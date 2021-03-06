xml.instruct! :xml, version: "1.0"
xml.tag! "OAI-PMH", :xmlns => "http://www.openarchives.org/OAI/2.0/",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xsi:schemaLocation" => "http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd" do
  xml.responseDate Time.zone.now.utc.iso8601
  xml.request manifestations_url(format: :oai), verb: "GetRecord"
  xml.GetRecord do
    xml.record do
      xml.header do
        xml.identifier @manifestation.oai_identifier
        xml.datestamp @manifestation.updated_at.utc.iso8601
        @manifestation.series_statements.each do |series_statement|
          xml.setSpec series_statement.id
        end
      end
      xml.metadata do
        case @oai[:metadataPrefix]
        when 'oai_dc', nil
          render 'record_oai_dc', manifestation: @manifestation, xml_builder: xml
        when 'junii2'
          render 'record_junii2', manifestation: @manifestation, xml_builder: xml
        when 'jpcoar'
          render 'record_jpcoar', manifestation: @manifestation, xml_builder: xml
        when 'dcndl'
          render 'record_dcndl', manifestation: @manifestation, xml_builder: xml
        end
      end
    end
  end
end
