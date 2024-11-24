require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:district) { create(:federal_district) }
  let(:region)   { create(:region, federal_district: district) }
  let(:user)     { create(:user, region: region) }
  let(:admin)    { create(:user, admin: true, region: nil) }
  # let(:posts) { create_list(:post, 3, user: user) }

  describe 'GET #new' do
    context 'Authenticated user' do
      before do
        login(user)
        get :new
      end

      it 'assigns a new post to @post' do
        expect(assigns(:post)).to be_a_new(Post)
      end

      it 'render new view' do
        expect(response).to render_template :new
      end
    end

    context 'Unauthenticated user' do
      before { get :new }

      it_behaves_like 'Redirect to root'
    end
  end

  describe 'POST #create' do
    context 'Authenticated user' do
      before { login(user) }

      context 'create post with valid attributes' do
        it 'saves new post in DB' do
          expect { post :create, params: { post: attributes_for(:post) } }.to change(Post, :count).by(1)
        end

        it 'redirect to the author of the post' do
          post :create, params: { post: attributes_for(:post) }
          expect(response).to redirect_to user_path(user)
        end

        it 'user region set for post' do
          post :create, params: { post: attributes_for(:post) }
          expect(assigns(:post).region).to eq user.region
        end

        it 'draft state set' do
          post :create, params: { post: attributes_for(:post) }
          expect(assigns(:post)).to be_draft
        end

        it 'user can not create post with other region' do
          region = create(:region, federal_district: FederalDistrict.first, name: 'Республика Алтай')

          post :create, params: { post: attributes_for(:post, region: region) }
          expect(assigns(:post).region).to eq user.region
          expect(assigns(:post).region).to_not eq region
        end
      end

      context 'create post with invalid attributes' do
        it 'does not saves new post in DB' do
          expect { post :create, params: { post: attributes_for(:post, title: nil) } }
            .not_to change(Post, :count)
        end

        it 're-renders new view' do
          post :create, params: { post: attributes_for(:post, title: nil) }
          expect(response).to render_template :new
        end
      end
    end

    context 'Authenticated admin' do
      let!(:region_altay) { create(:region, name: 'Республика Алтай') }

      before { login(admin) }

      it 'default region set for post if user-admin and has not region' do
        post :create, params: { post: attributes_for(:post, region: nil) }
        expect(assigns(:post).region).to eq Region.first
      end

      it 'admin can set custom region to post' do
        post :create, params: { post: attributes_for(:post, region: region_altay) }
        expect(assigns(:post).region).to eq region_altay
      end

      it 'approved state set' do
        post :create, params: { post: attributes_for(:post) }
        expect(assigns(:post)).to be_approved
      end
    end

    context 'Unauthenticated user create post' do
      it 'does not saves new order in DB' do
        expect { post :create, params: { post: attributes_for(:post) } }.not_to change(Post, :count)
      end

      it 'redirect to root path' do
        post :create, params: { post: attributes_for(:post) }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #show' do
    context 'when post accepted' do
      let(:post) { create(:post, user: user, state: Post::APPROVED) }

      it 'assigns the requested post to @post' do
        get :show, params: { id: post }
        expect(assigns(:post)).to eq post
      end

      it 'render show view' do
        get :show, params: { id: post }
        expect(response).to render_template :show
      end
    end

    context 'when post not accepted' do
      let(:post) { create(:post, user: user) }

      it 'redirect to root when guest' do
        get :show, params: { id: post }
        expect(response).to redirect_to root_path
      end

      it 'show when author' do
        login(user)
        get :show, params: { id: post }
        expect(response).to render_template :show
      end

      it 'show when admin' do
        login(admin)
        get :show, params: { id: post }
        expect(response).to render_template :show
      end
    end
  end

  # describe 'PATCH #update' do
  #   context 'Unauthenticated user change state post' do
  #     let(:post) { create(:post, user: user) }
  #
  #     it 'does not change post state' do
  #       patch :update, params: { id: post, post: { state: Post::APPROVED } }
  #       post.reload
  #       expect(post.state).to eq Post::DRAFT
  #     end
  #   end
  # end

  # describe 'GET #index' do
  # end
  #
  # describe 'DELETE #destroy' do
  # end
end

