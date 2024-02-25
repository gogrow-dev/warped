# frozen_string_literal: true

require "active_record"

RSpec.describe Boosted::Queries::Sort do
  let(:scope) { double("scope") }

  before do
    allow(scope).to receive(:klass).and_return(double("klass", arel_table: Arel::Table.new("id")))
    allow(scope).to receive(:reorder).and_return(scope)
  end

  describe "#call" do
    subject(:sort) { described_class.call(scope, sort_key:, sort_direction:) }

    context "when sort_direction is a single column" do
      let(:sort_key) { "id" }
      context "when sort_direction is invalid" do
        let(:sort_direction) { "invalid" }

        it "raises an error" do
          message = "Invalid sort direction: #{sort_direction}, must be one of #{described_class::SORT_DIRECTIONS}"
          expect do
            sort
          end.to raise_error(ArgumentError, message)
        end
      end

      context "when sort_direction is asc" do
        let(:sort_direction) { "asc" }

        it "sorts the scope by the given sort key in ascending order" do
          expect(scope).to receive(:reorder).with({ "id" => "asc" })

          sort
        end
      end

      context "when sort_direction is desc" do
        let(:sort_direction) { "desc" }

        it "sorts the scope by the given sort key in descending order" do
          expect(scope).to receive(:reorder).with({ "id" => "desc" })

          sort
        end
      end

      context "when sort_direction is asc_nulls_first" do
        let(:sort_direction) { "asc_nulls_first" }

        it "sorts the scope by the given sort key in ascending order with nulls first" do
          expect(scope).to receive(:reorder).with(Arel::Table.new("id")["id"].asc.nulls_first)

          sort
        end
      end

      context "when sort_direction is asc_nulls_last" do
        let(:sort_direction) { "asc_nulls_last" }

        it "sorts the scope by the given sort key in ascending order with nulls last" do
          expect(scope).to receive(:reorder).with(Arel::Table.new("id")["id"].asc.nulls_last)

          sort
        end
      end

      context "when sort_direction is desc_nulls_first" do
        let(:sort_direction) { "desc_nulls_first" }

        it "sorts the scope by the given sort key in descending order with nulls first" do
          expect(scope).to receive(:reorder).with(Arel::Table.new("id")["id"].desc.nulls_first)

          sort
        end
      end
    end

    context "when sort_direction is a table.column" do
      let(:sort_key) { "table.id" }
      context "when sort_direction is invalid" do
        let(:sort_direction) { "invalid" }

        it "raises an error" do
          message = "Invalid sort direction: #{sort_direction}, must be one of #{described_class::SORT_DIRECTIONS}"
          expect do
            sort
          end.to raise_error(ArgumentError, message)
        end
      end

      context "when sort_direction is asc" do
        let(:sort_direction) { "asc" }

        it "sorts the scope by the given sort key in ascending order" do
          expect(scope).to receive(:reorder).with({ "table.id" => "asc" })

          sort
        end
      end

      context "when sort_direction is desc" do
        let(:sort_direction) { "desc" }

        it "sorts the scope by the given sort key in descending order" do
          expect(scope).to receive(:reorder).with({ "table.id" => "desc" })

          sort
        end
      end

      context "when sort_direction is asc_nulls_first" do
        let(:sort_direction) { "asc_nulls_first" }

        it "sorts the scope by the given sort key in ascending order with nulls first" do
          expect(scope).to receive(:reorder).with(Arel::Table.new("table")["id"].asc.nulls_first)

          sort
        end
      end

      context "when sort_direction is asc_nulls_last" do
        let(:sort_direction) { "asc_nulls_last" }

        it "sorts the scope by the given sort key in ascending order with nulls last" do
          expect(scope).to receive(:reorder).with(Arel::Table.new("table")["id"].asc.nulls_last)

          sort
        end
      end

      context "when sort_direction is desc_nulls_first" do
        let(:sort_direction) { "desc_nulls_first" }

        it "sorts the scope by the given sort key in descending order with nulls first" do
          expect(scope).to receive(:reorder).with(Arel::Table.new("table")["id"].desc.nulls_first)

          sort
        end
      end
    end
  end
end
