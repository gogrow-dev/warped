# frozen_string_literal: true

RSpec.describe Warped::Queries::Search do
  describe "#call" do
    subject(:search) { described_class.call(scope, search_term:, model_search_scope:) }

    let(:scope) { double(:scope, klass: "User") }
    let(:search_term) { "foo" }
    let(:model_search_scope) { :search }

    context "when the scope responds to the model search scope" do
      before do
        allow(scope).to receive(:respond_to?).with(model_search_scope).and_return(true)
      end

      context "when the search term is blank" do
        let(:search_term) { "" }

        it "does not call the model search scope" do
          expect(scope).not_to receive(:search)
          search
        end
      end

      context "when the search term is not blank" do
        let(:search_term) { "foo" }

        it "calls the model search scope" do
          expect(scope).to receive(:search).with(search_term)
          search
        end
      end
    end

    context "when the scope does not respond to the model search scope" do
      it "raises an ArgumentError" do
        expect { search }.to raise_error(ArgumentError).with_message(
          "#{scope.klass} does not respond to #{model_search_scope}"
        )
      end
    end
  end
end
