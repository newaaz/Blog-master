require 'rails_helper'

feature 'User can sign out', %q{
  In order to protect my account
  As an authenticated user
  I'd like to be able to sign out
} do

  given(:user) { create(:user) }

  scenario 'Authenticated user tries to sign out' do
    sign_in(user)

    click_on 'Выход'

    expect(page).to have_content 'Выход из системы выполнен.'
    expect(page).not_to have_content user.login
    expect(current_path).to eq root_path
  end

  scenario 'Unauthenticated user can not see sign out link' do
    visit root_path

    expect(page).not_to have_link 'Выход'
  end
end
