module Statable
  extend ActiveSupport::Concern

  included do
    STATE_ACTIONS = %w[submit_to_review approve reject]

    include AASM

    enum state: { draft: 0, under_review: 1, approved: 2, rejected: 3 }

    aasm column: :state, enum: true do
      state :draft, initial: true
      state :under_review,
            :approved,
            :rejected

      event :submit_to_review do
        transitions from: :draft, to: :under_review
        # after do
        #   PostStateChangeJob.perform_later(self)
        # end
      end

      event :approve do
        before { self.published_at = Time.current}
        transitions from: :under_review, to: :approved
        # after { self.update(published_at: Time.current)}
      end

      event :reject do
        transitions from: :under_review, to: :rejected
      end
    end

    def change_state(state_action)
      self.send("#{state_action}!")
    end
  end
end
