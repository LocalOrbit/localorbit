require 'spec_helper'

describe Admin::MarketsController do
  describe "#index" do
    it_behaves_like "admin only action", lambda { get :index }
  end

  describe "#new" do
    it_behaves_like "admin only action", lambda { get :new }
  end
end
