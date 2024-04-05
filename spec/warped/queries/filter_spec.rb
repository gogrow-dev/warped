# frozen_string_literal: true

RSpec.describe Warped::Queries::Filter do
  let(:scope) { double("scope") }

  describe "#call" do
    subject(:filter) { described_class.call(scope, filter_conditions:) }

    context "when filter_conditions is empty" do
      let(:filter_conditions) { [] }

      it "returns the scope" do
        expect(filter).to eq(scope)
      end
    end

    context "when filter_conditions is not empty" do
      let(:filter_conditions) { [{ relation:, field: "id", value: }] }

      context "when relation is eq" do
        let(:value) { 1 }
        let(:relation) { "eq" }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).with("id" => 1)

          filter
        end
      end

      context "when relation is neq" do
        let(:value) { 1 }
        let(:relation) { "neq" }

        before { allow(scope).to receive_message_chain(:where, :not) }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive_message_chain(:where, :not).with("id" => 1)

          filter
        end
      end

      context "when relation is gt" do
        let(:value) { 1 }
        let(:relation) { "gt" }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).and_return(scope)
          expect(scope).to receive(:not).with("id" => ...value)

          filter
        end
      end

      context "when relation is gte" do
        let(:value) { 1 }
        let(:relation) { "gte" }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).with("id" => 1..)

          filter
        end
      end

      context "when relation is lt" do
        let(:value) { 1 }
        let(:relation) { "lt" }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).with("id" => ...1)

          filter
        end
      end

      context "when relation is lte" do
        let(:value) { 1 }
        let(:relation) { "lte" }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).with("id" => ..1)

          filter
        end
      end

      context "when relation is in" do
        let(:relation) { "in" }
        let(:value) { [1, 2] }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).with("id" => [1, 2])

          filter
        end
      end

      context "when relation is between" do
        let(:relation) { "between" }
        let(:value) { [1, 2] }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).with("id" => value.first..value.last)

          filter
        end
      end

      context "when relation is starts_with" do
        let(:relation) { "starts_with" }
        let(:value) { "test" }
        let(:arel_table) { double("ArelTable") }

        before do
          allow(scope).to receive(:where).with(anything).and_return(scope)
          allow(scope).to receive(:arel_table).and_return(arel_table)
          allow(arel_table).to receive(:[]).with(anything).and_return(arel_table)
          allow(arel_table).to receive(:matches).with(anything)
        end

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:arel_table)
          expect(arel_table).to receive(:[]).with(:id)
          expect(arel_table).to receive(:matches).with("test%")

          filter
        end
      end

      context "when relation is ends_with" do
        let(:relation) { "ends_with" }
        let(:value) { "test" }
        let(:arel_table) { double("ArelTable") }

        before do
          allow(scope).to receive(:where).with(anything).and_return(scope)
          allow(scope).to receive(:arel_table).and_return(arel_table)
          allow(arel_table).to receive(:[]).with(anything).and_return(arel_table)
          allow(arel_table).to receive(:matches).with(anything)
        end

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:arel_table)
          expect(arel_table).to receive(:[]).with(:id)
          expect(arel_table).to receive(:matches).with("%test")

          filter
        end
      end

      context "when relation is contains" do
        let(:relation) { "contains" }
        let(:value) { "test" }
        let(:arel_table) { double("ArelTable") }

        before do
          allow(scope).to receive(:where).with(anything).and_return(scope)
          allow(scope).to receive(:arel_table).and_return(arel_table)
          allow(arel_table).to receive(:[]).with(anything).and_return(arel_table)
          allow(arel_table).to receive(:matches).with(anything)
        end

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:arel_table)
          expect(arel_table).to receive(:[]).with(:id)
          expect(arel_table).to receive(:matches).with("%test%")

          filter
        end
      end

      context "when relation is is_null" do
        let(:relation) { "is_null" }
        let(:value) { nil }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive(:where).with("id" => nil)

          filter
        end
      end

      context "when relation is is_not_null" do
        let(:relation) { "is_not_null" }
        let(:value) { nil }

        it "filters the scope by the given filter conditions" do
          expect(scope).to receive_message_chain(:where, :not).with("id" => nil)

          filter
        end
      end
    end

    context "when filter_conditions contains multiple conditions" do
      let(:filter_conditions) do
        [
          { relation: "eq", field: "id", value: 1 },
          { relation: "eq", field: "name", value: "test" }
        ]
      end

      it "filters the scope by the given filter conditions" do
        expect(scope).to receive(:where).with("id" => 1).and_return(scope)
        expect(scope).to receive(:where).with("name" => "test")

        filter
      end
    end

    context "when filter_conditions contains a relation that is not supported" do
      let(:filter_conditions) { [{ relation: "invalid", field: "id", value: 1 }] }

      it "raises an error" do
        expect do
          filter
        end.to raise_error(ArgumentError, "relation must be one of: #{described_class::RELATIONS.join(", ")}")
      end
    end
  end
end
