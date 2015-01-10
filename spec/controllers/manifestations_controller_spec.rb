require 'spec_helper'

describe ManifestationsController do
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
        get :index, :format => 'oai'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/index")
      end

      it "assigns all manifestations as @manifestations in oai format with ListRecords" do
        get :index, :format => 'oai', :verb => 'ListRecords'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/list_records")
      end

      it "assigns all manifestations as @manifestations in oai format with ListIdentifiers" do
        get :index, :format => 'oai', :verb => 'ListIdentifiers'
        assigns(:manifestations).should_not be_nil
        response.should render_template("manifestations/list_identifiers")
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord without identifier" do
        get :index, :format => 'oai', :verb => 'GetRecord'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should be_nil
        response.should render_template('manifestations/index')
      end

      it "assigns all manifestations as @manifestations in oai format with GetRecord with identifier" do
        get :index, :format => 'oai', :verb => 'GetRecord', :identifier => 'oai:localhost:manifestations-1'
        assigns(:manifestations).should be_nil
        assigns(:manifestation).should_not be_nil
        response.should render_template('manifestations/show')
      end
    end
  end
end
