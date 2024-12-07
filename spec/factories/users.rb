FactoryBot.define do
  factory :user do
    association :region
    sequence(:login) { |n| "user_#{n}" }
    sequence(:fio) { |n| "Test User FIO_#{n}" }
    password { '123456' }
    admin    { false }
    password_confirmation { '123456' }
  end
end
