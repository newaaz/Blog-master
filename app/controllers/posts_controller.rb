class PostsController < ApplicationController
  def index
    @posts = Post.all
  end

  def show
    @post = Post.with_attached_files.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params.merge(region_id: current_user.region_id))

    if @post.save
      flash[:success] = "Объявление добавлено и ожидает проверки. После активации вам на почту придёт письмо"
      redirect_to @post
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

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    @post.update(post_params)
    redirect_to posts_path
  end

  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :body, :region_id, files: [])
  end
end