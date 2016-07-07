require 'spec_helper'

###
# Tests Baron::Article class
#
# This class represents an individual article

describe "Baron::Article" do
  before :all do
    @config = load_config()
    @article_parts = {:filename_and_path => "#{SAMPLE_DATA_PATH}articles/favorites/1916-01-01-the-road-not-taken.txt", 
                      :date => '1916-01-01', 
                      :filename => 'the-road-not-taken', 
                      :category => 'poems'}
    @article = Baron::Article.new(@article_parts, @config)
  end
  
  describe "Provides access to properties" do
    it "should return input parameters" do
      expect(@article[:filename_and_path]).to eq(@article_parts[:filename_and_path])
      expect(@article[:date]).to be_instance_of(Date)
      expect(@article[:category]).to eq(@article_parts[:category])
    end
    
    it "should return article data correctly" do
      expect(@article[:title]).to eq('The Road Not Taken')
      expect(@article.title).to eq('The Road Not Taken')
      expect(@article.date).to eq('01/01/1916')
      expect(@article.date_iso8601).to eq('1916-01-01T00:00:00+00:00')
      expect(@article[:author]).to eq('Robert Frost')
      expect(@article.author).to eq('Robert Frost')
      expect(@article[:body].length).to be > 0
      expect(@article[:category]).to eq('poems')
      expect(@article.category).to eq('poems')
      expect(@article[:slug]).to eq('the-road-not-taken')
      expect(@article.slug).to eq('the-road-not-taken')
    end
    
    it "should handle different path configuations" do
      expect(@article.path('', :no_date)).to eq('/poems/the-road-not-taken/')
      expect(@article.path('', :year_month_day_date)).to eq('/poems/1916/01/01/the-road-not-taken/')
      expect(@article.path('', :year_month_date)).to eq('/poems/1916/01/the-road-not-taken/')
      expect(@article.path('', :year_date)).to eq('/poems/1916/the-road-not-taken/')
      expect(@article.path('posts', :no_date)).to eq('/posts/poems/the-road-not-taken/')
      expect(@article.path('posts', :year_month_day_date)).to eq('/posts/poems/1916/01/01/the-road-not-taken/')
      expect(@article.path('posts', :year_month_date)).to eq('/posts/poems/1916/01/the-road-not-taken/')
      expect(@article.path('posts', :year_date)).to eq('/posts/poems/1916/the-road-not-taken/')
      expect(@article.path('/foo/bar/', :no_date)).to eq('/foo/bar/poems/the-road-not-taken/')
      expect(@article.path('/foo/bar/', :year_month_day_date)).to eq('/foo/bar/poems/1916/01/01/the-road-not-taken/')
      expect(@article.path('/foo/bar/', :year_month_date)).to eq('/foo/bar/poems/1916/01/the-road-not-taken/')
      expect(@article.path('/foo/bar/', :year_date)).to eq('/foo/bar/poems/1916/the-road-not-taken/')
    end

    it "should create values correctly" do
      expect(Baron::Article.create_slug "B's Cookies & Cream 2,3,4", Date.new(2016,6,15)).to eq("2016-06-15-b-s-cookies---cream-2-3-4")
    end

  end
end