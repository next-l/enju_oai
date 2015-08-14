# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "manifestations/list_records.oai.builder" do
  fixtures :all

  before do
    view.stub(:current_user_role_name).and_return('Guest')
  end

  it "renders the XML template" do
    assign(:oai, { :errors => [] })
    assign(:manifestations, [FactoryGirl.create(:manifestation)])
    render
    rendered.should match(/oai_dc/)
  end
end
