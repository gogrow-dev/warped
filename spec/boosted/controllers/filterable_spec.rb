# frozen_string_literal: true

require "spec_helper"

require "boosted/controllers/filterable"

RSpec.describe Boosted::Controllers::Filterable do
  let(:dummy_controller) { Class.new { include Boosted::Controllers::Filterable } }
  let(:dummy_instance) { dummy_controller.new }
  let(:dummy_scope) { double }

  before do
    allow(dummy_instance).to receive(:request) {
                               double(parameters: { "name_eq" => "John", "age_gteq" => "20",
                                                    "without_operator" => "foo", "not_allowed_like" => "bar" })
                             }
  end

  describe "#filter" do
    context "when filterable_by is empty" do
      it "returns the dummy_scope" do
        allow(dummy_instance).to receive(:filterable_by) { [] }
        expect(dummy_instance.filter(dummy_scope)).to eq(dummy_scope)
      end
    end

    context "when filterable_by is not empty" do
      before do
        allow(dummy_instance).to receive(:filterable_by) { %w[name age] }
        allow(dummy_scope).to receive(:where) { dummy_scope }
      end

      it "filters the dummy_scope by the provided filters" do
        expect(dummy_scope).to receive(:where).with("name = (?)", "John")
        expect(dummy_scope).to receive(:where).with("age >= (?)", "20")
        dummy_instance.filter(dummy_scope)
      end

      it "returns the filtered dummy_scope" do
        expect(dummy_instance.filter(dummy_scope)).to eq(dummy_scope)
      end
    end
  end

  describe "#filtering_params" do
    it "returns a hash of the parameters that are filterable" do
      allow(dummy_instance).to receive(:filterable_by) { %w[name age] }
      expect(dummy_instance.send(:filtering_params)).to eq({ "name_eq" => "John", "age_gteq" => "20" })
    end
  end

  describe "#contains_operator?" do
    let(:operator) { "_eq" }

    it "returns true if the key contains an operator" do
      expect(dummy_instance.send(:contains_operator?, "name#{operator}")).to eq(true)
    end

    it "returns false if the key does not contain an operator" do
      expect(dummy_instance.send(:contains_operator?, "name")).to eq(false)
    end
  end

  describe "#extract_param" do
    let(:operator) { "_eq" }

    it "extracts the parameter name from the key" do
      expect(dummy_instance.send(:extract_param, "name#{operator}", true)).to eq("name")
    end

    it "returns the key if it does not contain an operator" do
      expect(dummy_instance.send(:extract_param, "name", false)).to eq("name")
    end
  end

  describe "#extract_operator" do
    let(:operator) { "_eq" }

    it "extracts the operator from the key" do
      expect(dummy_instance.send(:extract_operator, "name#{operator}", true)).to eq("eq")
    end

    it "returns nil if the key does not contain an operator" do
      expect(dummy_instance.send(:extract_operator, "name", false)).to be_nil
    end
  end
end
