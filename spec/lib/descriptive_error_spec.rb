require 'spec_helper'

describe DescriptiveError do

  let(:data) { {some:"data"} }

  it "can be built with a message and some data" do
    error = DescriptiveError.new(message: "The error", data: data)
    expect(error.data).to be data
    expect(error.message).to eq %|The error: {"some":"data"}|
    expect(error.backtrace).to be nil
  end

  it "can be built with no args" do
    error = DescriptiveError.new
    expect(error.data).to be nil
    expect(error.message).to eq %|Error|
    expect(error.backtrace).to be nil
  end

  it "can be built with a root" do
    root = nil
    begin
      raise "Boom!"
    rescue Exception => e
      root = e
    end

    error = DescriptiveError.new(message: "The error", data: data, root: root)
    expect(error.data).to be data
    expect(error.message).to eq %|The error: {"some":"data"}|
    expect(error.backtrace).to eq root.backtrace
  end
end
