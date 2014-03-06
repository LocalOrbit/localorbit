require 'spec_helper'

describe Location do
  describe "soft_delete" do
    subject { create(:location) }
    it_behaves_like "a soft deleted model"
  end
end
