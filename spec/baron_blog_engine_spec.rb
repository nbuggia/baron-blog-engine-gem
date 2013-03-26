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
      @blog_engine.get_system_resource('redirects.txt').should == SAMPLE_DATA_PATH + 'resources/redirects.txt'
      @blog_engine.get_system_resource('robots.txt').should == SAMPLE_DATA_PATH + 'resources/robots.txt'
      @blog_engine.get_system_resource('feeds.atom').should == SAMPLE_DATA_PATH + 'resources/feeds.atom'
    end 
    
    it "finds all categories" do
      categories = @blog_engine.get_all_categories
      categories.count.should == 4
      categories.first[:name].should == 'Favorites'
      categories.first[:path].should == '/favorites/'
      categories.first[:count].should == 1
      categories.last[:name].should == 'Other Authors'
      categories.last[:path].should == '/other-authors/'
      categories.last[:count].should == 1
    end

    # todo, refactor to break out testing that we're appropriately breaking the fileparts down

    it "finds all articles" do
      articles_fileparts = @blog_engine.get_all_articles()
      articles_fileparts.count.should == 7
    end
    
    it "parses all article fileparts" do
      articles_fileparts = @blog_engine.get_all_articles()
      articles_fileparts[0][:filename_and_path].should == SAMPLE_DATA_PATH + 'articles/favorites/1916-01-01-the-road-not-taken.txt' 
      articles_fileparts[0][:date].should == '1916-01-01' 
      articles_fileparts[0][:filename].should == 'the-road-not-taken' 
      articles_fileparts[0][:category].should == 'favorites'
      articles_fileparts[1][:filename_and_path].should == SAMPLE_DATA_PATH + 'articles/north of boston/1914-01-05-A-Hundred-callers.txt' 
      articles_fileparts[1][:date].should == '1914-01-05' 
      articles_fileparts[1][:filename].should == 'a-hundred-callers' 
      articles_fileparts[1][:category].should == 'north of boston'
      articles_fileparts.last[:filename_and_path].should == SAMPLE_DATA_PATH + 'articles/other authors/1909-01-02-If.txt' 
      articles_fileparts.last[:date].should == '1909-01-02' 
      articles_fileparts.last[:filename].should == 'if' 
      articles_fileparts.last[:category].should == 'other authors' 
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