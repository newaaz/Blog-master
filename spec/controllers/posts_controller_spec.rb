require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:district) { create(:federal_district) }
  let(:region)   { create(:region, federal_district: district) }
  let(:user)     { create(:user, region: region) }
  let(:admin)    { create(:user, admin: true, region: nil) }

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

  describe 'PATCH #update' do
    let(:author) { create(:user, region: region) }
    let(:post)   { create(:post, user: author) }

    before { ActiveJob::Base.queue_adapter = :test }

    context 'change state from draft' do
      let(:state_action) { 'submit_to_review' }

      context 'authenticated author' do
        before { login(author) }

        it 'enqueues PostStateChangeJob with correct arguments' do
          expect {
            patch :update, params: { id: post.id, state_action: state_action }
          }.to have_enqueued_job(PostStateChangeJob)
                 .with(post.id, state_action)
                 .on_queue('default')
        end
      end

      context 'authenticated user non-author' do
        before { login(user) }

        it_behaves_like 'State authorized'
      end

      context 'authenticated user-admin changes state from draft' do
        before { login(admin) }

        it_behaves_like 'State authorized'
      end

      context 'Unauthenticated user change state post' do
        it_behaves_like 'State authorized'
      end
    end

    context 'change state to approve from under_review' do
      let(:state_action) { 'approve' }

      context 'authenticated user-admin changes state to approved from under_review' do
        before { login(admin) }

        before { post.update(state: Post::UNDER_REVIEW)}

        it 'enqueues PostStateChangeJob with correct arguments' do
          expect {
            patch :update, params: { id: post.id, state_action: state_action }
          }.to have_enqueued_job(PostStateChangeJob)
                 .with(post.id, state_action)
                 .on_queue('default')
        end
      end

      context 'authenticated user-admin changes state to approved from draft' do
        before { login(admin) }

        it_behaves_like 'State authorized'
      end

      context 'authenticated author' do
        before { login(author) }

        it_behaves_like 'State authorized'
      end

      context 'authenticated user non-author' do
        before { login(user) }

        it_behaves_like 'State authorized'
      end

      context 'Unauthenticated user change state post' do
        it_behaves_like 'State authorized'
      end

    end

    context 'change state to approve from under_review' do
      let(:state_action) { 'reject' }

      context 'authenticated user-admin changes state to approved from under_review' do
        before { login(admin) }

        before { post.update(state: Post::UNDER_REVIEW)}

        it 'enqueues PostStateChangeJob with correct arguments' do
          expect {
            patch :update, params: { id: post.id, state_action: state_action }
          }.to have_enqueued_job(PostStateChangeJob)
                 .with(post.id, state_action)
                 .on_queue('default')
        end
      end

      context 'authenticated user-admin changes state to approved from draft' do
        before { login(admin) }

        it_behaves_like 'State authorized'
      end

      context 'authenticated author' do
        before { login(author) }

        it_behaves_like 'State authorized'
      end

      context 'authenticated user non-author' do
        before { login(user) }

        it_behaves_like 'State authorized'
      end

      context 'Unauthenticated user change state post' do
        it_behaves_like 'State authorized'
      end
    end
  end

  describe 'GET #index' do
    let(:region_altay)    { create(:region, federal_district: district, name: 'Республика Алтай') }
    let(:author)          { create(:user, region: region_altay) }
    let!(:published_posts) { create_list(:post, 3, user: author, state: Post::APPROVED) }
    let!(:user_posts)      { create_list(:post, 3, user: user) }
    let!(:admin_posts)     { create_list(:post, 3, user: admin, region: region) }

    it 'populates an array of only published posts' do
      get :index

      expect(assigns(:posts)).to match_array(published_posts + admin_posts)
      expect(assigns(:posts).count).to eq (published_posts + admin_posts).count
    end

    it 'does not fill the array of unpublished messages' do
      get :index

      expect(assigns(:posts)).to_not include(user_posts)
    end

    it 'filtering by author' do
      get :index, params: { user_id: author.id }

      expect(assigns(:posts)).to match_array(published_posts)
    end

    it 'filtering by region' do
      get :index, params: { region_id: region_altay.id }
      expect(assigns(:posts)).to match_array(published_posts)
    end

    context 'advanced filtering' do
      let!(:yesterdays_posts) { create_list(:post, 4, user: author, state: Post::APPROVED, published_at: 2.day.ago) }
      let!(:todays_posts)     { create_list(:post, 4, user: admin, published_at: 1.day.ago) }

      it 'filtering by date' do
        get :index, params: { start_date: 2.days.ago, end_date: 1.days.ago }

        expect(assigns(:posts)).to match_array(yesterdays_posts)
      end

      it 'filtering by date, author, region' do
        get :index, params: { start_date: 1.day.ago,  end_date: Date.today, user_id: admin.id, region_id: Region.first.id}

        expect(assigns(:posts)).to match_array(todays_posts)
      end
    end

    context 'when format is xlsx' do
      let!(:posts)        { published_posts + admin_posts }
      let(:excel_data)    { 'fake_excel_data' }
      let(:excel_service) { instance_double(PostExcelExportService) }

      before do
        allow(Post).to receive(:find_by_filters).with(any_args).and_return(posts)

        allow(PostExcelExportService).to receive(:new).with(any_args).and_return(excel_service)

        allow(excel_service).to receive(:export_to_excel).and_return(excel_data)

        allow(Date).to receive(:today).and_return(Date.new(2024, 11, 24))

        allow_any_instance_of(Kernel).to receive(:rand).with(100).and_return(42)
      end

      it 'returns xlsx file with correct headers' do
        get :index, format: :xlsx

        expect(response.content_type).to eq('application/vnd.ms-excel')
        expect(response.headers['Content-Disposition']).to include('posts-2024-11-24-42.xlsx')
      end

      it 'calls PostExcelExportService with correct parameters' do
        get :index, format: :xlsx

        expect(PostExcelExportService).to have_received(:new).with(posts)
        expect(excel_service).to have_received(:export_to_excel)
      end

      it 'sends data generated by export service' do
        get :index, format: :xlsx

        expect(response.body).to eq excel_data
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:post) { create(:post, user: user) }

    context 'Authenticated user' do
      before { login(user) }

      it 'deletes the post' do
        expect { delete :destroy, params: { id: post } }.to change(Post, :count).by(-1)
      end

      it 'does not deletes when the post is not a draft' do
        post.update(state: Post::UNDER_REVIEW)

        expect { delete :destroy, params: { id: post } }.not_to change(Post, :count)
      end
    end

    context 'Authenticated admin' do
      before { login(admin) }

      it 'does not deletes the post' do
        expect { delete :destroy, params: { id: post } }.not_to change(Post, :count)
      end
    end

    context 'Unauthenticated user' do
      it 'does not deletes the post' do
        expect { delete :destroy, params: { id: post } }.not_to change(Post, :count)
      end
    end
  end
end
