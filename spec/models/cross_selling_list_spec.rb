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

  context "cross selling list" do
    let(:publishing_list) { create(:cross_selling_list, :market_list, creator: true) }
    let(:subscribing_list) { create(:cross_selling_list, :market_list, parent_id: publishing_list.id, creator: false) }
    let(:subscribing_list2) { create(:cross_selling_list, :market_list, parent_id: publishing_list.id, creator: false) }

    describe ".show_product_management_button?" do
      it "is true for publishing lists" do
        expect(publishing_list.show_product_management_button?).to be true
      end

      it "is false for subscribing lists with no products" do
        expect(subscribing_list.show_product_management_button?).to be false
      end

      it "is true for subscribing lists with products" do
        subscribing_list2.cross_selling_list_products.create
        expect(subscribing_list2.show_product_management_button?).to be true
      end
    end

    describe ".publisher?" do
      it "is true for publishing lists" do
        expect(publishing_list.publisher?).to be true
      end

      it "is false for subscribing lists" do
        expect(subscribing_list.publisher?).to be false
      end
    end

    describe ".statuses" do
      let(:new_publishing_list) { build(:cross_selling_list, :market_list, creator: true) }
      let(:new_subscribing_list) { build(:cross_selling_list, :market_list, parent_id: new_publishing_list.id, creator: false, status: 'Pending') }

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

      it "includes required items for pending subscribing lists" do
        new_subscribing_list.save
        expect(new_subscribing_list.statuses).to include(:Declined)
        expect(new_subscribing_list.statuses).to include(:Pending)
      end

      it "excludes erroneous items for published subscribing lists" do
        new_subscribing_list.save
        new_subscribing_list.publish!
        expect(new_subscribing_list.statuses).to_not include(:Declined)
        expect(new_subscribing_list.statuses).to_not include(:Pending)
      end
    end

    describe ".manage_status" do
      let(:subscribing_list) { create(:cross_selling_list, :market_list, parent_id: publishing_list.id, creator: false, status: "Published") }

      it "properly revokes list" do
        subscribing_list.manage_status("Inactive")
        expect(subscribing_list.status).to eq "Revoked"
      end

      it "properly updates status to pending for revoked lists" do
        subscribing_list.update_column(:status, "Revoked")
        subscribing_list.manage_status("Published")
        expect(subscribing_list.status).to eq "Pending"
      end

      it "properly updates status to pending for draft lists" do
        subscribing_list.update_column(:status, "Draft")
        subscribing_list.manage_status("Published")
        expect(subscribing_list.status).to eq "Pending"
      end
    end

    describe ".manage_dates" do
      it "sets revocation date" do
        expect(subscribing_list.deleted_at).to eq nil
        subscribing_list.manage_dates("Revoked")
        expect(subscribing_list.deleted_at).to_not eq nil
      end

      it "sets publication date" do
        expect(subscribing_list.published_at).to eq nil
        subscribing_list.manage_dates("Published")
        expect(subscribing_list.published_at).to_not eq nil
      end

      it "unsets deleted_at" do
        subscribing_list.manage_dates("Revoked")
        expect(subscribing_list.deleted_at).to_not eq nil
        subscribing_list.manage_dates("Declined")
        expect(subscribing_list.deleted_at).to eq nil
      end
    end

    describe ".translate_status" do
      let(:publishing_list) { create(:cross_selling_list, :market_list, creator: true, status: "Inactive") }

      context "publisher list" do
        it "returns publisher list status unchanged" do
          expect(publishing_list.translate_status(publishing_list.status)).to eq publishing_list.status
        end
      end

      context "subscriber list" do
        it "translates 'Published'" do
          expect(subscribing_list.translate_status("Published")).to eq "Active"
        end

        it "translates 'Draft'" do
          expect(subscribing_list.translate_status("Draft")).to eq "Unreleased"
        end

        it "translates 'Revoked'" do
          expect(subscribing_list.translate_status("Revoked")).to eq "Deactivated by Publisher"
        end
      end
    end

    describe ".subscriber?" do
      it "returns false for publisher lists" do
        expect(publishing_list.subscriber?).to eq false
      end

      it "returns true for subscriber lists" do
        expect(subscribing_list.subscriber?).to eq true
      end
    end

    describe ".published?" do
      it "returns true for published lists" do
        publishing_list.publish!

        expect(publishing_list.published?).to eq true
      end

      it "returns false for unpublished lists" do
        expect(publishing_list.published?).to eq false
      end

      it "returns false for future-published lists" do
        publishing_list.publish!(Time.current + 7.days)

        expect(publishing_list.published?).to eq false
      end
    end

    describe ".publish!" do
      let(:publication_date) { Time.current + 7.days }

      it "publishes the list" do
        publishing_list.publish!(publication_date)

        expect(publishing_list.published_at).to eq publication_date
        expect(publishing_list.status).to eq "Published"
      end
    end

    describe ".revoke!" do
      it "revokes the list" do
        subscribing_list.publish!
        subscribing_list.revoke!

        expect(subscribing_list.status).to eq "Revoked"
        expect(subscribing_list.deleted_at).to be_within(5.seconds).of(Time.now)
      end
    end

    describe ".unpublish!" do
      it "unpublishes the list with the default status" do
        subscribing_list.publish!
        subscribing_list.unpublish!

        expect(subscribing_list.status).to eq "Unpublished"
        expect(subscribing_list.published_at).to eq nil
      end

      it "unpublishes the list with a supplied status" do
        subscribing_list.publish!
        subscribing_list.unpublish!("Hoo-DANG")

        expect(subscribing_list.status).to eq "Hoo-DANG"
        expect(subscribing_list.published_at).to eq nil
      end
    end

    describe ".pending?" do
      it "returns true for pending lists" do
        subscribing_list.update_column(:status, "Pending")

        expect(subscribing_list.pending?).to eq true
      end

      it "returns false for non-pending lists" do
        subscribing_list.revoke!

        expect(subscribing_list.pending?).to eq false
      end
    end

    describe ".draft?" do
      it "returns true for draft lists" do
        subscribing_list.update_column(:status, "Draft")

        expect(subscribing_list.draft?).to eq true
      end

      it "returns false for non-draft lists" do
        subscribing_list.revoke!

        expect(subscribing_list.draft?).to eq false
      end
    end

    describe ".locked?" do
      it "returns true for revoked lists" do
        subscribing_list.revoke!

        expect(subscribing_list.locked?).to eq true
      end

      it "returns false for non-revoked lists" do
        subscribing_list.publish!

        expect(subscribing_list.locked?).to eq false
      end
    end

    describe ".subscribers_list" do
      let(:other_publishing_list) { create(:cross_selling_list, :market_list, creator: true) }
      let(:other_subscribing_list) { create(:cross_selling_list, :market_list, parent_id: other_publishing_list.id, creator: false) }

      it "returns the list of subscribers" do
        publishing_list.publish!
        subscribing_list.publish!

        expect(publishing_list.subscribers_list).to be_an_instance_of(String)
        expect(publishing_list.subscribers_list).to include(subscribing_list.entity.name)
      end

      it "excludes non-subscribers" do
        publishing_list.publish!
        subscribing_list.publish!
        other_publishing_list.publish!
        other_subscribing_list.publish!

        expect(publishing_list.subscribers_list).to be_an_instance_of(String)
        expect(publishing_list.subscribers_list).to_not include(other_subscribing_list.entity.name)
      end
    end

    describe ".display_subscribers?" do
      let(:new_publishing_list) { build(:cross_selling_list, :market_list, creator: true) }

      it "displays subscribers for publishing lists" do
        expect(publishing_list.display_subscribers?).to eq true
      end

      it "displays subscribers for unsaved new lists" do
        expect(new_publishing_list.display_subscribers?).to eq true
      end

      it "does not display subscribers for subscribing lists" do
        expect(subscribing_list.display_subscribers?).to eq false
      end
    end

    describe ".display_product_overview?" do
      it "displays product overview for publishing lists" do
        expect(publishing_list.display_product_overview?).to eq true
      end

      it "displays product overview for approved lists" do
        subscribing_list.publish!

        expect(subscribing_list.display_product_overview?).to eq true

        subscribing_list.update_column(:status, "Inactive")
        expect(subscribing_list.display_product_overview?).to eq true
      end

      it "suppresses product overview for unapproved lists" do
        expect(subscribing_list.display_product_overview?).to eq false

        subscribing_list.update_column(:status, "Declined")
        expect(subscribing_list.display_product_overview?).to eq false

        subscribing_list.update_column(:status, "Revoked")
        expect(subscribing_list.display_product_overview?).to eq false
      end
    end
  end
end
