class Interest < ApplicationRecord
  has_many :account_interests
  has_many :accounts, through: :account_interests
end
