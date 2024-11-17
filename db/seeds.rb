# frozen_string_literal: true

User.destroy_all
Region.destroy_all
FederalDistrict.destroy_all

json_data = JSON.parse(File.read(Rails.root.join('db', 'seeds', 'regions.json')))

json_data['data'].each do |district|
  federal_district = FederalDistrict.create!(name: district['name'])

  federal_district.regions.create!(district['areas'].map { |area| { name: area['name'] } })
end

User.create!(login: 'admin', password: 'admin', admin: true, fio: 'Admin Adminovich')

user = User.create!(login: 'user', password: 'user', region: Region.all.sample, admin: false, fio: 'Антонов Александр')

20.times do |i|
  state = i < 5 ? :draft : :approved

  post = user.posts.create!(title: "Статья № #{i} о регионе #{Region.all.sample.name}",
                            body: "Описание #{i}: Климат средней полосы России, с его четко выраженными сезонами, влияет на жизнь жителей региона, обуславливая как трудовые, так и культурные практики. Зимние морозы и теплая летняя погода создают особые условия для сельского хозяйства, где фермеры выращивают зерновые, овощи и фрукты, радуя местных жителей и обеспечивая рынки свежими продуктами. К тому же, средний регион является настоящей сокровищницей природных ресурсов: живописные заповедники и национальные парки открывают двери для туристов, желающих насладиться уникальной флорой и фауной, что подтверждает богатство и разнообразие этого чарующего уголка России.",
                            state: state,
                            region: user.region)

  rand(5).times do |i|
    if i < 2
      post.files.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'map.png')),
                        filename: 'map.png', content_type: 'image/jpeg')
    else
      post.files.attach(io: File.open(Rails.root.join('app', 'assets', 'files', 'test_file.txt')),
                        filename: 'test_file.txt', content_type: 'text/plain')
    end
  end
end

puts "База данных успешно заполнена тестовыми данными."
