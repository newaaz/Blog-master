class PostStateChangeService
  def self.change_state(post_id, state_action)
    post = Post.find(post_id)

    post.change_state(state_action)
  rescue ActiveRecord::RecordNotFound => exception
    Rails.logger.error "Could not find record: #{exception.message}"
  end
end
