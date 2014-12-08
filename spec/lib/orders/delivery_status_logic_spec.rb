describe Orders::DeliveryStatusLogic do
  subject(:logic) { described_class }

  describe ".overall_status" do

    context "is 'delivered'" do
      scenario "when all items are 'delivered'" do
        expect(logic.overall_status(%w{delivered})).to eq "delivered"
        expect(logic.overall_status(%w{delivered delivered})).to eq "delivered"
        expect(logic.overall_status(%w{delivered delivered})).to eq "delivered"
      end

      scenario "when all items are 'delivered' other than one or more 'canceled'" do
        expect(logic.overall_status(%w{delivered canceled})).to eq "delivered"
        expect(logic.overall_status(%w{canceled delivered canceled})).to eq "delivered"
      end
    end

    context "is 'pending'" do
      scenario "when all items are 'pending'" do
        expect(logic.overall_status(%w{pending})).to eq "pending"
        expect(logic.overall_status(%w{pending pending})).to eq "pending"
        expect(logic.overall_status(%w{pending pending})).to eq "pending"
      end

      scenario "when all items are 'pending' other than one or more 'canceled'" do
        expect(logic.overall_status(%w{pending canceled})).to eq "pending"
        expect(logic.overall_status(%w{canceled pending canceled})).to eq "pending"
      end
    end

    context "is 'canceled'" do
      scenario "when all items are 'canceled'" do
        expect(logic.overall_status(%w{canceled})).to eq "canceled"
        expect(logic.overall_status(%w{canceled canceled})).to eq "canceled"
      end
    end

    context "is 'partially delivered'" do
      scenario "when some items are 'delivered' and some 'pending'" do
        expect(logic.overall_status(%w{pending delivered})).to eq "partially delivered"
        expect(logic.overall_status(%w{delivered pending})).to eq "partially delivered"
        expect(logic.overall_status(%w{delivered pending delivered pending})).to eq "partially delivered"
      end

      scenario "when some items are 'delivered' and some 'pending', other than one or more 'canceled'" do
        expect(logic.overall_status(%w{pending canceled delivered})).to eq "partially delivered"
        expect(logic.overall_status(%w{delivered pending canceled canceled})).to eq "partially delivered"
        expect(logic.overall_status(%w{canceled delivered pending canceled delivered pending})).to eq "partially delivered"
      end
    end

    context "is 'contested'" do
      scenario "when at least one item is 'contested'" do
        expect(logic.overall_status(%w{contested})).to eq "contested"
        expect(logic.overall_status(%w{delivered delivered contested})).to eq "contested"
        expect(logic.overall_status(%w{delivered canceled delivered contested canceled})).to eq "contested"
        expect(logic.overall_status(%w{canceled pending contested pending canceled})).to eq "contested"
      end

      context "is 'contested, partially delivered'" do
        scenario "when at least one item is 'contested' AND at least one is 'delivered' AND at least one is 'pending'" do
          expect(logic.overall_status(%w{delivered contested pending})).to eq "contested, partially delivered"
          expect(logic.overall_status(%w{delivered delivered contested canceled pending})).to eq "contested, partially delivered"
        end
      end
    end

    context "disregards unrecognized statuses" do
      scenario "when strange status strings mixed with knowns" do
        expect(logic.overall_status(%w{canceled such stat delivered wow canceled})).to eq "delivered"
        expect(logic.overall_status(%w{canceled much pending canceled})).to eq "pending"
        expect(logic.overall_status(%w{canceled very canceled})).to eq "canceled"
        expect(logic.overall_status(%w{delivered pending whoa canceled canceled})).to eq "partially delivered"
        expect(logic.overall_status(%w{canceled pending very contested pending such weather canceled})).to eq "contested"
        expect(logic.overall_status(%w{delivered much delivered contested canceled pending})).to eq "contested, partially delivered"
      end
    end
  end

  describe ".overall_status_for_order" do
    let!(:order) { 
      Order.new(items: [
                OrderItem.new(delivery_status: 'pending'),
                OrderItem.new(delivery_status: 'delivered')])
    }
    it "aggregates the order items' delivery statuses" do
      expect(logic.overall_status_for_order(order)).to eq "partially delivered"
    end
  end

  describe ".human_readable" do
    it "titleizes the input" do
      expect(logic.human_readable("one for the road".to_sym)).to eq "One For The Road"
    end
  end

end
