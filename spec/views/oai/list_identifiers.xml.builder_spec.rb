require 'rails_helper'

describe "oai/list_identifiers.xml.builder" do
  fixtures :all
  before(:each) do 
    view.stub(:current_user_role_name).and_return('Guest')
    assign(:oai, { :errors => [] })
    manifestations = [ FactoryGirl.create(:manifestation) ]
    manifestations.stub(:last_page?){true}
    manifestations.stub(:total_count){manifestations.size}
    assign(:manifestations, manifestations)
  end
  it "renders the XML template" do
    render
    expect(rendered).to match /<ListIdentifiers>/
  end
end
