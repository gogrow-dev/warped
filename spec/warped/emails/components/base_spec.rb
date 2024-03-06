# frozen_string_literal: true

RSpec.describe Warped::Emails::Base do
  let(:base) { Warped::Emails::Base.new }

  describe "#template" do
    it "raises NotImplementedError" do
      expect { base.template }.to raise_error(NotImplementedError)
    end
  end

  describe "#content" do
    context "when the content block is not set" do
      it "returns nil" do
        expect(base.content).to be_nil
      end
    end

    context "when the content block is set" do
      before { base.instance_variable_set(:@content_block, "<h1>Sample Content</h1>") }

      it "returns the content block" do
        expect(base.content).to eq("<h1>Sample Content</h1>")
      end
    end
  end

  describe "#helpers" do
    context "when the view context is not set" do
      it "raises ArgumentError" do
        expect do
          base.helpers
        end.to raise_error(ArgumentError,
                           "helpers cannot be used during initialization, as it depends on the view context")
      end
    end

    context "when the view context is set" do
      let(:view_context) { double("view_context") }
      before { base.instance_variable_set(:@view_context, view_context) }

      it "returns the view context" do
        expect(base.helpers).to eq(view_context)
      end
    end
  end

  describe "#render_in" do
    let(:view_context) { double("view_context") }

    before do
      allow(view_context).to receive(:content_tag).with(:h1, "Sample Content").and_return("<h1>Sample Content</h1>")
      allow(view_context).to receive(:capture).and_yield
      allow(base).to receive(:template).and_return("<span>Template</span>")
    end

    subject { base.render_in(view_context) { |base| base.content_tag(:h1, "Sample Content") } }

    it "sets the view context" do
      subject
      expect(base.view_context).to eq(view_context)
    end

    it "sets the content block" do
      expect(subject).to eq("<span>Template</span>")
      expect(base.content).to eq("<h1>Sample Content</h1>")
    end
  end
end
