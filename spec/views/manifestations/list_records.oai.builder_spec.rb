# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "manifestations/list_records.oai.builder" do
  fixtures :all

  before do
    view.stub(:current_user_role_name).and_return('Guest')
    assign(:oai, { :errors => [] })
    assign(:manifestations, [FactoryGirl.create(:manifestation)])
  end

  it "renders the XML template" do
    render
    rendered.should match(/oai_dc/)
  end

  it "renders dc:date" do
    assign(:manifestations, [FactoryGirl.create(:manifestation, pub_date: '2015-08-15')])
    render
    rendered.should match(/2015-08-15/)
  end
end
