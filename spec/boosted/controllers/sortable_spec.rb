require "spec_helper"

require "boosted/controllers/sortable"

RSpec.describe Boosted::Controllers::Sortable do
  let(:dummy_controller) { Class.new { include Boosted::Controllers::Sortable } }
  let(:dummy_instance) { dummy_controller.new }
  let(:dummy_scope) { double("DummyScope") }

  before do
    allow(dummy_instance).to receive(:request) {
                               double(parameters: { "title_sort" => "asc", "author_sort" => "desc" })
                             }
  end

  describe ".sortable_by" do
    context "when sortable_by is called with valid arguments" do
      it "defines the sortable_by method" do
        dummy_controller.sortable_by(:title, :content)
        expect(dummy_controller.method_defined?(:sortable_by)).to be_truthy
      end

      it "returns an array of string arguments" do
        result = dummy_controller.sortable_by(:title, :content)
        expect(result).to contain_exactly("title", "content")
      end
    end

    context "when sortable_by is called multiple times" do
      it "does not redefine the sortable_by method" do
        dummy_controller.sortable_by(:title)
        dummy_controller.sortable_by(:content)
        expect(dummy_controller.method_defined?(:sortable_by)).to be_truthy
      end
    end
  end

  describe "#sort" do
    it "returns the scope unchanged if no sorting params are present" do
      allow(dummy_instance).to receive(:sorting_params).and_return({})
      expect(dummy_instance.sort(dummy_scope)).to eq(dummy_scope)
    end

    it "orders the scope based on the sorting params" do
      dummy_controller.sortable_by(:title, :content)
      allow(dummy_instance).to receive(:sorting_params).and_return({ "title_sort" => "asc" })

      expect(dummy_scope).to receive(:order).with("title" => :asc).and_return(dummy_scope)
      dummy_instance.sort(dummy_scope)
    end
  end

  describe "#sorting_params" do
    it "returns an empty hash if no sortable params are present" do
      allow(dummy_instance).to receive(:request).and_return(double("Request", parameters: {}))
      expect(dummy_instance.sorting_params).to be_empty
    end

    it "returns a hash of sortable params" do
      allow(dummy_instance).to receive(:sortable_by).and_return(%w[title content])
      allow(dummy_instance).to receive(:request).and_return(double("Request", parameters: {
                                                                     "title_sort" => "asc",
                                                                     "author_sort" => "desc"
                                                                   }))

      expect(dummy_instance.sorting_params).to eq({ "title_sort" => "asc" })
    end
  end
end
