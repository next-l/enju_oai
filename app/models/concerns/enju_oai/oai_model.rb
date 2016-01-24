module EnjuOai
  module OaiModel
    extend ActiveSupport::Concern

    def self.find_by_oai_identifier(identifier)
      self.find(identifier.to_s.split(":").last.split("-").last)
    end
  
    def oai_identifier
      "oai:#{::Addressable::URI.parse(LibraryGroup.site_config.url).host}:#{self.class.to_s.tableize}-#{self.id}"
    end
  end
end
