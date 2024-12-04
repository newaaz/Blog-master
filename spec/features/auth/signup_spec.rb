require 'rails_helper'

feature 'User can sign up', %q{
  In order to publish posts
  As an unregistered user
  I'd like to be able to sign up
} do

  given!(:altai_region) { create(:region, name: 'Алтайский край') }
  given(:user) { build(:user) }

  scenario 'Unregistered user tries to sign up' do
    complete_registration

    expect(page).to have_content 'Добро пожаловать! Вы успешно зарегистрировались.'
  end

  scenario 'User tries to sign up with errors' do
    visit new_user_registration_path
    click_on 'Зарегистрироваться'

    expect(page).to have_content "Регион не может быть пустым"
    expect(page).to have_content "Логин не может быть пустым"
    expect(page).to have_content "Имя не может быть пустым"
  end

  scenario 'User is redirected to users show path after successful registration' do
    login = user.login
    complete_registration

    created_user = User.find_by(login: login)
    expect(current_path).to eq user_path(created_user)
  end

  scenario 'Registered user tries to sign up' do
    complete_registration
    click_on 'Выход'
    complete_registration

    expect(page).to have_content 'Логин уже зарегистрирован'
  end

  scenario 'User tries to sign up with too short password' do
    visit new_user_registration_path
    fill_in 'Логин', with: user.login
    fill_in 'Имя', with: user.fio
    select altai_region.name, from: 'Регион'
    fill_in 'Пароль', with: '123'
    fill_in 'Подтверждение пароля', with: '123'
    click_on 'Зарегистрироваться'

    expect(page).to have_content 'Пароль слишком короткий'
  end

  private

  def complete_registration
    visit new_user_registration_path
    fill_in 'Логин', with: user.login
    fill_in 'Имя', with: user.fio
    select altai_region.name, from: 'Регион'
    fill_in 'Пароль', with: '123456'
    fill_in 'Подтверждение пароля', with: '123456'
    click_on 'Зарегистрироваться'
  end
end