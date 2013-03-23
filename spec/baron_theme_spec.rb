require 'spec_helper'

###
# Tests Baron::Theme class
#
# This class represents an individual article

describe "Baron::Theme" do
  before :all do
    @config = load_config()
    @theme = Baron::Theme.new(@config)
  end

  it "finds all parameters in theme_config.yml" do
    @theme.root.should == '/themes/typography'
    @theme[:root].should == '/themes/typography'
    @theme[:masthead_url].should == "http://www.my-corporation.com"
    @theme[:param_test].should == "FOOBAR"
    @theme[:company_description].should == "Insert content here"
  end
  
  it "finds all the rendering templates" do
    @theme.get_template('article').should == SAMPLE_DATA_PATH + 'themes/typography/templates/article.rhtml'
    @theme.get_template('category').should == SAMPLE_DATA_PATH + 'themes/typography/templates/category.rhtml'
    @theme.get_template('error').should == SAMPLE_DATA_PATH + 'themes/typography/templates/error.rhtml'
    @theme.get_template('home').should == SAMPLE_DATA_PATH + 'themes/typography/templates/home.rhtml'
    @theme.get_template('layout').should == SAMPLE_DATA_PATH + 'themes/typography/templates/layout.rhtml'
  end
end
