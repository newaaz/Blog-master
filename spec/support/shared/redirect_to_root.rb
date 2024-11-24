shared_examples_for 'Redirect to root' do
  it 'redirect to root path' do
    expect(response).to redirect_to root_path
  end
end
