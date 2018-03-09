require 'spec_helper'

RSpec.describe StyleGuideController, type: :controller do
  describe 'GET show' do

    it 'renders in non-production environments' do
      get :show
      expect(response).to be_success
    end

    it 'raises a routing error in the production environment' do
      allow(Rails).to receive(:env).and_return ( double(production?: true) )
      expect { get :show }.to raise_error(ActionController::RoutingError)
    end
  end
end
