module FeatureHelpers
  def sign_in(user)
    visit new_user_session_path
    fill_in 'Логин', with: user.login
    fill_in 'Пароль', with: user.password
    click_on 'Войти'
  end
end
