shared_examples "an action that restricts access admin, market manager, or seller only" do |run_action|
  def meet_expected_expectation
    %w[total_sales].include?(controller.action_name) ? be_a_success : be_a_redirect
  end

  it "redirects to login given no user" do
    instance_exec(&run_action)

    expect(response).to redirect_to(new_user_session_path)
  end

  it "renders 404 if logged in user is a buyer only" do
    sign_in create(:user)

    instance_exec(&run_action)

    expect(response).to be_not_found
  end

  it "runs successfully for an admin" do
    sign_in create(:user, :admin)

    instance_exec(&run_action)

    expect(response).to meet_expected_expectation
  end

  it "runs successfully for a market manager" do
    sign_in create(:user, :market_manager)

    instance_exec(&run_action)

    expect(response).to meet_expected_expectation
  end

  it "runs successfully for a seller" do
    sign_in create(:user, :seller)

    instance_exec(&run_action)

    expect(response).to meet_expected_expectation
  end
end
