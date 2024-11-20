FactoryBot.define do
  factory :post do
    association :user
    association :region
    title  { 'post_title' }
    body   { 'post_title' }
  end
end

