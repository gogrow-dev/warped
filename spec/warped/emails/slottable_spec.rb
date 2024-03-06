# frozen_string_literal: true

require "action_view"

RSpec.describe Warped::Emails::Slottable do
  let(:test_class) do
    Class.new(Warped::Emails::Base) do
      include Warped::Emails::Slottable
    end
  end

  it "adds the slots class attribute" do
    expect(test_class.slots).to eq(one: {}, many: {})
    expect(test_class.new.slots).to eq(one: {}, many: {})
  end

  it "adds the slots_one class method" do
    expect(test_class).to respond_to(:slots_one)
  end

  it "adds the slots_many class method" do
    expect(test_class).to respond_to(:slots_many)
  end

  describe ".slots_one" do
    before { test_class.slots_one(:header) }

    it "adds the with_header method" do
      component = test_class.new
      expect(component).to respond_to(:with_header)
      expect do
        component.with_header do
          "<h1>Header</h1>"
        end
      end.to change { component.slots[:one][:header] }.from(nil).to(be_a(Proc))
    end

    it "adds the header method" do
      component = test_class.new
      component.instance_variable_set(:@view_context, ActionView::Base.new([], {}, nil))

      expect(component).to respond_to(:header)

      component.with_header { "<h1>Header</h1>" }

      expect(component.header).to eq("&lt;h1&gt;Header&lt;/h1&gt;")
    end
  end

  describe ".slots_many" do
    before { test_class.slots_many(:headers) }

    it "adds the with_headers method" do
      component = test_class.new
      expect(component).to respond_to(:with_header)
      expect do
        component.with_header do
          "<h1>Header</h1>"
        end
      end.to change { component.slots[:many][:headers] }.from(nil).to([be_a(Proc)])
    end

    it "adds the headers method" do
      component = test_class.new
      component.instance_variable_set(:@view_context, ActionView::Base.new([], {}, nil))

      expect(component).to respond_to(:headers)

      component.with_header { "<h1>Header1</h1>" }
      component.with_header { "<h1>Header2</h1>" }

      expect(component.headers).to eq(["&lt;h1&gt;Header1&lt;/h1&gt;", "&lt;h1&gt;Header2&lt;/h1&gt;"])
    end
  end
end
