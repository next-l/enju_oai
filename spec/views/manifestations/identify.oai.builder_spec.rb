# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "manifestations/identify.oai.builder" do
  fixtures :all

  before(:each) do
    assign(:library_group, LibraryGroup.site_config)
    view.stub(:current_user).and_return(User.where(username: 'enjuadmin').first)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders the XML template" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/enju_library/)
  end
end
