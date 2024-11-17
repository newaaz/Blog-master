class PostStateChangeJob < ApplicationJob
  queue_as :default

  def perform(post_id, state_action)
    PostStateChangeService.change_state(post_id, state_action)
  end
end
