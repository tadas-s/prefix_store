# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CacheToolbox::FixedPrefix do
  describe '#initialize' do
    it 'raises an error if no cache store is given' do
      expect { described_class.new(prefix: 'pr') }
        .to raise_exception(ArgumentError, 'No cache store option given.')
    end

    it 'looks up cache store using `ActiveSupport::Cache.lookup_store`' do
      store = described_class.new(prefix: 'pr', store: :memory_store)

      expect(store.instance_variable_get(:@store))
        .to be_a ActiveSupport::Cache::MemoryStore
    end

    it 'accepts a cache object as store option' do
      store = described_class.new(
        prefix: 'pr',
        store: ActiveSupport::Cache.lookup_store(:memory_store)
      )

      expect(store.instance_variable_get(:@store))
        .to be_a ActiveSupport::Cache::MemoryStore
    end

    it 'raises an error if no cache key prefix is given' do
      expect { described_class.new(store: :memory_store) }
        .to raise_exception(ArgumentError, 'No key prefix option given.')
    end

    it 'stringifies symbol key prefix' do
      store = described_class.new(prefix: :pr, store: :memory_store)

      expect(store.instance_variable_get(:@prefix)).to eq 'pr-'
    end

    it 'stringifies numeric key prefix' do
      store = described_class.new(prefix: 123, store: :memory_store)

      expect(store.instance_variable_get(:@prefix)).to eq '123-'
    end
  end

  describe '#read' do
    subject(:cache) { described_class.new(store: parent, prefix: 'pr') }

    let(:parent) { ActiveSupport::Cache.lookup_store(:memory_store) }

    it 'reads from parent cache store with a prefixed key' do
      parent.write('pr-foo', 'bar')
      expect(cache.read('foo')).to eq 'bar'
    end
  end

  describe '#write' do
    subject(:cache) { described_class.new(store: parent, prefix: 'pr') }

    let(:parent) { ActiveSupport::Cache.lookup_store(:memory_store) }

    it 'writes to parent cache store with a prefixed key' do
      cache.write('baz', 'woo')
      expect(parent.read('pr-baz')).to eq 'woo'
    end
  end

  describe '#delete' do
    subject(:cache) { described_class.new(store: parent, prefix: 'pr') }

    let(:parent) { ActiveSupport::Cache.lookup_store(:memory_store) }

    it 'deletes prefixed key from parent cache' do
      parent.write('pr-the_key', 'the_value')
      cache.delete('the_key')
      expect(parent.read('pr-the_key')).to be_nil
    end
  end
end
