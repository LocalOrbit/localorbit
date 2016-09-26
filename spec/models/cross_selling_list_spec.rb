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
end