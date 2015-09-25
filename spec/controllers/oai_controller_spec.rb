require 'spec_helper'

RSpec.describe OaiController, type: :controller do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:manifestation)
  end

  describe "GET index", :solr => true do
    before do
      Manifestation.reindex
    end

    describe "When not logged in" do
      it "assigns all manifestations as @manifestations in oai format without verb" do
        get :provider, format: 'xml'
        assigns(:manifestations).should_not be_nil
        response.should render_template("oai/provider")
      end

      it "should not assign all manifestations as @manifestations in oai format with ListRecords without metadataPrefix" do
        get :provider, format: 'xml', :verb => 'ListRecords'
        assigns(:manifestations).should_not be_nil
        response.should render_template("oai/provider")
      end

      it "assigns all manifestations as @manifestations in oai format with ListRecords for junii2 metadata" do
        get :provider, format: 'xml', :verb => 'ListRecords', :metadataPrefix => 'junii2'
        assigns(:manifestations).should_not be_nil
        response.should render_template("oai/list_records")
      end

      it "should not assign all manifestations as @manifestations in oai format with ListIdentifiers without metadataPrefix" do
        get :provider, format: 'xml', :verb => 'ListIdentifiers'
        assigns(:manifestations).should_not be_nil
        response.should render_template("oai/provider")
      end

      it "assigns all manifestations as @manifestations in oai format with ListIdentifiers for junii2 metadata" do
        get :provider, format: 'xml', :verb => 'ListIdentifiers', :metadataPrefix => 'junii2'
        assigns(:manifestations).should_not be_nil
        response.should render_template("oai/list_identifiers")
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord without identifier" do
        get :provider, format: 'xml', :verb => 'GetRecord'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should be_nil
        response.should render_template('oai/provider')
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord with identifier" do
        get :provider, format: 'xml', :verb => 'GetRecord', :identifier => 'oai:localhost:manifestations-1'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
        response.should render_template('oai/get_record')
      end
      it "assigns all manifestations as @manifestations in oai format with GetRecord with identifier for junii2 metadata" do
        get :provider, format: 'xml', :verb => 'GetRecord', :identifier => 'oai:localhost:manifestations-1', :metadataPrefix => 'junii2'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
        response.should render_template('oai/get_record')
      end
    end
  end
end
