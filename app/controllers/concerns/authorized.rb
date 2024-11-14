module Authorized
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:warning] = 'Вы не авторизованы для этого действия'
      redirect_to root_path
    end
  end
end
