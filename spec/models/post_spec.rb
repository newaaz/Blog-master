require 'rails_helper'

require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user)  { build(:user) }

  describe 'validations' do
    it 'validates presence of title' do
      post = Post.new(title: nil,  body: 'Some body', user: user,  region: user.region)
      expect(post).not_to be_valid
    end

    it 'validates presence of body' do
      post = Post.new(title: 'Some title',  body: nil, user: user,  region: user.region)
      expect(post).not_to be_valid
    end
  end

  describe 'associations' do
    let(:region) { build(:region) }

    it 'is belong to user' do
      post = Post.new(title: 'Some title',  body: 'Some body',  user: nil, region: region)
      post.valid?

      expect(post.errors.count).to eq 1
      expect(post.errors.first.full_message).to include("Автор требуется")
    end

    it 'is belong to region' do
      post = Post.new(title: 'Some title',  body: 'Some body',  user: user, region: nil)
      post.valid?

      expect(post.errors.count).to eq 1
      expect(post.errors.first.full_message).to include("Регион требуется")
    end

  end

  context 'when user is admin' do
    let!(:region) { create(:region) }
    let(:admin)   { build(:user, admin: true, region: nil) }

    it 'set the default region if the admin has no region' do
      post = Post.new(title: 'Some title', body: 'Some body', user: admin, region: nil)
      post.valid?
      expect(post.region).to eq region
    end

    it 'set published_at on creation' do
      post = Post.create(title: 'Some title', body: 'Some body', user: admin, region: region)

      expect(post.published_at).to be_within(0.2.second).of(post.created_at)
    end

    it 'set approved on creation' do
      post = Post.create(title: 'Some title', body: 'Some body', user: admin, region: region)

      expect(post.state).to eq 'approved'
    end
  end
end
