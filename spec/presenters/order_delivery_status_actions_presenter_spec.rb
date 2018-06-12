require 'spec_helper'

describe OrderDeliveryStatusActionsPresenter do
  describe '#render' do
    let(:user) { double('User') }
    let(:order) { double('Order') }
    let(:view_context) { ActionView::Base.new }

    subject { OrderDeliveryStatusActionsPresenter.new(user, order, view_context) }

    before do
      allow(Order::DeliveryStatusPolicy).to receive(:new) { policy }
    end

    context 'when allowed to mark delivered' do
      let(:policy) { double(:mark_delivered? => true, :mark_undelivered? => false) }

      it "renders 'Mark delivered'" do
        expect(subject.render).to match(/Mark all delivered/)
      end
    end

    context 'when allowed to undo mark delivered' do
      let(:policy) { double(:mark_delivered? => false, :mark_undelivered? => true) }

      it "renders 'Undo mark delivery'" do
        expect(subject.render).to match(/Undo mark delivery/)
      end
    end

    context 'when not allowed to mark nor undo mark delivered' do
      let(:policy) { double(:mark_delivered? => false, :mark_undelivered? => false) }

      it 'renders nothing' do
        expect(subject.render).to be_nil
      end
    end
  end
end
