def request_attr(prefix = 'oai_dc')
  from_time = @from_time.utc.iso8601 if @from_time
  until_time = @until_time.utc.iso8601 if @until_time
  attribute = {:metadataPrefix => prefix, :verb => 'ListRecords'}
  attribute.merge(:from => from_time) if from_time
  attribute.merge(:until => until_time) if until_time
  attribute
end

xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request manifestations_url(format: :oai), request_attr(@oai[:metadataPrefix])
  @oai[:errors].each do |error|
    xml.error code: error
  end
  xml.ListRecords do
    @manifestations.each do |manifestation|
      cache([manifestation, fragment: 'list_records_oai', role: current_user_role_name, locale: @locale]) do
        xml.record do
          xml.header do
            xml.identifier manifestation.oai_identifier
            xml.datestamp manifestation.updated_at.utc.iso8601
          end
          xml.metadata do
            case @oai[:metadataPrefix]
            when 'oai_dc', nil
              render 'record_oai_dc', manifestation: manifestation, xml_builder: xml
            when 'junii2'
              render 'record_junii2', manifestation: manifestation, xml_builder: xml
            end
          end
        end
      end
    end
    if @resumption.present?
      if @resumption[:cursor].to_i + @manifestations.limit_value < @manifestations.total_count
        xml.resumptionToken @resumption[:token], completeListSize: @manifestations.total_count, cursor: @resumption[:cursor], expirationDate: @resumption[:expired_at]
      end
    end
  end
end
