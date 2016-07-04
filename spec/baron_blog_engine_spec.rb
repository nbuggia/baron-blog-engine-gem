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
      expect(@blog_engine.get_pages_path).to eq(SAMPLE_DATA_PATH + 'pages/')
      expect(@blog_engine.get_articles_path).to eq(SAMPLE_DATA_PATH + 'articles')
      expect(@blog_engine.get_page_template('about')).to eq(SAMPLE_DATA_PATH + 'pages/about.rhtml')
      expect(@blog_engine.get_system_resource('redirects.txt')).to eq(SAMPLE_DATA_PATH + 'resources/redirects.txt')
      expect(@blog_engine.get_system_resource('robots.txt')).to eq(SAMPLE_DATA_PATH + 'resources/robots.txt')
      expect(@blog_engine.get_system_resource('feeds.atom')).to eq(SAMPLE_DATA_PATH + 'resources/feeds.atom')
    end 
    
    it "finds all categories" do
      categories = @blog_engine.get_all_categories
      expect(categories.count).to eq(3)
      expect(categories.first[:name]).to eq('Favorites')
      expect(categories.first[:path]).to eq('/favorites/')
      expect(categories.first[:count]).to eq(1)
      expect(categories.last[:name]).to eq('Other Authors')
      expect(categories.last[:path]).to eq('/other-authors/')
      expect(categories.last[:count]).to eq(1)
    end

    # todo, refactor to break out testing that we're appropriately breaking the fileparts down

    it "finds all articles" do
      articles_fileparts = @blog_engine.get_all_articles()
      expect(articles_fileparts.count).to eq(7)
    end
    
    it "parses all article fileparts" do
      articles_fileparts = @blog_engine.get_all_articles()
      expect(articles_fileparts[0][:filename_and_path]).to eq(SAMPLE_DATA_PATH + 'articles/favorites/1916-01-01-the-road-not-taken.txt')
      expect(articles_fileparts[0][:date]).to eq('1916-01-01')
      expect(articles_fileparts[0][:filename]).to eq('the-road-not-taken')
      expect(articles_fileparts[0][:category]).to eq('favorites')
      expect(articles_fileparts[1][:filename_and_path]).to eq(SAMPLE_DATA_PATH + 'articles/north of boston/1914-01-05-A-Hundred-callers.txt')
      expect(articles_fileparts[1][:date]).to eq('1914-01-05')
      expect(articles_fileparts[1][:filename]).to eq('a-hundred-callers')
      expect(articles_fileparts[1][:category]).to eq('north of boston')
      expect(articles_fileparts.last[:filename_and_path]).to eq(SAMPLE_DATA_PATH + 'articles/other authors/1909-01-02-If.txt')
      expect(articles_fileparts.last[:date]).to eq('1909-01-02') 
      expect(articles_fileparts.last[:filename]).to eq('if')
      expect(articles_fileparts.last[:category]).to eq('other authors')
    end
        
    it "returns all article parts" do
      @blog_engine.get_all_articles().each do |article_parts|
        expect(article_parts[:filename_and_path]).not_to eq(nil)
        expect(article_parts[:date]).not_to eq(nil)
        expect(article_parts[:filename]).not_to eq(nil)
      end
    end
  end # Access all content
end