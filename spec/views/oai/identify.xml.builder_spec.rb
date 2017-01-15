require 'rails_helper'

describe "oai/identify.xml.builder" do
  fixtures :all

  before(:each) do
    assign(:library_group, LibraryGroup.site_config)
    view.stub(:current_user).and_return(User.find_by(username: 'enjuadmin'))
  end

  it "renders the XML template" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/enju_library/)
  end
end
