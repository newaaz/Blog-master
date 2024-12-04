FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "user_#{n}" }
    association :region
    fio      { 'Test User FIO' }
    password { '123456' }
    admin    { false }
    password_confirmation { '123456' }
  end
end
