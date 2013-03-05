require 'spec_helper'

###
# Tests Baron::BlogEngine class
#
# This class understands how the blog directory structure works, and is used by the app to access
# all content from the directory structure.

describe "Baron::BlogEngine" do
  before :all do
    @config = load_config()
    @blog_engine = Baron::BlogEngine.new @config
  end
    
  describe "Access all content" do
    it "finds application paths" do
      @blog_engine.get_pages_path.should == SAMPLE_DATA_PATH + 'pages/'
      @blog_engine.get_articles_path.should == SAMPLE_DATA_PATH + 'articles'
      @blog_engine.get_page_template('about').should == SAMPLE_DATA_PATH + 'pages/about.rhtml'
      @blog_engine.get_theme_template('article').should == SAMPLE_DATA_PATH + 'themes/test/templates/article.rhtml'
      @blog_engine.get_theme_template('category').should == SAMPLE_DATA_PATH + 'themes/test/templates/category.rhtml'
      @blog_engine.get_theme_template('error').should == SAMPLE_DATA_PATH + 'themes/test/templates/error.rhtml'
      @blog_engine.get_theme_template('index').should == SAMPLE_DATA_PATH + 'themes/test/templates/index.rhtml'
      @blog_engine.get_theme_template('layout').should == SAMPLE_DATA_PATH + 'themes/test/templates/layout.rhtml'
      @blog_engine.get_system_resource('redirects.txt').should == SAMPLE_DATA_PATH + 'resources/redirects.txt'
      @blog_engine.get_system_resource('robots.txt').should == SAMPLE_DATA_PATH + 'resources/robots.txt'
      @blog_engine.get_system_resource('feeds.rss').should == SAMPLE_DATA_PATH + 'resources/feeds.rss'
    end 
    
    it "finds all categories" do
      categories = @blog_engine.get_all_categories
      categories.count.should == 2
      categories.first[:name].should == 'Code Projects'
      categories.first[:path].should == '/code-projects/'
      categories.first[:count].should == 0
      categories.last[:name].should == 'Poems'
      categories.last[:path].should == '/poems/'
      categories.last[:count].should == 2
    end
    
    it "finds all articles" do
      articles_fileparts = @blog_engine.get_all_articles()
      articles_fileparts.count.should == 3
      articles_fileparts.first[:filename_and_path].should == SAMPLE_DATA_PATH + 'articles/2012-11-09-sample-post.txt' 
      articles_fileparts.first[:date].should == '2012-11-09' 
      articles_fileparts.first[:filename].should == 'sample-post' 
      articles_fileparts.first[:category].should == ''
      articles_fileparts.last[:filename_and_path].should == SAMPLE_DATA_PATH + 'articles/poems/1909-01-02-If.txt' 
      articles_fileparts.last[:date].should == '1909-01-02' 
      articles_fileparts.last[:filename].should == 'if' 
      articles_fileparts.last[:category].should == 'poems' 
    end
    
    it "returns all article parts" do
      @blog_engine.get_all_articles().each do |article_parts|
        article_parts[:filename_and_path].should_not == nil
        article_parts[:date].should_not == nil
        article_parts[:filename].should_not == nil
      end
    end
  end # Access all content
end