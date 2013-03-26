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
      @article[:filename_and_path].should == @article_parts[:filename_and_path]
      @article[:date].should be_instance_of(Date)
      @article[:category].should == @article_parts[:category]
    end
    
    it "should return article data correctly" do
      @article[:title].should == 'The Road Not Taken'
      @article.title.should == 'The Road Not Taken'
      @article.date.should == '01/01/1916'
      @article.date_iso8601.should == '1916-01-01T00:00:00+00:00'
      @article[:author].should == 'Robert Frost'
      @article.author.should == 'Robert Frost'
      @article[:body].length.should > 0
      @article[:category].should == 'poems'
      @article.category.should == 'poems'
      @article[:slug].should == 'the-road-not-taken'
      @article.slug.should == 'the-road-not-taken'   
    end
    
    it "should handle different path configuations" do
      @article.path('', :no_date).should == '/poems/the-road-not-taken/'
      @article.path('', :year_month_day_date).should == '/poems/1916/01/01/the-road-not-taken/'
      @article.path('', :year_month_date).should == '/poems/1916/01/the-road-not-taken/'
      @article.path('', :year_date).should == '/poems/1916/the-road-not-taken/'
      @article.path('posts', :no_date).should == '/posts/poems/the-road-not-taken/'
      @article.path('posts', :year_month_day_date).should == '/posts/poems/1916/01/01/the-road-not-taken/'
      @article.path('posts', :year_month_date).should == '/posts/poems/1916/01/the-road-not-taken/'
      @article.path('posts', :year_date).should == '/posts/poems/1916/the-road-not-taken/'
      @article.path('/foo/bar/', :no_date).should == '/foo/bar/poems/the-road-not-taken/'
      @article.path('/foo/bar/', :year_month_day_date).should == '/foo/bar/poems/1916/01/01/the-road-not-taken/'
      @article.path('/foo/bar/', :year_month_date).should == '/foo/bar/poems/1916/01/the-road-not-taken/'
      @article.path('/foo/bar/', :year_date).should == '/foo/bar/poems/1916/the-road-not-taken/'
    end
  end
end
