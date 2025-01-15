class Skill < ApplicationRecord
  has_many :account_skills
  has_many :accounts, through: :account_skills
end
