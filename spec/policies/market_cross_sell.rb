describe MarketCrossSellingPolicy do

  permissions :index? do
    it "denies access if cross selling not enabled" do
      expect(subject).not_to permit(Market.new(admin: false), Post.new(published: true))
    end
  end
end