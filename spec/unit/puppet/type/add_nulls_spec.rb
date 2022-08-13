require 'puppetlabs_spec_helper/module_spec_helper'

describe Puppet::Type.type(:node_group).provider(:https) do

  let(:resource) do
    Puppet::Type.type(:node_group).new(
      :name                 => 'testnodegroup',
      :override_environment => 'false',
      :rule                 => ['or', ['=', 'name', 'master.puppetlabs.vm']],
      :environment          => 'testenvironment',
      :classes              => {},
      :provider             => 'https',
      :variables            => {},
      :description          => "Sample message",
    )
  end

  let(:provider) do
    provider = described_class.new
    provider.resource = resource
    provider
  end

  let(:no_val) { {} }
  let(:nil_val) { { "key" => nil } }
  let(:true_val) { { "key" => true } }
  let(:false_val) { { "key" => false } }
  let(:old_string_val) { { "key" => "oldstring" } }
  let(:string_val) { { "key" => "stringvalue" } }
  let(:zero_val) { { "key" => 0 } }
  let(:numeric_val) { { "key" => 59 } }

  describe ".add_nulls" do
    context "if we change one value from true to false in a hash of multiple keys" do
      let(:old_hash) { { "firstkey" => true, "secondkey" => true, "thirdkey" => "somestring", "fourthkey" => 59 } }
      let(:new_hash) { { "firstkey" => true, "secondkey" => false, "thirdkey" => "somestring", "fourthkey" => 59 } }
      let(:expected_hash) { { "firstkey" => true, "secondkey" => false, "thirdkey" => "somestring", "fourthkey" => 59 } }
      it "is expected to return a hash with a false value" do
        expect(provider.send(:add_nulls, old_hash, new_hash)).to eq(expected_hash)
      end
    end
    context "if we set a new key to true" do
      it "is expected to return a hash with a true value" do
        expect(provider.send(:add_nulls, no_val, true_val)).to eq(true_val)
      end
    end
    context "if we set a new key to false" do
      it "is expected to return a hash with a false value" do
        expect(provider.send(:add_nulls, no_val, false_val)).to eq(false_val)
      end
    end
    context "if we set a new key to zero" do
      it "is expected to return a hash with a zero" do
        expect(provider.send(:add_nulls, no_val, zero_val)).to eq(zero_val)
      end
    end
    context "if we set a new key to a string" do
      it "is expected to return a hash with a true value" do
        expect(provider.send(:add_nulls, no_val, string_val)).to eq(string_val)
      end
    end
    context "if we set a new key to a non-zero number" do
      it "is expected to return a hash the same non-zero number" do
        expect(provider.send(:add_nulls, no_val, numeric_val)).to eq(numeric_val)
      end
    end
    context "if we change a value from true to false" do
      it "is expected to return a hash with a false value" do
        expect(provider.send(:add_nulls, true_val, false_val)).to eq(false_val)
      end
    end
    context "if we change a value from nil to false" do
      it "is expected to return a hash with a false value" do
        expect(provider.send(:add_nulls, nil_val, false_val)).to eq(false_val)
      end
    end
    context "if we change a value from 0 to false" do
      it "is expected to return a hash with a false value" do
        expect(provider.send(:add_nulls, zero_val, false_val)).to eq(false_val)
      end
    end
    context "if we change a value from a string to false" do
      it "is expected to return a hash with a false value" do
        expect(provider.send(:add_nulls, string_val, false_val)).to eq(false_val)
      end
    end
    context "if we change a value from false to true" do
      it "is expected to return a hash with a true value" do
        expect(provider.send(:add_nulls, false_val, true_val)).to eq(true_val)
      end
    end
    context "if we change a value from nil to true" do
      it "is expected to return a hash with a true value" do
        expect(provider.send(:add_nulls, nil_val, true_val)).to eq(true_val)
      end
    end
    context "if we change a value from true to true" do
      it "is expected to return a hash with a true value" do
        expect(provider.send(:add_nulls, true_val, true_val)).to eq(true_val)
      end
    end
    context "if we change a value from one string to another string" do
      it "is expected to return a hash with a true value" do
        expect(provider.send(:add_nulls, old_string_val, string_val)).to eq(string_val)
      end
    end
  end

end
