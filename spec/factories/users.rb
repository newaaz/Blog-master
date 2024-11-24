FactoryBot.define do
  factory :user do
    sequence(:login) { |n| "user_#{n}" }
    association :region
    fio      { 'Test Employee FIO' }
    password { 'user' }
    admin    { false }
    password_confirmation { '12345678' }
  end
end
