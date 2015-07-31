require 'spec_helper'

describe ProductImport::Transforms::MoveNonCanonicalFieldsToSourceData do

  it "moves noncanonical fields to the source_data field" do
    data = [
      {
        'product_code' => 'abc123',
        'name' => 'foo',
        'category' => 'Rice',
        'price' => '1.423',
        'unit' => 'lbs',

        'short_description' => "short",
        'long_description' => "Looooooooooong",

        "foo" => "bar",
        "hello" => "world"
      },
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(1)

    expect(successes[0]).to eq({
      'product_code' => 'abc123',
      'name' => 'foo',
      'category' => 'Rice',
      'price' => '1.423',
      'unit' => 'lbs',

      'short_description' => "short",
      'long_description' => "Looooooooooong",

      'source_data' => {
        "foo" => "bar",
        "hello" => "world"
      }
    })

    expect(failures.size).to eq(0)
  end

  it "doesn't clobber values in the existing source_data" do
    data = [
      {
        'product_code' => 'abc123',
        'name' => 'foo',
        'category' => 'Rice',
        'price' => '1.423',
        'unit' => 'lbs',

        'short_description' => "short",
        'long_description' => "Looooooooooong",

        'source_data' => {
          'foo' => 'baz'
        },

        "foo" => "bar",
        "hello" => "world"
      },
    ]

    successes, failures = subject.transform_enum(data)

    expect(successes.size).to eq(1)

    expect(successes[0]).to eq({
      'product_code' => 'abc123',
      'name' => 'foo',
      'category' => 'Rice',
      'price' => '1.423',
      'unit' => 'lbs',

      'short_description' => "short",
      'long_description' => "Looooooooooong",

      'source_data' => {
        # refused to update existing foo.
        "foo" => "baz",
        "hello" => "world"
      }
    })

    expect(failures.size).to eq(0)
  end

end
