FactoryBot.define do
  factory :region do
    association :federal_district
    name  { 'Ярославская область' }
  end
end
