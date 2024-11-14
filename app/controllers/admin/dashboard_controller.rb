class Admin::DashboardController < Admin::BaseController
  def index
    @pending_posts = Post.under_review
  end
end
