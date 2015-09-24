# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "oai/list_identifiers.xml.builder" do
  fixtures :all
  before(:each) do 
    view.stub(:current_user_role_name).and_return('Guest')
    assign(:oai, { :errors => [] })
    assign(:manifestations, [ FactoryGirl.create(:manifestation) ])
  end
  it "renders the XML template" do
    render
    expect(rendered).to match /<ListIdentifiers>/
  end
end
