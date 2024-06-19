# frozen_string_literal: true

module RequestHelper
  require "action_controller"
  require "active_support/rescuable"

  def base_controller
    Class.new do
      include ActionController::Helpers
      include ActiveSupport::Rescuable
      attr_accessor :params
    end
  end

  def controller(base_controller = self.base_controller, controller_const = "MockController", &)
    @controller ||= Class.new(base_controller, &).tap do |controller|
      stub_const(controller_const, controller)
    end
  end

  def call_action(controller, action, params: {})
    controller_instance = controller.new
    controller_instance.params = ActionController::Parameters.new(params)
    controller_instance.send(action)
  end

  def response
    @response
  end
end
