# frozen_string_literal: true

RSpec.describe Warped::Queries::Paginate do
  let(:scope) { double("scope") }

  describe "#call" do
    before do
      allow(scope).to receive(:limit).with(anything).and_return(scope)
      allow(scope).to receive(:offset).with(anything).and_return(scope)
      allow(scope).to receive(:count).with(anything).and_return(10)
      allow(scope).to receive(:group_values).and_return([])
    end

    subject(:paginate) { described_class.call(scope, page:, per_page:) }

    context "when page is not present" do
      let(:page) { nil }

      context "when per_page is not present" do
        let(:per_page) { nil }

        it "paginates the scope with default page and per_page" do
          expect(scope).to receive(:limit).with(10)
          expect(scope).to receive(:offset).with(0)
          expect(scope).to receive(:count).with(:all).and_return(10)

          expect(paginate[0]).to include(page: 1, total_pages: 1, total_count: 10, next_page: nil, prev_page: nil,
                                         per_page: 10)
          expect(paginate[1]).to eq(scope)
        end
      end

      context "when per_page is present" do
        let(:per_page) { 20 }

        it "paginates the scope with the given per_page" do
          expect(scope).to receive(:limit).with(20)
          expect(scope).to receive(:offset).with(0)
          expect(scope).to receive(:count).with(:all).and_return(10)
          expect(paginate[0]).to include(page: 1, total_pages: 1, total_count: 10, next_page: nil, prev_page: nil,
                                         per_page:)
          expect(paginate[1]).to eq(scope)
        end
      end

      context "when per_page is greater than MAX_PER_PAGE" do
        let(:per_page) { 200 }

        it "paginates the scope with the given per_page" do
          expect(scope).to receive(:limit).with(100)
          expect(scope).to receive(:offset).with(0)
          expect(scope).to receive(:count).with(:all).and_return(10)
          expect(paginate[0]).to include(page: 1, total_pages: 1, total_count: 10, next_page: nil, prev_page: nil,
                                         per_page: 100)
          expect(paginate[1]).to eq(scope)
        end
      end
    end

    context "when page is present" do
      let(:page) { 2 }

      context "when per_page is not present" do
        let(:per_page) { nil }

        it "paginates the scope with default per_page" do
          expect(scope).to receive(:limit).with(10)
          expect(scope).to receive(:offset).with(10)
          expect(scope).to receive(:count).with(:all).and_return(10)
          expect(paginate[0]).to include(page:, total_pages: 1, total_count: 10, next_page: nil, prev_page: 1,
                                         per_page: 10)
          expect(paginate[1]).to eq(scope)
        end
      end

      context "when per_page is present" do
        let(:per_page) { 20 }

        it "paginates the scope with the given per_page" do
          expect(scope).to receive(:limit).with(20)
          expect(scope).to receive(:offset).with(20)
          expect(scope).to receive(:count).with(:all).and_return(10)
          expect(paginate[0]).to include(page:, total_pages: 1, total_count: 10, next_page: nil, prev_page: 1,
                                         per_page: 20)
          expect(paginate[1]).to eq(scope)
        end
      end
    end
  end
end
