xml.instruct! :xml, :version=>"1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request manifestations_url(format: :oai), request_attr(@oai[:metadataPrefix])
  @oai[:errors].each do |error|
    xml.error :code => error
  end
  xml.ListIdentifiers do
    @manifestations.each do |manifestation|
      cache([manifestation, fragment: 'list_identifiers_oai', role: current_user_role_name, locale: @locale]) do
        xml.header do
          xml.identifier manifestation.oai_identifier
          xml.datestamp manifestation.updated_at.utc.iso8601
          manifestation.series_statements.each do |series_statement|
            xml.setSpec series_statement.id
          end
        end
      end
    end
    if @resumption.present?
      if @resumption[:cursor].to_i + @manifestations.limit_value <= @count[:query_result]
        token = @resumption[:token]
      else
        token = nil
      end
      xml.resumptionToken token, completeListSize: @count[:query_result], cursor: @cursor.to_i
    end
  end
end
