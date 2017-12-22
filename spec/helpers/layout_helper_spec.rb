require 'spec_helper'

RSpec.describe LayoutHelper, :type => :helper do
  describe '.classes' do
    context 'with a string arg' do
      it 'returns the string' do
        expect(classes('foo')).to eq 'foo'
      end
    end

    context 'with a mix of strings and hash args' do
      it 'returns strings as is and keys of hashes only if values are truthy' do
        expect(classes('foo', bar: false, baz: 1)).to eq('foo baz')
        expect(classes({foo: :bar}, 'hey', {bar: false}, {baz: 1})).to eq 'foo hey baz'
      end
    end
  end
end
