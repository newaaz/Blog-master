class AccountSkill < ApplicationRecord
  belongs_to :account
  belongs_to :skill
end
