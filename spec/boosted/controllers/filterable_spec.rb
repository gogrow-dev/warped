# frozen_string_literal: true

RSpec.describe Boosted::Controllers::Filterable, type: :controller do
  let(:scope) { double("ActiveRecord::Relation") }

  before do
    stub_const("TestModel", double("TestModel"))
    allow(TestModel).to receive(:all).and_return(scope)
    allow(Boosted::Queries::Filter).to receive(:call).with(scope, filter_conditions: anything).and_return(scope)

    controller do
      include Boosted::Controllers::Filterable

      def index
        _test_models = filter(TestModel.all)
      end
    end
  end

  describe "MockController#index" do
    let(:params) { {} }
    subject(:request) { call_action(MockController, :index, params:) }

    context "when no filterable fields are defined" do
      it "calls Boosted::Queries::Filter with correct params" do
        request
        expect(Boosted::Queries::Filter).to have_received(:call).with(scope, filter_conditions: [])
      end
    end

    context "when filterable fields are defined" do
      before do
        MockController.filterable_by :email, "users.created_at" => "signed_up_at", updated_at: "last_updated_at"
      end

      context "when passing non mapped filter names" do
        let(:params) { { email: "sample@test.com" } }

        it "calls Boosted::Queries::Filter with correct params" do
          request
          expect(Boosted::Queries::Filter).to have_received(:call).with(scope,
                                                                        filter_conditions: [
                                                                          {
                                                                            field: :email,
                                                                            value: "sample@test.com",
                                                                            relation: "="
                                                                          }
                                                                        ])
        end
      end

      context "when passing mapped filter names" do
        let(:params) do
          { "signed_up_at" => "2020-01-01", "signed_up_at.rel" => ">=", "last_updated_at" => "2020-01-01",
            "last_updated_at.rel": "<=" }
        end

        it "calls Boosted::Queries::Filter with correct params" do
          request
          expect(Boosted::Queries::Filter).to have_received(:call).with(scope,
                                                                        filter_conditions: [
                                                                          {
                                                                            field: "users.created_at",
                                                                            value: "2020-01-01",
                                                                            relation: ">="
                                                                          },
                                                                          {
                                                                            field: :updated_at,
                                                                            value: "2020-01-01",
                                                                            relation: "<="
                                                                          }
                                                                        ])
        end
      end

      context "when using is_null" do
        let(:params) { { "email.rel" => "is_null" } }

        it "calls Boosted::Queries::Filter with correct params" do
          request
          expect(Boosted::Queries::Filter).to have_received(:call).with(scope,
                                                                        filter_conditions: [
                                                                          {
                                                                            field: :email,
                                                                            value: nil,

                                                                            relation: "is_null"
                                                                          }
                                                                        ])
        end
      end

      context "when using is_not_null" do
        let(:params) { { "email.rel" => "is_not_null" } }

        it "calls Boosted::Queries::Filter with correct params" do
          request
          expect(Boosted::Queries::Filter).to have_received(:call).with(scope,
                                                                        filter_conditions: [
                                                                          {
                                                                            field: :email,
                                                                            value: nil,
                                                                            relation: "is_not_null"
                                                                          }
                                                                        ])
        end
      end
    end
  end
end
