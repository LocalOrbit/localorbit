require "spec_helper"

describe EventTracker do
  before do
    # We need to observe EventTracker's interactions with Intercom in this spec:
    EventTracker.capture_events = false
  end

  after do
    EventTracker.capture_events = true
  end

  describe "#track_event_for_user" do
    context "using a stubbed HTTP api" do
      @user = OpenStruct.new(email: "mary+testing@example.com")
      VCR.use_cassette("intercom/post_event", :allow_unused_http_interactions=>false) do
        EventTracker.track_event_for_user(@user, "viewed_order", {order: {url:"/admin/orders/1", value:"LO-14-MARKET1-0000001"}, email: "mary+testing@example.com"})
      end
    end
  end

  describe "#find_or_create_user!" do
    before do
      @user = OpenStruct.new(email: "foo")
    end

    it "returns a user if it already exists in Intercom" do
      expect(Intercom::User).to receive(:find).with(email: @user.email).and_return("foo")
      intercom_user = EventTracker.find_or_create_user!(@user)
      expect(intercom_user).to eq "foo"
    end

    it "creates a user if it cannot be found" do
      expect(Intercom::User).to receive(:find).with(email: @user.email).and_raise(Intercom::ResourceNotFound.new(nil))
      expect(Intercom::User).to receive(:create).with(email: @user.email).and_return("foo")
      intercom_user = EventTracker.find_or_create_user!(@user)
      expect(intercom_user).to eq "foo"
    end

    # ?? maybe #track_event_for_user  
    context "using a stubbed HTTP api" do
      @user = OpenStruct.new(email: "mary2+testing@example.com")
      VCR.use_cassette("intercom/create_user", :allow_unused_http_interactions=>false) do
        EventTracker.find_or_create_user!(@user)
      end
    end
  end


end
