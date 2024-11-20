FactoryBot.define do
  factory :user do
    association :region
    login    { 'login' }
    fio      { 'Test Employee FIO' }
    password { 'user' }
    admin    { false }
    password_confirmation { '12345678' }
  end
end
