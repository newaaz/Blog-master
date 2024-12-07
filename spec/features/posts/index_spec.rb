require 'rails_helper'

feature 'User can view approved posts', %q{
  In order to read posts
  As an any user
  I'd like to be able to view approved posts on main page
} do
  given!(:region) { create(:region) }
  given(:user)    { create(:user, region: region) }
  given!(:approved_posts)   { create_list(:post, 3, user: user, state: 'approved') }
  given!(:draft_posts)      { create_list(:post, 3, user: user, state: 'draft') }
  given!(:moderation_posts) { create_list(:post, 3, user: user, state: 'under_review') }
  given!(:rejected_posts)   { create_list(:post, 3, user: user, state: 'rejected') }

  describe 'Any user' do
    before { visit root_path }

    scenario 'sees approved posts' do
      approved_posts.each do |post|
        expect(page).to have_css("#post_#{post.id}")

        within("#post_#{post.id}") do
          expect(page).to have_content post.title
          expect(page).to have_content post.body
        end
      end
    end

    scenario 'does not see posts with other states' do
      draft_posts.each do |post|
        expect(page).to_not have_css("#post_#{post.id}")
      end

      moderation_posts.each do |post|
        expect(page).to_not have_css("#post_#{post.id}")
      end

      rejected_posts.each do |post|
        expect(page).to_not have_css("#post_#{post.id}")
      end
    end
  end

  describe 'Author of posts' do
    before do
      sign_in(user)
      visit root_path
    end

    scenario 'sees only approved posts on main page' do
      approved_posts.each do |post|
        expect(page).to have_css("#post_#{post.id}")
      end

      (draft_posts + moderation_posts + rejected_posts).each do |post|
        expect(page).to_not have_css("#post_#{post.id}")
      end
    end
  end
end
