require "enju_oai/engine"
require 'enju_oai/oai_controller'

module EnjuOai
end

ActionController::Base.send :include, EnjuOai::OaiController
