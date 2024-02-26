# frozen_string_literal: true

RSpec.describe Warped::Controllers::Sortable, type: :controller do
  let(:scope) { double("ActiveRecord::Relation") }

  before do
    stub_const("TestModel", double("TestModel"))
    allow(TestModel).to receive(:all).and_return(scope)
    allow(Warped::Queries::Sort).to receive(:call).with(scope, sort_key: anything,
                                                               sort_direction: anything).and_return(scope)

    controller do
      include Warped::Controllers::Sortable

      def index
        _test_models = sort(TestModel.all)
      end
    end
  end

  describe "MockController#index" do
    let(:params) { {} }
    subject(:request) { call_action(MockController, :index, params:) }

    context "when no sortable fields are defined" do
      it "calls Warped::Queries::Sort with correct params" do
        request
        expect(Warped::Queries::Sort).to have_received(:call).with(scope, sort_key: :id, sort_direction: :desc)
      end
    end

    context "when sortable fields are defined" do
      before do
        MockController.sortable_by :email, "users.created_at" => "signed_up_at", updated_at: "last_updated_at"
      end

      let(:sort_direction) { %w[asc desc asc_nulls_first asc_nulls_last desc_nulls_first desc_nulls_last].sample }

      context "when passing non mapped sort names" do
        let(:params) { { sort_key: "email", sort_direction: } }

        it "calls Warped::Queries::Sort with correct params" do
          request

          expect(Warped::Queries::Sort).to have_received(:call).with(scope, sort_key: "email", sort_direction:)
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
    end
  end
end
