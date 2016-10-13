require "spec_helper"

describe CrossSellingList do

  context "validations" do
    let(:market) { create(:market) }
    # Null/not nul checks:

    describe "name" do
      it "must be present" do
        list = build(:cross_selling_list)
        list.name = nil

        expect(list).to_not be_valid
        expect(list).to have(1).error_on(:name)
      end
      
      it "is less than 255 characters" do
        list = build(:cross_selling_list)
        list.name = "a" * 256

        expect(list).to_not be_valid
        expect(list).to have(1).error_on(:name)
      end
    end

    describe "status" do
      it "must be present" do
        list = build(:cross_selling_list)
        list.status = nil

        expect(list).to_not be_valid
        expect(list).to have(1).error_on(:status)
      end

      it "is less that 255 characters" do
        list = build(:cross_selling_list)
        list.status = "a" * 256
        
        expect(list).to_not be_valid
        expect(list).to have(1).error_on(:status)
      end
    end

    describe "entity" do
      it "must be present" do
        list = build(:cross_selling_list)
        list.entity_id = nil

        expect(list).to_not be_valid
        expect(subject).to have(2).error_on(:entity_id)
      end
    end

    describe "entity type" do
      it "must be present" do
        list = build(:cross_selling_list)
        list.entity_type = nil

        expect(list).to_not be_valid
        expect(subject).to have(1).error_on(:entity_type)
      end

      it "is less than 255 characters" do
        list = build(:cross_selling_list)
        list.entity_type = "a" * 256
        
        expect(list).to_not be_valid
        expect(list).to have(1).error_on(:entity_type)
      end
    end

  end

  # KXM CrossSellingList Coverage = 49.38%, mostly due to missing tests for class methods... add them here...
  context "editing a list" do
    xit "allows name to be changed" do
    end

    xit "allows status to be changed" do
    end
  end

  context "publishing a list" do
    xit "sets the status to 'Published'" do
    end

    xit "sets the 'published_at' date" do
    end
  end

  context "cross selling list" do
    let(:publishing_list) { create(:cross_selling_list, :market_list, creator: true) }
    let(:subscribing_list) { create(:cross_selling_list, :market_list, parent_id: publishing_list, creator: false) }

    describe "#publisher?" do  
      it "is true for publishing lists" do
        expect(publishing_list.publisher?).to be true
      end

      it "is false for subscribing lists" do
        expect(subscribing_list.publisher?).to be false
      end
    end

    describe "statuses" do
      let(:new_publishing_list) { build(:cross_selling_list, :market_list, creator: true) }
      let(:new_subscribing_list) { build(:cross_selling_list, :market_list, parent_id: new_publishing_list, creator: false, status: 'Pending') }

      it "includes 'Draft' for new publishing lists" do
        expect(new_publishing_list.statuses).to include(:Draft)
      end

      it "excludes 'Inactive' for draft publishing lists" do
        new_publishing_list.save
        expect(new_publishing_list.statuses).to_not include(:Inactive)
      end

      it "excludes 'Draft' for published publishing lists" do
        new_publishing_list.save
        new_publishing_list.publish!

        expect(new_publishing_list.statuses).to_not include(:Draft)
      end

      it "excludes 'Inactive' for pending subscribing lists" do
        new_subscribing_list.save
        expect(new_subscribing_list.statuses).to_not include(:Inactive)
      end

      it "includes 'Declined' for pending subscribing lists" do
        new_subscribing_list.save
        expect(new_subscribing_list.statuses).to include(:Declined)
      end

      it "excludes 'Declined' for published subscribing lists" do
        new_subscribing_list.save
        new_subscribing_list.publish!
        expect(new_subscribing_list.statuses).to_not include(:Declined)
      end
    end
  end
end