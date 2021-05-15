module EnjuOai
  module OaiController
    def self.included(base)
      base.send :include, ClassMethods
      base.helper_method :request_attr
    end
  
    module ClassMethods
      def check_oai_params(params)
        oai = {}
        oai[:errors] = []
        case params[:verb]
        when 'Identify'
        when 'ListSets'
        when 'ListMetadataFormats'
        when 'ListIdentifiers'
          oai[:metadataPrefix] = params[:metadataPrefix]
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "badArgument"
          end
        when 'ListRecords'
          oai[:metadataPrefix] = params[:metadataPrefix]
          unless valid_metadata_format?(params[:metadataPrefix])
            oai[:errors] << "badArgument"
          end
        when 'GetRecord'
          if valid_metadata_format?(params[:metadataPrefix])
            if params[:identifier].blank?
              oai[:errors] << "badArgument"
            end
            oai[:metadataPrefix] = params[:metadataPrefix]
            unless valid_metadata_format?(params[:metadataPrefix])
              oai[:errors] << "badArgument"
            end
          else
            oai[:errors] << "badArgument"
          end
        else
          oai[:errors] << "badVerb"
        end

        oai
      end
  
      def valid_metadata_format?(format)
        if format.present?
          if ['oai_dc', 'junii2', 'jpcoar', 'dcndl'].include?(format)
            true
          else
            false
          end
        else
          false
        end
      end

      def request_attr(from_time, until_time, prefix = 'oai_dc')
        attribute = {metadataPrefix: prefix, verb: 'ListRecords'}
        attribute.merge(from: from_time.utc.iso8601) if from_time
        attribute.merge(until: until_time.utc.iso8601) if until_time
        attribute
      end

      def set_resumption_token(token, from_time, until_time, per_page = 200)
        if token
          cursor = token.split(',').reverse.first.to_i + per_page
        else
          cursor = per_page
        end
        {
          token: "f(#{from_time.utc.iso8601.to_s}),u(#{until_time.utc.iso8601.to_s}),#{cursor}",
          cursor: cursor
        }
      end

      def set_from_and_until(klass, from_t, until_t)
        if klass.first and klass.last
          from_t ||= klass.order(:updated_at).first.updated_at.to_s
          until_t ||= klass.order(:updated_at).last.updated_at.to_s
        else
          from_t ||= Time.zone.now.to_s
          until_t ||= Time.zone.now.to_s
        end

        times = {}
        if /^[12]\d{3}-(0?[1-9]|1[0-2])-(0?[1-9]|[12]\d|3[01])$/ =~ from_t
          times[:from] = Time.zone.parse(from_t).beginning_of_day
        else
          times[:from] = Time.zone.parse(from_t)
        end
        if /^[12]\d{3}-(0?[1-9]|1[0-2])-(0?[1-9]|[12]\d|3[01])$/ =~ until_t
          times[:until] = Time.zone.parse(until_t).beginning_of_day
        else
          times[:until] = Time.zone.parse(until_t)
        end
        times[:from] ||= Time.zone.parse(from_t)
        times[:until] ||= Time.zone.parse(until_t)
        times
      end
    end
  end
end
