# frozen_string_literal: true

RSpec.describe Warped::Controllers::Filterable, type: :controller do
  let(:scope) { double("ActiveRecord::Relation") }

  before do
    stub_const("TestModel", double("TestModel"))
    allow(TestModel).to receive(:all).and_return(scope)
    allow(Warped::Queries::Filter).to receive(:call).with(scope, filter_conditions: anything).and_return(scope)

    controller do
      include Warped::Controllers::Filterable

      def index
        _test_models = filter(TestModel.all)
      end
    end
  end

  describe "MockController#index" do
    let(:params) { {} }
    subject(:request) { call_action(MockController, :index, params:) }

    context "when no filterable fields are defined" do
      it "calls Warped::Queries::Filter with correct params" do
        request
        expect(Warped::Queries::Filter).to have_received(:call).with(scope, filter_conditions: [])
      end
    end

    context "when filterable fields are defined" do
      before do
        MockController.filterable_by :email, "users.created_at" => { kind: :time, alias_name: "signed_up_at" },
                                             updated_at: { alias_name: "last_updated_at" }
      end

      context "when passing non mapped filter names" do
        let(:params) { { email: "sample@test.com" } }

        it "calls Warped::Queries::Filter with correct params" do
          request
          expect(Warped::Queries::Filter).to have_received(:call).with(scope,
                                                                       filter_conditions: [
                                                                         {
                                                                           field: "email",
                                                                           value: "sample@test.com",
                                                                           relation: "eq"
                                                                         }
                                                                       ])
        end
      end

      context "when passing mapped filter names" do
        let(:params) do
          { "signed_up_at" => "2020-01-01", "signed_up_at.rel" => "gte", "last_updated_at" => "2020-01-01",
            "last_updated_at.rel": "lte" }
        end

        it "calls Warped::Queries::Filter with correct params" do
          request
          expect(Warped::Queries::Filter).to have_received(:call).with(scope,
                                                                       filter_conditions: [
                                                                         {
                                                                           field: "users.created_at",
                                                                           value: Time.new(2020, 1, 1),
                                                                           relation: "gte"
                                                                         },
                                                                         {
                                                                           field: "updated_at",
                                                                           value: "2020-01-01",
                                                                           relation: "lte"
                                                                         }
                                                                       ])
        end
      end

      context "when using is_null" do
        let(:params) { { "email.rel" => "is_null" } }

        it "calls Warped::Queries::Filter with correct params" do
          request
          expect(Warped::Queries::Filter).to have_received(:call).with(scope,
                                                                       filter_conditions: [
                                                                         {
                                                                           field: "email",
                                                                           value: nil,
                                                                           relation: "is_null"
                                                                         }
                                                                       ])
        end
      end

      context "when using is_not_null" do
        let(:params) { { "email.rel" => "is_not_null" } }

        it "calls Warped::Queries::Filter with correct params" do
          request
          expect(Warped::Queries::Filter).to have_received(:call).with(scope,
                                                                       filter_conditions: [
                                                                         {
                                                                           field: "email",
                                                                           value: nil,
                                                                           relation: "is_not_null"
                                                                         }
                                                                       ])
        end
      end
    end
  end
end
