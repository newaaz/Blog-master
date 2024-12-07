require 'rails_helper'

feature 'User can filter posts', %q{
  In order to find specific posts
  As an any user
  I'd like to be able to filter posts by region, author and date range
} do

  given(:district1) { create(:federal_district, name: 'Центральный федеральный округ') }
  given(:district2) { create(:federal_district, name: 'Северо-Западный федеральный округ') }

  given(:region1) { create(:region, name: 'Москва', federal_district: district1) }
  given(:region2) { create(:region, name: 'Санкт-Петербург', federal_district: district2) }

  given(:user1) { create(:user, region: region1, fio: 'Иванов Иван Иванович') }
  given(:user2) { create(:user, region: region2, fio: 'Петров Петр Петрович') }

  given!(:posts_region1) { create_list(:post, 2, user: user1, state: 'approved') }
  given!(:posts_region2) { create_list(:post, 2, user: user2, state: 'approved') }

  given!(:old_post) { create(:post, user: user1, state: 'approved', published_at: 1.month.ago) }
  given!(:new_post) { create(:post, user: user2, state: 'approved', published_at: 1.day.ago) }

  describe 'Any user', js: true do
    before { visit root_path }

    scenario 'can see all approved posts without filters' do
      expect(page).to have_css('.post', count: 6) # всего 6 постов (2+2+2)
    end

    scenario 'can filter posts by region' do
      select 'Москва', from: 'region_id'
      click_button 'Фильтр'

      expect(page).to have_css('.post', count: 3) # 2 поста + 1 старый пост
      posts_region1.each do |post|
        expect(page).to have_css("#post_#{post.id}")
      end
      expect(page).to have_css("#post_#{old_post.id}")

      posts_region2.each do |post|
        expect(page).to_not have_css("#post_#{post.id}")
      end
    end

    scenario 'can filter posts by author' do
      select "#{user1.fio}", from: 'user_id'
      click_button 'Фильтр'

      expect(page).to have_css('.post', count: 3) # 2 поста + 1 старый пост
      posts_region1.each do |post|
        expect(page).to have_css("#post_#{post.id}")
      end
    end

    scenario 'can filter posts by date range' do
      fill_in 'start_date', with: 2.days.ago.strftime('%m/%d/%Y')
      fill_in 'end_date', with: Time.current.strftime('%m/%d/%Y')
      click_button 'Фильтр'

      expect(page).to have_css("#post_#{new_post.id}")
      expect(page).to_not have_css("#post_#{old_post.id}")
    end

    scenario 'can filter posts by multiple parameters' do
      select 'Санкт-Петербург', from: 'region_id'
      select "#{user2.fio}", from: 'user_id'
      fill_in 'start_date', with: 2.days.ago.strftime('%m/%d/%Y')
      fill_in 'end_date', with: Time.current.strftime('%m/%d/%Y')

      click_button 'Фильтр'

      expect(page).to have_css("#post_#{new_post.id}")
      expect(page).to_not have_css("#post_#{old_post.id}")
      posts_region1.each do |post|
        expect(page).to_not have_css("#post_#{post.id}")
      end
    end

    scenario 'sees error message when end date is earlier than start date' do
      fill_in 'start_date', with: 1.day.ago.strftime('%m/%d/%Y')
      fill_in 'end_date', with: 2.days.ago.strftime('%m/%d/%Y')
      click_button 'Фильтр'

      expect(page).to have_content('Неверно указаны даты')
    end

    # Необходимо указать обе даты для фильтрации по дате
    scenario 'sees error message when only one date is specified' do
      fill_in 'start_date', with: 1.day.ago.strftime('%m/%d/%Y')
      click_button 'Фильтр'

      expect(page).to have_content('Необходимо указать обе даты')
    end

    scenario 'can reset filters by selecting blank options' do
      select 'Москва', from: 'region_id'
      click_button 'Фильтр'

      expect(page).to have_css('.post', count: 3)

      select 'Все регионы', from: 'region_id'
      click_button 'Фильтр'

      expect(page).to have_css('.post', count: 6)
    end
  end
end
