require 'rails_helper'

feature 'User can send post to moderation Admin can accept or reject vacation requests', %q{
  In order to moderate the posts
  As an user I'd like to be able to send posts on moderation,
  As an admin I'd like to be able to accept or reject posts sended on moderation
} do

  given!(:region) { create(:region) }
  given(:user)    { create(:user, region: region) }
  given(:admin)   { create(:user, admin: true, region: nil) }
  given!(:draft_post)    { create(:post, user: user, region: region, state: 'draft') }
  given!(:approved_post) { create(:post, user: user, region: region, state: 'approved') }

  # scenario 'User can send post on moderation Admin can accept or reject vacation requests', js: true do
  scenario 'User can send post on moderation Admin can accept or reject vacation requests', js: true do
    Capybara.using_session('user') do
      sign_in(user)
      within("#post_#{draft_post.id}") do
        click_on 'На модерацию'
      end

      within("#post_#{draft_post.id}") do
        expect(page).to have_content 'Обработка...'
        expect(page).to_not have_link 'На модерацию'
      end

      visit root_path
      expect(page).to have_css("#post_#{approved_post.id}")

      expect(page).to_not have_css("#post_#{draft_post.id}")
    end

    Capybara.using_session('admin') do
      sign_in(admin)
      visit admin_dashboard_path

      expect(page).to_not have_css("#post_#{approved_post.id}")
      save_and_open_page
      within("#post_#{draft_post.id}") do
        expect(page).to have_content draft_post.title
        expect(page).to have_link 'Принять'
        expect(page).to have_link 'Отклонить'

        click_on 'Принять'
      end

      within("#post_#{draft_post.id}") do
        expect(page).to have_content 'Обработка...'
        expect(page).to_not have_link 'Принять'
        expect(page).to_not have_link 'Отклонить'
      end
    end

    Capybara.using_session('guest') do
      visit root_path

      expect(page).to have_css("#post_#{approved_post.id}")
      expect(page).to have_css("#post_#{draft_post.id}")
    end

    Capybara.using_session('user') do
      visit user_path(user)

      within("#post_#{draft_post.id}") do
        expect(page).to have_content 'approved'
        expect(page).to_not have_link 'На модерацию'
      end
    end
  end
end

