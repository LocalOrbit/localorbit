shared_examples "admin only action" do |run_action|
  it "redirects to login given no user" do
    instance_exec(&run_action)

    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders 404 if logged in user is not an admin" do
    sign_in create(:user)

    instance_exec(&run_action)

    expect(response).to be_not_found
  end
end