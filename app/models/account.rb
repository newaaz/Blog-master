class Account < ApplicationRecord
  MIN_AGE = 0
  MAX_AGE = 90
  VALID_GENDERS = %w[male female]

  has_many :account_interests, dependent: :destroy
  has_many :interests, through: :account_interests

  has_many :account_skills, dependent: :destroy
  has_many :skills, through: :account_skills
end
