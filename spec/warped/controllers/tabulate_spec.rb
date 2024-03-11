# frozen_string_literal: true

RSpec.describe Warped::Controllers::Tabulatable, type: :controller do
  let(:scope) { double("ActiveRecord::Relation") }

  before do
    stub_const("TestModel", double("TestModel"))
    allow(TestModel).to receive(:all).and_return(scope)
    allow(Warped::Queries::Filter).to receive(:call).with(scope, filter_conditions: anything).and_return(scope)
    allow(Warped::Queries::Sort).to receive(:call).with(scope, sort_key: anything,
                                                               sort_direction: anything).and_return(scope)
    allow(Warped::Queries::Search).to receive(:call).with(scope, search_term: anything,
                                                                 model_search_scope: anything).and_return(scope)
    allow(Warped::Queries::Paginate).to receive(:call).with(scope, page: anything,
                                                                   per_page: anything).and_return(scope)

    controller do
      include Warped::Controllers::Tabulatable

      def index
        _test_models = tabulate(TestModel.all)
      end
    end
  end

  describe "MockController#index" do
    let(:params) { {} }
    subject(:request) { call_action(MockController, :index, params:) }

    context "when no tabulate fields are defined" do
      it "calls Warped::Queries::Filter with correct params" do
        request
        expect(Warped::Queries::Filter).to have_received(:call).with(scope, filter_conditions: [])
      end

      it "calls Warped::Queries::Sort with correct params" do
        request
        expect(Warped::Queries::Sort).to have_received(:call).with(scope, sort_key: :id, sort_direction: :desc)
      end

      it "calls Warped::Queries::Search with correct params" do
        request
        expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: nil,
                                                                            model_search_scope: :search)
      end

      it "calls Warped::Queries::Paginate with correct params" do
        request
        expect(Warped::Queries::Paginate).to have_received(:call).with(scope, page: 1, per_page: 10)
      end
    end

    context "when tabulate fields are defined" do
      before do
        MockController.tabulatable_by :email, "users.created_at" => "signed_up_at", updated_at: "last_updated_at"
      end

      let(:sort_direction) { %w[asc desc asc_nulls_first asc_nulls_last desc_nulls_first desc_nulls_last].sample }

      context "when passing non mapped sort names" do
        let(:params) { { sort_key: "email", sort_direction: } }

        it "calls Warped::Queries::Sort with correct params" do
          request
          expect(Warped::Queries::Sort).to have_received(:call).with(scope, sort_key: "email",
                                                                            sort_direction:)
        end
      end

      context "when passing mapped sort names" do
        let(:params) { { sort_key: "signed_up_at", sort_direction: } }

        it "calls Warped::Queries::Sort with correct params" do
          request
          expect(Warped::Queries::Sort).to have_received(:call).with(scope, sort_key: "users.created_at",
                                                                            sort_direction:)
        end
      end

      context "when sort_direction is not passed" do
        let(:params) { { sort_key: "last_updated_at" } }

        it "calls Warped::Queries::Sort with correct params" do
          request
          expect(Warped::Queries::Sort).to have_received(:call).with(scope, sort_key: "updated_at",
                                                                            sort_direction: :desc)
        end
      end

      context "when a non existing sort key is passed" do
        let(:params) { { sort_key: "non_existing_key" } }

        it "raises an ActionController::BadRequest error" do
          expect { request }.to raise_error(ActionController::BadRequest).with_message(anything)
        end
      end

      context "when passing filter params" do
        let(:params) { { email: "john@sample.com" } }

        it "calls Warped::Queries::Filter with correct params" do
          request
          expect(Warped::Queries::Filter).to have_received(:call).with(scope,
                                                                       filter_conditions: [{
                                                                         field: :email,
                                                                         relation: "eq",
                                                                         value: "john@sample.com"
                                                                       }])
        end
      end

      context "when passing search params" do
        let(:params) { { q: "John" } }

        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: "John",
                                                                              model_search_scope: :search)
        end
      end

      context "when passing pagination params" do
        let(:params) { { page: 2, per_page: 10 } }

        it "calls Warped::Queries::Paginate with correct params" do
          request
          expect(Warped::Queries::Paginate).to have_received(:call).with(scope, page: 2, per_page: 10)
        end
      end

      context "when passing all params" do
        let(:params) do
          { email: "john@sample.com", q: "John", page: 2, per_page: 10, sort_key: "email",
            sort_direction: }
        end

        it "calls Warped::Queries::Filter with correct params" do
          request
          expect(Warped::Queries::Filter).to have_received(:call).with(scope,
                                                                       filter_conditions: [{
                                                                         field: :email,
                                                                         value: "john@sample.com",
                                                                         relation: "eq"
                                                                       }])
        end

        it "calls Warped::Queries::Search with correct params" do
          request
          expect(Warped::Queries::Search).to have_received(:call).with(scope, search_term: "John",
                                                                              model_search_scope: :search)
        end

        it "calls Warped::Queries::Paginate with correct params" do
          request
          expect(Warped::Queries::Paginate).to have_received(:call).with(scope, page: 2, per_page: 10)
        end

        it "calls Warped::Queries::Sort with correct params" do
          request
          expect(Warped::Queries::Sort).to have_received(:call).with(scope, sort_key: "email",
                                                                            sort_direction:)
        end
      end
    end
  end
end
