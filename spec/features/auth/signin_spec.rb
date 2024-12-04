require 'rails_helper'

feature 'User can sign in', %q{
  In order to create posts
  As an registered user
  I'd like to be able to sign in
} do

  given(:user) { create(:user) }

  scenario 'Registered user tries to sign in' do
    sign_in(user)

    expect(page).to have_content 'Вход в систему выполнен.'
    expect(current_path).to eq user_path(user)
  end

  scenario 'Unregistered user tries to sign in' do
    visit new_user_session_path
    fill_in 'Логин', with: 'wrong_user'
    fill_in 'Пароль', with: '123456'
    click_button 'Войти'

    expect(page).to have_content 'Неверный Логин или пароль.'
    expect(current_path).to eq new_user_session_path
  end

  scenario 'User tries to sign in with wrong password' do
    visit new_user_session_path
    fill_in 'Логин', with: user.login
    fill_in 'Пароль', with: 'wrong_password'
    click_button 'Войти'

    expect(page).to have_content 'Неверный Логин или пароль.'
    expect(current_path).to eq new_user_session_path
  end

  scenario 'User tries to sign in with empty fields' do
    visit new_user_session_path
    click_button 'Войти'

    expect(page).to have_content 'Неверный Логин или пароль.'
    expect(current_path).to eq new_user_session_path
  end

  scenario 'User is already signed in' do
    sign_in(user)
    visit new_user_session_path

    expect(page).to have_content 'Вы уже вошли в систему.'
  end
end
