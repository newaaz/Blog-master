class PostsController < ApplicationController
  include DatesChecked

  # before_action :authenticate_user!, except: %i[index show]
  before_action :set_post, only: %i[show update destroy]
  before_action :authorize_post!

  after_action  :verify_authorized

  def index
    filter_params = params.permit(:region_id, :user_id, :start_date, :end_date)

    if filter_params[:start_date].present? || filter_params[:end_date].present?
      respond_date_error and return unless dates_valid?
    end

    @posts = Post.find_by_filters(filter_params)

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('posts',
                              render_to_string(partial: 'posts/post_index',
                                               collection: @posts,
                                               as: :post)),
          turbo_stream.update('forms_errors',
                              render_to_string(partial: 'shared/error_messages',
                                               locals: { message: nil }))
        ]
      end
      format.xlsx do
        send_excel
      end
    end
  end

  def show
    @images = []
    @files = []
    @post.files.each do |file|
      if file.image?
        @images << file
      else
        @files << file
      end
    end
  end

  def new
    @post = Post.new
  end

  def create
    region_id = set_region_id

    @post = current_user.posts.build(post_params.merge(region_id: region_id))

    if @post.save
      flash[:success] = "Пост добавлен в черновики. Для публикации отправьте его на модерацию" if current_user.admin?
      redirect_to @post.user
    else
      respond_to do |format|
        format.html { render 'new', status: :unprocessable_entity }

        format.turbo_stream do
          render turbo_stream:
                   turbo_stream.update('forms_errors',
                                       partial: 'shared/errors',
                                       locals:   { object: @post })
        end
      end
    end
  end

  def update
    state_action = params[:state_action]

    if state_action && state_action_exist?(state_action)
      authorize(@post, "#{state_action}?")

      PostStateChangeJob.perform_later(@post.id, state_action)

      respond_to do |format|
        format.html {
          redirect_back(
            fallback_location: root_path,
            notice: 'Запрос на изменение состояния поста отправлен'
          )
        }
        format.turbo_stream do
          render turbo_stream:
                   turbo_stream.replace(@post, partial: 'posts/post_update', locals: { post: @post })
        end
      end

    else
      redirect_to root_path, flash: { error: 'Неправильное действие' }
    end
  end

  def destroy
    @post.destroy

    respond_to do |format|
      format.html { redirect_to @post.user, notice: 'Пост удалён' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("post_#{@post.id}")
      end
    end
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :region_id, files: [])
  end

  def set_post
    @post = Post.with_attached_files.find(params[:id])
  end

  def state_action_exist?(state_action)
    Post::STATE_ACTIONS.include?(state_action)
  end

  def pundit_user
    current_user
  end

  def authorize_post!
    authorize(@post || Post)
  end

  def send_excel
    xlsx_data = PostExcelExportService.new(@posts).export_to_excel
    send_data xlsx_data, filename: "posts-#{Date.today}-#{rand(100)}.xlsx"
  end

  def set_region_id
    if current_user.admin?
      post_params[:region_id].presence || current_user.region_id
    else
      current_user.region_id
    end
  end
end
