module EnjuOai
  module ActsAsMethods
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def enju_oai
        include InstanceMethods
      end

      def find_by_oai_identifier(identifier)
        self.find(identifier.to_s.split(":").last.split("-").last)
      end
    end
  
    module InstanceMethods
      def oai_identifier
        "oai:#{::Addressable::URI.parse(LibraryGroup.site_config.url).host}:#{self.class.to_s.tableize}-#{self.id}"
      end
    end
  end
end

ActiveRecord::Base.send :include, EnjuOai::ActsAsMethods
