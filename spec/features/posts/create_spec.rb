require 'rails_helper'

feature 'User can create post', %q{
  In order to share information
  As an authenticated user
  I'd like to be able to create post
} do

  given!(:region) { create(:region) }
  given(:user)    { create(:user, region: region) }
  given(:admin)   { create(:user, admin: true, region: nil) }

  describe 'Authenticated user' do
    background do
      sign_in(user)
      page.find('.new_post').click
    end

    scenario 'tries to create post' do
      fill_in 'Заголовок', with: 'Test title'
      fill_in 'Текст', with: 'Test body'
      click_button 'Добавить пост'

      post = Post.last

      expect(page).to have_current_path(user_path(user))

      within("#post_#{post.id}") do
        expect(page).to have_link 'Test title'
        expect(page).to have_content 'draft'
        expect(page).to have_link 'На модерацию'
        expect(page).to have_link 'Удалить'
      end
    end

    scenario 'tries to create post with errors' do
      click_on 'Добавить пост'

      expect(page).to have_content "Заголовок не может быть пустым"
      expect(page).to have_content "Текст не может быть пустым"
    end

    scenario 'cannot see region select' do
      expect(page).not_to have_select('post_region_id')
    end
  end

  describe 'Authenticated user creates post with attachments' do
    let(:image_path) { "#{Rails.root}/app/assets/images/map.png" }
    let(:file_path)  { "#{Rails.root}/app/assets/files/test_file.txt" }

    background do
      sign_in(user)
      page.find('.new_post').click
    end

    scenario 'with valid files' do
      fill_in 'Заголовок', with: 'Test title'
      fill_in 'Текст', with: 'Test body'

      attach_file 'post[files][]', [image_path, file_path]

      click_button 'Добавить пост'

      post = Post.last

      visit post_path(post)

      expect(page).to have_css("img[src*='map.png']")
      expect(page).to have_link 'test_file.txt'
    end

    # scenario 'with invalid file type' do
    #   fill_in 'Заголовок', with: 'Test title'
    #   fill_in 'Текст', with: 'Test body'
    #
    #   attach_file 'post[files][]', "#{Rails.root}/app/assets/files/invalid.exe"
    #
    #   click_button 'Добавить пост'
    #
    #   expect(page).to have_content 'Неправильный формат файла'
    # end
    #
    # scenario 'with too large file' do
    #   fill_in 'Заголовок', with: 'Test title'
    #   fill_in 'Текст', with: 'Test body'
    #
    #   attach_file 'post[files][]', "#{Rails.root}/app/assets/files/large_file.jpg"
    #
    #   click_button 'Добавить пост'
    #
    #   expect(page).to have_content 'Размер файла превышает допустимый'
    # end
  end

  describe 'Admin' do
    background do
      sign_in(admin)
      click_on 'Новый пост'
    end

    scenario 'creates post with selected region' do
      fill_in 'Заголовок', with: 'Admin post'
      fill_in 'Текст', with: 'Admin post body'
      select region.name, from: 'post_region_id'
      click_on 'Добавить пост'

      expect(page).to have_current_path(user_path(admin))

      post = Post.last

      within("#post_#{post.id}") do
        expect(page).to have_link 'Admin post'
        expect(page).to have_content 'approved'
      end

      expect(page).to have_content 'Пост добавлен в черновики. Для публикации отправьте его на модерацию'
      expect(Post.last.region).to eq region
    end

    scenario 'tries to create post with errors' do
      click_on 'Добавить пост'

      expect(page).to have_content "Заголовок не может быть пустым"
      expect(page).to have_content "Текст не может быть пустым"
    end

    scenario 'can see region select' do
      expect(page).to have_select('post_region_id')
    end
  end

  describe 'Unauthenticated user' do
    scenario 'tries to create post' do
      visit new_post_path

      expect(page).to have_content 'Вы не авторизованы для этого действия'
      expect(current_path).to eq root_path
    end
  end
end
