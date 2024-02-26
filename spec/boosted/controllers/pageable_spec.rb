# frozen_string_literal: true

RSpec.describe Boosted::Controllers::Pageable, type: :controller do
  let(:scope) { double("ActiveRecord::Relation") }

  before do
    stub_const("TestModel", double("TestModel"))
    allow(TestModel).to receive(:all).and_return(scope)
    allow(Boosted::Queries::Paginate).to receive(:call).with(scope, page: anything,
                                                                    per_page: anything).and_return(scope)

    controller do
      include Boosted::Controllers::Pageable

      def index
        _test_models = paginate(TestModel.all)
      end
    end
  end

  describe "MockController#index" do
    let(:params) { {} }
    subject(:request) { call_action(MockController, :index, params:) }

    context "when the page parameter is not present" do
      it "calls Boosted::Queries::Paginate with correct params" do
        request
        expect(Boosted::Queries::Paginate).to have_received(:call).with(scope, page: 1, per_page: 10)
      end
    end

    context "when the page parameter is present" do
      let(:params) { { page: 2 } }

      it "calls Boosted::Queries::Paginate with correct params" do
        request
        expect(Boosted::Queries::Paginate).to have_received(:call).with(scope, page: 2, per_page: 10)
      end
    end

    context "when the per_page parameter is present" do
      let(:params) { { per_page: 20 } }

      it "calls Boosted::Queries::Paginate with correct params" do
        request
        expect(Boosted::Queries::Paginate).to have_received(:call).with(scope, page: 1, per_page: 20)
      end
    end

    context "when the page and per_page parameters are present" do
      let(:params) { { page: 2, per_page: 20 } }

      it "calls Boosted::Queries::Paginate with correct params" do
        request
        expect(Boosted::Queries::Paginate).to have_received(:call).with(scope, page: 2, per_page: 20)
      end
    end
  end
end
