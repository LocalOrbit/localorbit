require 'spec_helper'

RSpec.describe Users::SessionsController, type: :controller do

  describe 'POST create' do

    # CSRF tokens become stale when a login and logout happens in another tab
    context 'when logging in from tab with a stale CSRF token' do
      let(:user) { build_stubbed(:user) }

      before do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        def controller.create
          raise ActionController::InvalidAuthenticityToken
        end
      end

      it 'redirects back to the sign in page' do
        post :create, user: {email: user.email, password: user.password}
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'sets a helpful flash message' do
        post :create, user: {email: user.email, password: user.password}
        expect(flash[:notice ]).to eq('Sorry, please try again')
      end

    end

  end

end
