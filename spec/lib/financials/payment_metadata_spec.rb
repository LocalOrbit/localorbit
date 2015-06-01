require 'spec_helper'

describe Financials::PaymentMetadata do
  subject { described_class }

  let(:configs) { Financials::PaymentMetadata::Configs }

  describe ".payment_config_for" do

    it "returns the payment config info for each of the defined Configs" do
      configs.keys.each do |k|
        expect(subject.payment_config_for(k)).to eq configs[k]
      end
      # by invoking payment_config_for for each member of Configs, we're also exercising schema correctness for each
    end

    it "raises for bad keys" do
      expect { subject.payment_config_for(:zaphon_beeblebroz) }.to raise_error(/no payment metadata/i)
    end
  end
end
