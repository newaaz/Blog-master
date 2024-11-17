class PostStateChangeService
  def self.change_state(post_id, state_action)
    post = Post.includes(:user).find(post_id)
    user = post.user

    policy = PostPolicy.new(user, post)
    return unless policy.public_send("#{state_action}?")

    post.change_state(state_action)
  rescue ActiveRecord::RecordNotFound => exception
    Rails.logger.error "Could not find record: #{exception.message}"
  end
end
