shared_examples "an action restricted to admin, market manager, member" do |action|
  def meet_expected_expectation
    %w(index new edit).include?(controller.action_name) ? be_a_success : be_a_redirect
  end

  it "prevents access when not signed in" do
    instance_exec(&action)

    expect(response).to redirect_to(new_user_session_path)
  end

  it "prevents access when not a member of the organization" do
    sign_in non_member

    instance_exec(&action)

    expect(response).to be_not_found
  end

  it "prevents access to market managers of another organization" do
    sign_in market_manager_non_member

    instance_exec(&action)

    expect(response).to be_not_found
  end

  it "grants access to organization members" do
    sign_in organization_member

    instance_exec(&action)

    expect(response).to meet_expected_expectation
  end

  it "grants access to market managers of this organization" do
    sign_in market_manager_member

    instance_exec(&action)

    expect(response).to meet_expected_expectation
  end

  it "grants access to admins" do
    sign_in admin

    instance_exec(&action)

    expect(response).to meet_expected_expectation
  end
end
