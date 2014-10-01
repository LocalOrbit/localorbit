require "spec_helper"

describe StyleGuideController do
  describe "/index" do
    after do
      ENV['DEPLOY_ENV'] = 'test'
    end

    it "renders in non-production deploy environments" do
      %w[ dev1 dev2 dev3 test staging ].each do |env|
        ENV['DEPLOY_ENV'] = env
        get :index
        expect(response).to be_success
      end
    end

    it "raises a routing error in the production deploy environment" do
      ENV['DEPLOY_ENV'] = 'production'
      expect { get :index }.to raise_error(ActionController::RoutingError)
    end
  end
end
