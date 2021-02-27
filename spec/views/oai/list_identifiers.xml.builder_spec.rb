# -*- encoding: utf-8 -*-
require 'rails_helper'

describe "oai/list_identifiers.xml.builder" do
  fixtures :all
  before(:each) do 
    view.stub(:current_user_role_name).and_return('Guest')
    assign(:oai, { errors: [] })
    @manifestations = Manifestation.all
    @manifestations.stub(:next_page_cursor){'11223344=='}
    @manifestations.stub(:last_page?){false}
    @manifestations.stub(:total_count){@manifestations.size}
    assign(:manifestations, @manifestations)
  end

  it "renders the XML template" do
    render
    expect(rendered).to match /<ListIdentifiers>/
  end

  it "renders resumptionToken" do
    render
    expect(Nokogiri::XML(rendered).remove_namespaces!.at('//resumptionToken').content).to eq '11223344%3D%3D'
  end
end
