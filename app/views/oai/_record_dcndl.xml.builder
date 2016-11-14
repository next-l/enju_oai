xml_builder.tag! "rdf:RDF",
  "xmlns:rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
  "xmlns:dcterms": "http://purl.org/dc/terms/",
  "xmlns:dcndl": "http://ndl.go.jp/dcndl/terms/",
  "xmlns:dc": "http://purl.org/dc/elements/1.1/",
  "xmlns:rdfs": "http://www.w3.org/2000/01/rdf-schema#",
  "xmlns:owl": "http://www.w3.org/2002/07/owl#",
  "xmlns:foaf": "http://xmlns.com/foaf/0.1/" do
  get_record_url = manifestations_url format: "oai", verb: 'GetRecord', metadataPrefix: 'dcndl', identifier: manifestation.oai_identifier
  xml_builder.tag! "dcndl:BibAdminResource", "rdf:about": get_record_url do
    xml_builder.tag! "dcndl:record", "rdf:resource": get_record_url
    xml_builder.tag! "dcndl:bibRecordCategory", ENV['DCNDL_BIBRECORDCATEGORY']
  end
  xml_builder.tag! "dcndl:BibResource", "rdf:about": get_record_url + "#material" do
    manifestation.identifiers.each do |identifier|
      case identifier.identifier_type.try(:name)
      when 'isbn'
        xml_builder.tag! "rdfs:seeAlso", "rdf:resource": "http://iss.ndl.go.jp/isbn/#{ identifier.body }"
        xml_builder.tag! "dcterms:identifier", identifier.body, "rdf:datatype": "http://ndl.go.jp/dcndl/terms/ISBN"
      when 'issn'
        xml_builder.tag! "dcterms:identifier", identifier.body, "rdf:datatype": "http://ndl.go.jp/dcndl/terms/ISSN"
      when 'ncid'
        xml_builder.tag! "dcterms:identifier", identifier.body, "rdf:datatype": "http://ndl.go.jp/dcndl/terms/NIIBibID"
      end
    end
    xml_builder.tag! "dcterms:title", manifestation.original_title
    xml_builder.tag! "dc:title" do
      xml_builder.tag! "rdf:Description" do
        xml_builder.tag! "rdf:value", manifestation.original_title
        if manifestation.title_transcription?
          xml_builder.tag! "dcndl:transcription", manifestation.title_transcription
        end
      end
    end
    xml_builder.tag! "dcterms:creator" do
      manifestation.creators.each do |creator|
        xml_builder.tag! "foaf:Agent" do
          xml_builder.tag! "foaf:name", creator.full_name
        end
      end
      xml_builder.tag! "dc:creator", manifestation.statement_of_responsibility
    end
    xml_builder.tag! "dcterms:publisher" do
      manifestation.publishers.each do |publisher|
        xml_builder.tag! "foaf:Agent" do
          xml_builder.tag! "foaf:name", publisher.full_name
        end
      end
    end
    xml_builder.tag! "dcterms:issued", manifestation.pub_date, "rdf:datatype": "http://purl.org/dc/terms/W3CDTF"
    xml_builder.tag! "dcndl:materialType", "rdf:resource": "http://ndl.go.jp/ndltype/Book"
  end
  unless manifestation.attachment.blank?
    xml_builder.fulltextURL manifestation_url(id: manifestation.id, format: :download)
  end
  %w( ISBN ISSN NCID ).each do |identifier|
    manifestation.identifier_contents(identifier.downcase).each do |val|
      xml_builder.tag! identifier, val
    end
  end
  if manifestation.root_series_statement
    xml_builder.jtitle manifestation.root_series_statement.original_title
  end
  xml_builder.volume manifestation.volume_number_string
  xml_builder.issue manifestation.issue_number_string
  xml_builder.spage manifestation.start_page
  xml_builder.epage manifestation.end_page
  xml_builder.dateofissued manifestation.pub_date
  #TODO: junii2: source
  if manifestation.language.blank? or manifestation.language.name == 'unknown'
    xml_builder.language "und"
  else
    xml_builder.language manifestation.language.iso_639_2
  end
  %w( pmid doi NAID ichushi ).each do |identifier|
    manifestation.identifier_contents(identifier.downcase).each do |val|
      xml_builder.tag! identifier, val
    end
  end
  #TODO: junii2: isVersionOf, hasVersion, isReplaceBy, replaces, isRequiredBy, requires, isPartOf, hasPart, isReferencedBy, references, isFormatOf, hasFormat
  #TODO: junii2: coverage, spatial, NIIspatial, temporal, NIItemporal
  #TODO: junii2: rights
  #TODO: junii2: textversion
  #TODO: junii2: grantid, dateofgranted, degreename, grantor
end
