class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]
  before_action :authorize_post!, except: %i[update]

  after_action  :verify_authorized, except: %i[update]

  def index
    filter_params = params.permit(:region_id, :user_id, :start_date, :end_date)

    check_dates if params[:start_date].present? && params[:start_date].present?

    @posts = Post.find_by_filters(filter_params)
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
    if current_user.admin?
      region_id = post_params[:region_id].presence || current_user.region_id
    else
      region_id = current_user.region_id
    end

    @post = current_user.posts.build(post_params.merge(region_id: region_id))

    if @post.save
      flash[:success] = "Пост добавлен в черновики. Для публикации отправьте его на модерацию"
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

      @post.change_state(state_action)

      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.turbo_stream do
          render turbo_stream:
                   turbo_stream.replace(@post, partial: 'posts/post', locals: { post: @post })
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

  def check_dates
    if params[:start_date] > params[:end_date]
      flash[:error] = 'Неверно указаны даты'
      redirect_back(fallback_location: root_path)
    end
  end
end
