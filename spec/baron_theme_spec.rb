require 'spec_helper'

###
# Tests Baron::Theme class
#
# This class represents an individual article

describe "Baron::Theme" do
  before :all do
    @config = load_config()
    @theme = Baron::Theme.new(@config)
    @theme.load_config()
  end

  it "finds all parameters in theme_config.yml" do
    expect(@theme.root).to eq('/themes/typography')
    expect(@theme[:root]).to eq('/themes/typography')
    expect(@theme[:masthead_url]).to eq("http://www.my-corporation.com")
    expect(@theme[:param_test]).to eq("FOOBAR")
    expect(@theme[:company_description]).to eq("Insert content here")
  end
  
  it "finds all the rendering templates" do
    expect(@theme.get_template('article')).to eq(SAMPLE_DATA_PATH + 'themes/typography/templates/article.rhtml')
    expect(@theme.get_template('category')).to eq(SAMPLE_DATA_PATH + 'themes/typography/templates/category.rhtml')
    expect(@theme.get_template('error')).to eq(SAMPLE_DATA_PATH + 'themes/typography/templates/error.rhtml')
    expect(@theme.get_template('home')).to eq(SAMPLE_DATA_PATH + 'themes/typography/templates/home.rhtml')
    expect(@theme.get_template('layout')).to eq(SAMPLE_DATA_PATH + 'themes/typography/templates/layout.rhtml')
  end
  
  it "doesn't crash with a bad or empty config file" do
    theme = Baron::Theme.new({})
    theme.load_config("#{SAMPLE_DATA_PATH}supplemental-files/theme_config.yml")
    expect(theme.length).to eq(4)
    theme.load_config("FOOBAR-FAKE-URL-FAKE-FAKE")
    expect(theme.length).to eq(4)
  end
end
