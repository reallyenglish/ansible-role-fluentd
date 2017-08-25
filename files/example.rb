require "fluent/input"

module Fluentd
  class Example
    Fluent::Plugin.register_input("example", self)
    config_param :port, :integer, :default => 8888

    def configure
      super
    end

    def start
      super
    end

    def shutdown
      super
    end
  end
end
