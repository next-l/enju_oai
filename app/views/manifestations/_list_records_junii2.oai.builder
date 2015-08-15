xml_builder.tag! "junii2",
  "xsi:schemaLocation": "http://irdb.nii.ac.jp/oai http://irdb.nii.ac.jp/oai/junii2-3-1.xsd",
  "xmlns": "http://irdb.nii.ac.jp/oai",
  "xmlns:dc": "http://purl.org/dc/elements/1.1/" do
  xml_builder.title manifestation.original_title
  xml_builder.alternative manifestation.title_alternative
  manifestation.creators.readable_by(current_user).each do |patron|
    xml_builder.creator patron.full_name
  end
  if manifestation.try(:subjects)
    manifestation.subjects.each do |subject|
      unless subject.subject_type.name =~ /BSH|NDLSH|MeSH|LCSH/io
        xml_builder.subject subject.term
      end
    end
  end
  if manifestation.try(:classifications)
    %w[ NDC NDLC ].each do |c|
      manifestation.classifications.each do |classification| 
        if classification.classification_type.name =~ /#{ c }/i
          xml_builder.tag! c, classification.category
        end
      end
    end
  end
  if manifestation.try(:subjects)
    %w[ BSH NDLSH MeSH ].each do |s|
      manifestation.subjects.each do |subject|
        if s.subject_type.name =~ /#{ subject }/i
          xml_builder.tag! subject, subject.term
        end
      end
    end
  end
  if manifestation.try(:classifications)
    %w[ DDC LCC UDC ].each do |c|
      manifestation.classifications.each do |classification| 
        if classification.classification_type.name =~ /#{ c }/i
          xml_builder.tag! c, classification.category
        end
      end
    end
  end
  if manifestation.try(:subjects)
    manifestation.subjects.each do |s|
      if s.subject_type.name =~ /LCSH/i
        xml_builder.tag! subject, subject.term
      end
    end
  end
  xml_builder.description manifestation.description
  manifestation.publishers.readable_by(current_user).each do |patron|
    xml_builder.publisher patron.full_name
  end
  manifestation.contributors.readable_by(current_user).each do |patron|
    xml_builder.contributor patron.full_name
  end
  xml_builder.date manifestation.pub_date
  xml_builder.type manifestation.manifestation_content_type.name
  #TODO: xml_builder.NIItype
  if manifestation.attachment
    xml_builder.format manifestation.attachment_content_type
  end
  manifestation.identifier_contents(:isbn).each do |isbn|
    xml_builder.ISBN isbn
  end
end
