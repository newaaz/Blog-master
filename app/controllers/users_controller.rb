class UsersController < ApplicationController
  def show
    @user = User.includes(posts: { files_attachments: :blob })
                .find(params[:id])

    # authorize @employee
  end

  private

  # def pundit_user
  #   current_user
  # end
end