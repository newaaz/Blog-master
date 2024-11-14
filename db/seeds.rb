# frozen_string_literal: true

User.destroy_all
Region.destroy_all
FederalDistrict.destroy_all

json_data = JSON.parse(File.read(Rails.root.join('db', 'seeds', 'regions.json')))

json_data['data'].each do |district|
  federal_district = FederalDistrict.create!(name: district['name'])

  federal_district.regions.create!(district['areas'].map { |area| { name: area['name'] } })
end
