shared_examples "admin only action" do |run_action|
  def meet_expected_expectation
    %w(index show new edit).include?(controller.action_name) ? be_a_success : be_a_redirect
  end

  it "redirects to login given no user" do
    instance_exec(&run_action)

    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders 404 if logged in user is not an admin" do
    sign_in create(:user)

    instance_exec(&run_action)

    expect(response).to be_not_found
  end

  it "runs successfully for an admin" do
    sign_in create(:user, :admin)

    instance_exec(&run_action)

    expect(response).to meet_expected_expectation
  end
end
