require "spec_helper"

module Metrics
  class TestMetrics < Base
    cattr_accessor :base_scope, :metrics, :model_name

    @@model_name = "Organization"
    @@base_scope = ::Organization.where("1=1")
    @@metrics    = {
      total_sellers: @@base_scope.where(can_sell: true),
      total_buyer_only: @@base_scope.where(can_sell: false)
    }
  end
end

describe Metrics::TestMetrics do

  let!(:organization1) { create(:organization) }
  let!(:organization2) { create(:organization, can_sell: false) }

  describe "#perform" do
    before do
      Timecop.freeze(1.day.from_now)
    end

    after do
      Timecop.return
    end

    it "creates one entry per metric" do
      expect {
        described_class.perform
      }.to change {
        Metric.count
      }.from(0).to(2)
    end

    it "when a calculation is run the result is updated to take the new state into account" do

      expect {
        described_class.perform
      }.to change {
        Metric.count
      }.from(0).to(2)
      # Reminder: the metrics are calculated for the previous full day
      expect(Metric.find_by(metric_code: "total_sellers", effective_on: 1.day.ago).model_ids).to eq([organization1.id])
      expect(Metric.find_by(metric_code: "total_buyer_only", effective_on: 1.day.ago).model_ids).to eq([organization2.id])

      Timecop.freeze(1.day.from_now)
      organization1.update_attribute(:can_sell, false)
      organization2.update_attribute(:can_sell, true)
      expect {
        described_class.perform
      }.to change {
        Metric.count
      }.from(2).to(4)
      expect(Metric.find_by(metric_code: "total_sellers", effective_on: 1.day.ago).model_ids).to eq([organization2.id])
      expect(Metric.find_by(metric_code: "total_buyer_only", effective_on: 1.day.ago).model_ids).to eq([organization1.id])
    end

    context "when more than one calculation is run on the same day" do
      it "does not create a new record in the metrics table" do
        expect {
          described_class.perform
        }.to change {
          Metric.count
        }.from(0).to(2)
        expect {
          described_class.perform
        }.not_to change {
          Metric.count
        }
      end

      it "replaces the old calculation with an updated number" do
        expect {
          described_class.perform
        }.to change {
          Metric.count
        }.from(0).to(2)
        expect(Metric.find_by(metric_code: "total_sellers", effective_on: 1.day.ago).model_ids).to eq([organization1.id])
        expect(Metric.find_by(metric_code: "total_buyer_only", effective_on: 1.day.ago).model_ids).to eq([organization2.id])

        organization1.update_attribute(:can_sell, false)
        organization2.update_attribute(:can_sell, true)
        expect {
          described_class.perform
        }.not_to change {
          Metric.count
        }
        expect(Metric.find_by(metric_code: "total_sellers", effective_on: 1.day.ago).model_ids).to eq([organization2.id])
        expect(Metric.find_by(metric_code: "total_buyer_only", effective_on: 1.day.ago).model_ids).to eq([organization1.id])
      end
    end
  end
end
