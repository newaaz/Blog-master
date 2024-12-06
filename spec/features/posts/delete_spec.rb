require 'rails_helper'

feature 'User can delete post', "
  In order to remove unnecessary information
  As an authenticated user
  I'd like to be able to delete my draft posts
" do

  given!(:region) { create(:region) }
  given!(:user) { create(:user, region:) }
  given!(:other_user) { create(:user, region:) }
  given!(:draft_post) { create(:post, user: user, state: 'draft') }
  given!(:approved_post) { create(:post, user: user, state: 'approved') }
  given!(:other_user_post) { create(:post, user: other_user, state: 'draft') }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      visit user_path(user)
    end

    scenario 'deletes his draft post' do
      within("#post_#{draft_post.id}") do
        expect(page).to have_link 'Удалить'
        click_on 'Удалить'
      end

      expect(page).to have_no_css("#post_#{draft_post.id}")
    end

    scenario 'cannot delete his approved post' do
      within("#post_#{approved_post.id}") do
        expect(page).not_to have_link 'Удалить'
      end
    end

    scenario "tries to delete other user's post" do
      visit user_path(other_user)

      expect(page).to have_content 'Вы не авторизованы для этого действия'
      expect(current_path).to eq root_path
    end
  end

  describe 'Unauthenticated user' do
    scenario "tries to delete user's post" do
      visit user_path(user)

      expect(page).to have_content 'Вы не авторизованы для этого действия'
      expect(current_path).to eq root_path
    end
  end
end

