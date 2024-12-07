FactoryBot.define do
  factory :post do
    title  { 'post_title' }
    body   { 'post_body' }
    association :user

    after(:build) do |post|
      post.region ||= post.user.region
    end
  end
end
