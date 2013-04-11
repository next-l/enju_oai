class EnjuOai::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def setup
    inject_into_class 'app/models/manifestation.rb', Manifestation,
      "  enju_oai\n"
  end
end
