# frozen_string_literal: true

def components
  %w[
    Warped::Emails::Align
    Warped::Emails::Button
    Warped::Emails::Divider
    Warped::Emails::Heading
    Warped::Emails::Link
    Warped::Emails::Layouts::Main
    Warped::Emails::Spacer
    Warped::Emails::Text
  ]
end

RSpec.describe "Warped::Emails Components classes are valid" do
  components.each do |component|
    it "#{component} is valid" do
      expect { Object.const_get(component) }.not_to raise_error
    end
  end
end
