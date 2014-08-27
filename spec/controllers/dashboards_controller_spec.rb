require "spec_helper"

describe DashboardsController do
  it "redirects to login if the user is not logged in" do
    get :show

    expect(response).to redirect_to(new_user_session_path)
  end
end
