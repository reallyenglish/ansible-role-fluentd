require "fluent/input"

module Fluentd
  # An example fluentd plug-in
  class Example
    Fluent::Plugin.register_input("example", self)

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
