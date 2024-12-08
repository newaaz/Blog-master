require 'rails_helper'

feature 'User can download posts report', %q{
  In order to get posts data in Excel format
  As an any user
  I'd like to be able to download posts report with or without filters
} do

  given(:district1) { create(:federal_district, name: 'Центральный федеральный округ') }
  given(:district2) { create(:federal_district, name: 'Северо-Западный федеральный округ') }

  given(:region1) { create(:region, name: 'Москва', federal_district: district1) }
  given(:region2) { create(:region, name: 'Санкт-Петербург', federal_district: district2) }

  given(:user1) { create(:user, region: region1, fio: 'Иванов Иван Иванович') }
  given(:user2) { create(:user, region: region2, fio: 'Петров Петр Петрович') }

  given!(:posts_region1) { create_list(:post, 2, user: user1, state: 'approved') }
  given!(:posts_region2) { create_list(:post, 2, user: user2, state: 'approved') }

  describe 'Any user', js: true do
    before do
      clear_downloads
      visit root_path
    end

    after { clear_downloads }

    scenario 'downloads report with ALL approved posts' do
      click_link 'Скачать отчет'

      wait_for_download

      downloaded_file = downloads.first

      expect(downloaded_file).to match(/.*\.xlsx/)

      workbook = Spreadsheet.open(downloaded_file)
      sheet = workbook.worksheet(0)

      expect(sheet.rows.count).to eq(1 + Post.all.count)

      expect(sheet.row(0)).to eq ['Регион', 'Заголовок', 'Текст поста', 'Автор', 'Файлы', 'Дата размещения']

      excel_data = sheet.rows[1..-1].map { |row| row[0..3] }

      Post.all.each do |post|
        post_data = [
          post.region.name,
          post.title,
          post.body,
          post.user.fio
        ]
        expect(excel_data).to include(post_data)
      end
    end

    scenario 'downloads filtered report by region' do
      select 'Москва', from: 'Регион'
      click_button 'Фильтр'

      click_link 'Скачать отчет'

      wait_for_download

      downloaded_file = downloads.first
      workbook = Spreadsheet.open(downloaded_file)
      sheet = workbook.worksheet(0)

      expect(sheet.rows.count).to eq(1 + posts_region1.count)

      sheet.rows[1..-1].each do |row|
        expect(row[0]).to eq 'Москва'
      end
    end

    scenario 'downloads filtered report by author' do
      select 'Иванов Иван Иванович', from: 'Автор'
      click_link 'Скачать отчет'

      wait_for_download

      downloaded_file = downloads.first
      workbook = Spreadsheet.open(downloaded_file)
      sheet = workbook.worksheet(0)

      expect(sheet.rows.count).to eq(1 + user1.posts.count)

      sheet.rows[1..-1].each do |row|
        expect(row[3]).to eq 'Иванов Иван Иванович'
      end
    end
  end
end
