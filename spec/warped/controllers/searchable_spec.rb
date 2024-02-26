# frozen_string_literal: true

RSpec.describe Warped::Controllers::Searchable, type: :controller do
  let(:scope) { double("ActiveRecord::Relation") }

  before do
    stub_const("TestModel", double("TestModel"))
    allow(TestModel).to receive(:all).and_return(scope)
    allow(Warped::Queries::Search).to receive(:call).with(scope, search_term: anything,
                                                                 model_search_scope: anything).and_return(scope)

    controller do
      include Warped::Controllers::Searchable

      def index
        _test_models = search(TestModel.all)
      end
    end
  end

  describe "MockController#index" do
    let(:params) { {} }
    subject(:request) { call_action(MockController, :index, params:) }

    context "when model_search_scope is not defined" do
      it "calls Warped::Queries::Search with correct params" do
        request
        expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: nil,
                                                                            model_search_scope: :search)
      end
    end

    context "when model_search_scope is defined" do
      before do
        MockController.searchable_by :term
      end

      context "when the search term is not present" do
        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: nil,
                                                                              model_search_scope: :term)
        end
      end

      context "when the search term is present" do
        let(:params) { { q: "John" } }

        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: "John",
                                                                              model_search_scope: :term)
        end
      end
    end

    context "when search_param is not defined" do
      context "when the search term is not present" do
        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: nil,
                                                                              model_search_scope: :search)
        end
      end

      context "when the search term is present" do
        let(:params) { { q: "John" } }

        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: "John",
                                                                              model_search_scope: :search)
        end
      end
    end

    context "when search_param is defined" do
      before do
        MockController.searchable_by :term, param: :search
      end

      context "when the search term is not present" do
        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: nil,
                                                                              model_search_scope: :term)
        end
      end

      context "when the search term is present" do
        let(:params) { { search: "John" } }

        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: "John",
                                                                              model_search_scope: :term)
        end
      end
    end
  end
end
