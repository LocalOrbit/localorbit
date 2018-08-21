require 'spec_helper'

describe OrganizationDecorator do
  let(:supplier_org) { build(:organization, :seller, :decorated) }
  let(:buyer_org)    { build(:organization, :buyer, :decorated) }
  let(:market_org)   { build(:organization, :market, :decorated) }
  let(:admin_org)    { build(:organization, :admin, :decorated) }

  describe '#human_org_type' do
    it 'is valid' do
      expect(supplier_org.human_org_type).to eq('supplier')
      expect(buyer_org.human_org_type).to eq('buyer')
      expect(market_org.human_org_type).to eq('market')
      expect(admin_org.human_org_type).to eq('admin')
    end
  end
end
