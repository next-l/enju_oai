# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "oai/list_records.xml.builder" do
  fixtures :all

  before(:each) do
    view.stub(:current_user_role_name).and_return('Guest')
    assign(:oai, { :errors => [] })
    assign(:manifestations, [FactoryGirl.create(:manifestation)])
  end

  it "renders the XML template" do
    render
    expect(rendered).to match /<metadata>/
  end

  it "renders dc:date" do
    assign(:manifestations, [FactoryGirl.create(:manifestation, pub_date: '2015-08-15')])
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
      assign(:manifestations, [FactoryGirl.create(:manifestation, nii_type_id: 1)])
      render
      expect(rendered).to match /<NIItype>Journal Article<\/NIItype>/
    end
  end
end
