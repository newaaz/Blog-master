# frozen_string_literal: true

Region.destroy_all
FederalDistrict.destroy_all

json_data = JSON.parse(File.read(File.join(__dir__, 'seeds', 'regions.json')))

json_data['data'].each do |district|
  federal_district = FederalDistrict.create!(name: district['name'])

  federal_district.regions.create!(district['areas'].map { |area| { name: area['name'] } })
end
