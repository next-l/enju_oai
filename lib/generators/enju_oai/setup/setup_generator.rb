class EnjuOai::SetupGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def copy_setup_files
    append_to_file 'config/initializers/mime_types.rb',  <<EOS
Mime::Type.register_alias "text/xml",  :oai
EOS
  end
end
