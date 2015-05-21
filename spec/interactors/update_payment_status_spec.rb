require "spec_helper"

describe UpdatePaymentStatus do
  include_context "the mini market"


  before do
    @payments = []
    tabulate_with_index(3, [
        :payment_provider,    :status, :balanced_uri,
                'balanced', 'pending',      '/uri-1',
                'balanced', 'pending',      '/uri-2',
                'balanced', 'pending',      '/uri-3',
                'balanced',    'paid',      '/uri-4',
                'balanced',    'paid',      '/uri-5',
                'balanced',  'failed',      '/uri-6',
                'balanced',  'failed',      '/uri-7',
                  'stripe', 'pending',      '/uri-8',
                  'stripe',    'paid',      '/uri-9',
                  'stripe',  'failed',     '/uri-10',
                'balanced', 'pending',           nil,
                'balanced',    'paid',           nil,
                'balanced',  'failed',           nil,
                  'stripe', 'pending',           nil,
                  'stripe',    'paid',           nil,
                  'stripe',  'failed',           nil,
    ]) do |row, index|
      @payments << create(:payment, row)
    end
  end

  def tabulate_with_index(columns, data, &block)
    index = 0
    tabulate(columns, data) do |row|
      block.call(row, index)
      index += 1
    end
  end

  def verify_payments(table)
    tabulate_with_index(3, table) do |row, index|
      p = @payments[index].reload
      row.each do |(key, value)|
        expect(p.send(key)).to eq(value)
      end
    end
  end

  it "translates balanced transaction statuses and stores them on corresponding pending payments" do
    Debit = Struct.new(:status)

    verify_payments [
         :payment_provider,   :status, :balanced_uri,
                'balanced', 'pending',     '/uri-1',
                'balanced', 'pending',     '/uri-2',
                'balanced', 'pending',     '/uri-3',
                'balanced',    'paid',     '/uri-4',
                'balanced',    'paid',     '/uri-5',
                'balanced',  'failed',     '/uri-6',
                'balanced',  'failed',     '/uri-7',
                  'stripe', 'pending',     '/uri-8',
                  'stripe',    'paid',     '/uri-9',
                  'stripe',  'failed',    '/uri-10',
                'balanced', 'pending',          nil,
                'balanced',    'paid',          nil,
                'balanced',  'failed',          nil,
                  'stripe', 'pending',          nil,
                  'stripe',    'paid',          nil,
                  'stripe',  'failed',          nil,
    ]

    @payments.first.orders << create(:order, payment_status: 'unpaid')
    @payments.first.orders << create(:order, payment_status: 'unpaid')

    url_to_debits =  {
      '/uri-1' => Debit.new("succeeded"),
      '/uri-2' => Debit.new("paid"),
      '/uri-3' => Debit.new("failed"),
    }
    expect(Balanced::Transaction).to receive(:find) { |url|
      url_to_debits[url]  
    }.exactly(3).times

    UpdatePaymentStatus.perform

    expect(@payments.first.orders[0].payment_status).to eq('paid')
    expect(@payments.first.orders[1].payment_status).to eq('paid')

    verify_payments [
         :payment_provider,   :status, :balanced_uri,
                'balanced',    'paid',     '/uri-1',
                'balanced',    'paid',     '/uri-2',
                'balanced',  'failed',     '/uri-3',
                'balanced',    'paid',     '/uri-4',
                'balanced',    'paid',     '/uri-5',
                'balanced',  'failed',     '/uri-6',
                'balanced',  'failed',     '/uri-7',
                  'stripe', 'pending',     '/uri-8',
                  'stripe',    'paid',     '/uri-9',
                  'stripe',  'failed',    '/uri-10',
                'balanced', 'pending',          nil,
                'balanced',    'paid',          nil,
                'balanced',  'failed',          nil,
                  'stripe', 'pending',          nil,
                  'stripe',    'paid',          nil,
                  'stripe',  'failed',          nil,
    ]
  end
end
