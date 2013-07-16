require "rails"

module Deb
  class Engine < ::Rails::Engine
    isolate_namespace Deb
  end
end

