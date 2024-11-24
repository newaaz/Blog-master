require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:admin) { create(:user, admin: true, region: nil) }
  let(:user)  { create(:user) }

  describe 'GET #show' do
    context 'when authenticated user' do
      before do
        login(user)
        get(:show, params: { id: user })
      end

      it 'assigns requested user to @user' do
        expect(assigns(:user)).to eq user
      end

      it 'render new show' do
        expect(response).to render_template :show
      end
    end

    context "when unauthenticated user is trying to access the user's page" do
      it 'redirect to root path' do
        get(:show, params: { id: user })
        expect(response).to redirect_to root_path
      end
    end

    context "when admin is trying to access the user's page" do
      it 'redirect to root path' do
        sign_in(admin)
        get(:show, params: { id: user })
        expect(response).to redirect_to root_path
      end
    end
  end
end
