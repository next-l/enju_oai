# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "manifestations/show.oai.builder" do
  describe "When metadataPrefix is 'oai_dc'" do
    before(:each) do
      assign(:manifestation, FactoryGirl.create(:manifestation))
      assign(:oai, metadataPrefix: 'oai_dc')
    end

    it "renders the XML template" do
      render
      rendered.should match /<metadata\b/
      rendered.should match /<oai_dc:dc\b/
      rendered.should match /<dc:title>manifestation_title/
    end
  end
end
