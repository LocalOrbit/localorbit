require 'spec_helper'

describe OrderDeliveryStatusActionsPresenter do
  describe "#render" do
    let(:user) { double("User") }
    let(:order) { double("Order") }
    let(:view_context) { ActionView::Base.new }

    let(:presenter) { OrderDeliveryStatusActionsPresenter.new(user, order, view_context) }

    before do
      allow_any_instance_of(Order::DeliveryStatusPolicy).to receive(:mark_delivered?) { allow_mark_delivered }
      allow_any_instance_of(Order::DeliveryStatusPolicy).to receive(:mark_undelivered?) { allow_undo_mark_delivered }
    end

    context "when allowed to mark delivered" do
      let(:allow_mark_delivered) { true }
      let(:allow_undo_mark_delivered) { false }

      it "renders 'Mark delivered'" do
        expect(presenter.render).to match(/Mark all delivered/)
      end
    end

    context "when allowed to undo mark delivered" do
      let(:allow_mark_delivered) { false }
      let(:allow_undo_mark_delivered) { true }

      it "renders 'Undo mark delivery'" do
        expect(presenter.render).to match(/Undo mark delivery/)
      end
    end

    context "when not allowed to mark nor undo mark delivered" do
      let(:allow_mark_delivered) { false }
      let(:allow_undo_mark_delivered) { false }

      it "renders nothing" do
        expect(presenter.render).to be_nil
      end
    end
  end
end
