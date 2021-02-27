require 'rails_helper'

describe "oai/list_records.xml.builder" do
  fixtures :all

  before(:each) do
    view.stub(:current_user_role_name).and_return('Guest')
    assign(:oai, { errors: [] })
    @manifestations = [FactoryBot.create(:manifestation, pub_date: '2015-08-15')]
    @manifestations.stub(:next_page_cursor){nil}
    @manifestations.stub(:last_page?){true}
    @manifestations.stub(:total_count){@manifestations.size}
    assign(:manifestations, @manifestations)
  end

  it "renders the XML template" do
    render
    expect(rendered).to match /<metadata>/
  end

  it "renders dc:date" do
    render
    expect(rendered).to match /2015-08-15/
  end

  describe "when metadataPrefix is oai_dc" do
    before(:each) do
      assign(:oai, { errors: [], metadataPrefix: 'oai_dc' } )
      @manifestations = [FactoryBot.create(:manifestation, nii_type_id: 1)]
      @manifestations.stub(:next_page_cursor){nil}
      @manifestations.stub(:last_page?){true}
      @manifestations.stub(:total_count){@manifestations.size}
      assign(:manifestations, @manifestations)
    end

    it "renders the XML template" do
      render
      expect(rendered).to match /<oai_dc/
    end
  end

  describe "when metadataPrefix is junii2" do
    before(:each) do
      assign(:oai, { errors: [], metadataPrefix: 'junii2' } )
      @manifestations = [FactoryBot.create(:manifestation, nii_type_id: 1)]
      @manifestations.stub(:next_page_cursor){nil}
      @manifestations.stub(:last_page?){true}
      @manifestations.stub(:total_count){@manifestations.size}
    end

    it "renders the XML template" do
      assign(:manifestations, @manifestations)
      render
      expect(rendered).to match /<junii2/
    end

    it "renders NIItype" do
      assign(:manifestations, @manifestations)
      render
      expect(rendered).to match /<NIItype>Journal Article<\/NIItype>/
    end
  end

  describe "when metadataPrefix is dcndl" do
    before(:each) do
      assign(:oai, { errors: [], metadataPrefix: 'dcndl' } )
      @manifestations = Manifestation.all
      @manifestations.stub(:next_page_cursor){'11223344=='}
      @manifestations.stub(:last_page?){false}
      @manifestations.stub(:total_count){@manifestations.size}
      assign(:manifestations, @manifestations)
    end

    it "renders the XML template" do
      render
      expect(rendered).to match /dcndl/
    end

    it "renders well-formed XML", vcr: true do
      NdlBook.import_from_sru_response('R100000002-I000008369884-00')
      render
      doc = Nokogiri::XML(rendered)
      expect(doc.errors).to be_empty
    end

    it "renders extent and dimensions" do
      FactoryBot.create(:manifestation, extent: "123p", dimensions: "23cm")
      render
      expect(rendered).to include "<dcterms:extent>123p ; 23cm</dcterms:extent>"
    end

    it "renders resumptionToken" do
      render
      expect(Nokogiri::XML(rendered).remove_namespaces!.at('//resumptionToken').content).to eq '11223344%3D%3D'
    end
  end
end
