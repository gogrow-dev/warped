# frozen_string_literal: true

RSpec.describe Warped::Emails::Styleable do
  let(:test_class) do
    Class.new(Warped::Emails::Base) do
      include Warped::Emails::Styleable
    end
  end

  describe ".default_variants" do
    subject { test_class.default_variants }

    context "when the default_variants is not set" do
      it "returns an empty hash" do
        is_expected.to eq({})
      end

      it "returns the @default_variants" do
        expect(subject).to eq({})
      end
    end

    context "when the default_variants is set" do
      before { test_class.instance_variable_set(:@default_variants, { size: "sm" }) }

      it "returns the default_variants" do
        is_expected.to eq(size: "sm")
      end

      it "does not change the @default_variants" do
        expect { subject }.not_to(change { test_class.instance_variable_get(:@default_variants) })
      end
    end
  end

  describe ".base_styles" do
    subject { test_class.base_styles }

    context "when the base_styles is not set" do
      it "returns an empty hash" do
        is_expected.to eq({})
      end

      it "returns the @base_styles" do
        expect(subject).to eq({})
      end
    end

    context "when the base_styles is set" do
      before { test_class.instance_variable_set(:@base_styles, { color: "red" }) }

      it "returns the base_styles" do
        is_expected.to eq(color: "red")
      end

      it "does not change the @base_styles" do
        expect { subject }.not_to(change { test_class.instance_variable_get(:@base_styles) })
      end
    end
  end

  describe ".variants" do
    subject { test_class.variants }

    context "when the variants is not set" do
      it "returns an empty hash" do
        is_expected.to eq({})
      end

      it "sets the @variants" do
        expect(subject).to eq({})
      end
    end

    context "when the variants is set" do
      before { test_class.instance_variable_set(:@variants, { size: "sm" }) }

      it "returns the variants" do
        is_expected.to eq(size: "sm")
      end

      it "does not change the @variants" do
        expect { subject }.not_to(change { test_class.instance_variable_get(:@variants) })
      end
    end
  end

  describe ".variant" do
    context "when the block is not given" do
      it "raises ArgumentError" do
        expect do
          test_class.variant
        end.to raise_error(ArgumentError, "You must provide a block")
      end
    end

    context "when the block is given" do
      context "when the variant_name is not given" do
        it "uses the default variant name" do
          test_class.variant do
            color do
              red { "color: red" }
            end
          end

          expect(test_class.variants[:_base_variant][:color][:red].class).to eq(Proc)
          expect(test_class.variants[:_base_variant][:color][:red].call).to eq("color: red")
        end
      end

      context "when the variant_name is given" do
        it "uses the given variant name" do
          test_class.variant(:highlight) do
            color do
              red { "color: red" }
            end
          end

          expect(test_class.variants[:highlight][:color][:red].class).to eq(Proc)
          expect(test_class.variants[:highlight][:color][:red].call).to eq("color: red")
        end
      end
    end
  end

  describe ".default_variant" do
    before do
      test_class.variant do
        color do
          red { "color: red" }
        end
      end

      test_class.variant(:highlight) do
        color do
          red { "color: blue" }
        end
      end
    end

    context "when the name is not given" do
      it "uses the default variant name" do
        expect { test_class.default_variant(color: :red) }.to change {
                                                                test_class.default_variants.dig(:_base_variant, :color)
                                                              }.from(nil).to(:red)
      end
    end

    context "when the name is given" do
      it "uses the given variant name" do
        expect { test_class.default_variant(:highlight, color: :red) }.to change {
                                                                            test_class.default_variants
                                                                                      .dig(:highlight, :color)
                                                                          }.from(nil).to(:red)
      end
    end
  end

  describe "#default_variants" do
    it "returns the class default_variants" do
      expect(test_class.new.default_variants).to eq(test_class.default_variants)
    end
  end

  describe "#base_styles" do
    it "returns the class base_styles" do
      expect(test_class.new.base_styles).to eq(test_class.base_styles)
    end
  end

  describe "#variants" do
    it "returns the class variants" do
      expect(test_class.new.variants).to eq(test_class.variants)
    end
  end

  describe "#style" do
    before do
      test_class.variant do
        base { ["color: red"] }
      end
    end
    context "when the variant_name is not given" do
      context "when the kwargs is not given" do
        context "when the default_variants is not set" do
          it "returns the base_styles" do
            expect(test_class.new.style).to eq("color: red")
          end
        end

        context "when the default_variants is set" do
          before do
            test_class.variant do
              size do
                sm { "font-size: 12px" }
              end
            end

            test_class.default_variant(size: :sm)
          end

          it "returns the base_styles appended with the default_variants" do
            expect(test_class.new.style).to eq("color: red; font-size: 12px")
          end
        end
      end

      context "when the kwargs is given" do
        before do
          test_class.variant do
            size do
              sm { "font-size: 12px" }
              md { "font-size: 114px" }
            end
          end
          test_class.default_variant(size: :sm)
        end

        it "returns the base_styles appended with the default_variants, overriden by the kwargs" do
          expect(test_class.new.style(size: :md)).to eq("color: red; font-size: 114px")
        end
      end
    end
  end

  describe "inheritance" do
    before do
      test_class.variant do
        base { ["color: red"] }

        color do
          red { "color: red" }
        end

        size do
          sm { "font-size: 12px" }
        end
      end
      test_class.default_variant(size: :sm, color: :red)
    end

    let!(:child_class) do
      Class.new(test_class) do
        variant do
          size do
            lg { "font-size: 18px" }
          end
        end

        default_variant(size: :lg)
      end
    end

    it "inherits the default_variants" do
      expect(test_class.default_variants[:_base_variant]).to eq({ size: :sm, color: :red })
      expect(child_class.default_variants[:_base_variant]).to eq({ size: :lg, color: :red })
    end

    it "inherits the base_styles" do
      expect(test_class.base_styles[:_base_variant].call).to eq(["color: red"])
      expect(child_class.base_styles[:_base_variant].call).to eq(["color: red"])
    end

    it "inherits the variants" do
      expect(test_class.variants[:_base_variant][:size][:sm].call).to eq("font-size: 12px")
      expect(test_class.variants[:_base_variant][:size][:lg]).to be_nil
      expect(child_class.variants[:_base_variant][:size][:sm].call).to eq("font-size: 12px")
      expect(child_class.variants[:_base_variant][:size][:lg].call).to eq("font-size: 18px")
    end
  end
end
