# -*- encoding: utf-8 -*-
require 'rails_helper'

describe "oai/list_records.xml.builder" do
  fixtures :all

  before(:each) do
    view.stub(:current_user_role_name).and_return('Guest')
    assign(:oai, { :errors => [] })
    manifestations = [ FactoryGirl.create(:manifestation) ]
    manifestations.stub(:last_page?){true}
    manifestations.stub(:total_count){manifestations.size}
    assign(:manifestations, manifestations)
  end

  it "renders the XML template" do
    render
    expect(rendered).to match /<metadata>/
  end

  it "renders dc:date" do
    manifestations = [FactoryGirl.create(:manifestation, pub_date: '2015-08-15')]
    manifestations.stub(:last_page?){true}
    manifestations.stub(:total_count){manifestations.size}
    assign(:manifestations, manifestations)
    render
    expect(rendered).to match /2015-08-15/
  end

  describe "when metadataPrefix is oai_dc" do
    before(:each) do
      assign(:oai, { :errors => [], :metadataPrefix => 'oai_dc' } )
    end
    it "renders the XML template" do
      render
      expect(rendered).to match /<oai_dc/
    end
  end

  describe "when metadataPrefix is junii2" do
    before(:each) do
      assign(:oai, { :errors => [], :metadataPrefix => 'junii2' } )
    end
    it "renders the XML template" do
      render
      expect(rendered).to match /<junii2/
    end
    it "renders NIItype" do
      manifestations = [FactoryGirl.create(:manifestation, nii_type_id: 1)]
      manifestations.stub(:last_page?){true}
      manifestations.stub(:total_count){manifestations.size}
      assign(:manifestations, manifestations)
      render
      expect(rendered).to match /<NIItype>Journal Article<\/NIItype>/
    end
  end

  describe "when metadataPrefix is dcndl" do
    before(:each) do
      assign(:oai, { :errors => [], :metadataPrefix => 'dcndl' } )
    end
    it "renders the XML template" do
      render
      expect(rendered).to match /dcndl/
    end
    it "renders well-formed XML", vcr: true do
      NdlBook.import_from_sru_response('R100000002-I000008369884-00')
      manifestations = Manifestation.all
      manifestations.stub(:last_page?){true}
      manifestations.stub(:total_count){manifestations.size}
      assign(:manifestations, manifestations)
      render
      doc = Nokogiri::XML(rendered)
      expect(doc.errors).to be_empty
    end
    it "renders extent and dimensions" do
      FactoryGirl.create(:manifestation, extent: "123p", dimensions: "23cm")
      manifestations = Manifestation.all
      manifestations.stub(:last_page?){true}
      manifestations.stub(:total_count){manifestations.size}
      assign(:manifestations, manifestations)
      render
      expect(rendered).to include "<dcterms:extent>123p ; 23cm</dcterms:extent>"
    end
  end
end
