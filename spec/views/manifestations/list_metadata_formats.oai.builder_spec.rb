# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "manifestations/list_metadata_formats.oai.builder" do
  fixtures :all
  it "renders the XML template" do
    render
    expect(rendered).to match /<ListMetadataFormats>/
  end
  it "supports oai_dc metadata format" do
    render
    expect(rendered).to match /oai_dc/
  end
  it "supports junii2 metadata format" do
    render
    expect(rendered).to match /junii2/
  end
end
