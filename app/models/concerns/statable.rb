module Statable
  extend ActiveSupport::Concern

  included do
    STATE_ACTIONS = %w[submit_to_review approve reject]

    DRAFT = 'draft'
    UNDER_REVIEW = 'under_review'
    APPROVED = 'approved'
    REJECTED = 'rejected'

    include AASM

    enum state: { draft: 0, under_review: 1, approved: 2, rejected: 3 }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :under_review,
            :approved,
            :rejected

      event :submit_to_review do
        transitions from: :draft, to: :under_review
      end

      event :approve do
        before { self.published_at = Time.current}
        after  { broadcast_approved_post }
        transitions from: :under_review, to: :approved
      end

      event :reject do
        transitions from: :under_review, to: :rejected
      end
    end

    def change_state(state_action)
      self.send("#{state_action}!")
    end

    private

    def broadcast_approved_post
      ActionCable.server.broadcast(
        'posts_channel',
        self.as_json(
          only: %i[id title body created_at],
          include: {
            user: { only: %i[id fio] },
            region: { only: %i[name] }
          }
        )
      )
    end
  end
end
