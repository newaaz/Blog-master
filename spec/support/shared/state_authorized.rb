shared_examples_for 'State authorized' do
  it 'does not enqueues PostStateChangeJob with correct arguments' do
    expect {
      patch :update, params: { id: post.id, state_action: state_action }
    }.to_not have_enqueued_job(PostStateChangeJob)
      .with(post.id, state_action)
      .on_queue('default')
  end

  it 'redirect to root path' do
    patch :update, params: { id: post, state_action: state_action }
    expect(response).to redirect_to root_path
  end
end
