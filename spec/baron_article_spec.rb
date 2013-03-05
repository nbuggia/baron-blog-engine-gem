require 'spec_helper'

###
# Tests Baron::ArticleModel class
#
# This class represents an individual article

describe "Baron::ArticleModel" do
  before :all do
    @config = load_config()
    @article_parts = {:filename_and_path => "#{SAMPLE_DATA_PATH}articles/poems/1916-01-01-the-road-not-taken.txt", 
                      :date => '1916-01-01', 
                      :filename => 'the-road-not-taken', 
                      :category => 'poems'}
    @article = Baron::Article.new(@article_parts, @config)
  end
  
  describe "Provides access to properties" do
    it "should return input parameters" do
      @article[:filename_and_path].should eq(@article_parts[:filename_and_path])
      @article[:date].should be_instance_of(Date)
      @article[:category].should eq(@article_parts[:category])
    end
    
    it "should return article data correctly" do
      @article[:title].should eq('The Road Not Taken')
      @article.title.should eq('The Road Not Taken')
      @article[:author].should eq('Robert Frost')
      @article.author.should eq('Robert Frost')
      @article[:body].length.should > 0
      @article[:category].should eq('poems')
      @article.category.should eq('poems')
      @article[:slug].should eq('the-road-not-taken')
      @article.slug.should eq('the-road-not-taken')      
    end
    
    it "should handle different path configuations" do
      @article.path('', :no_date).should eq('/poems/the-road-not-taken/')
      @article.path('', :year_month_day_date).should eq('/poems/1916/01/01/the-road-not-taken/')
      @article.path('', :year_month_date).should eq('/poems/1916/01/the-road-not-taken/')
      @article.path('', :year_date).should eq('/poems/1916/the-road-not-taken/')
      @article.path('posts', :no_date).should eq('/posts/poems/the-road-not-taken/')
      @article.path('posts', :year_month_day_date).should eq('/posts/poems/1916/01/01/the-road-not-taken/')
      @article.path('posts', :year_month_date).should eq('/posts/poems/1916/01/the-road-not-taken/')
      @article.path('posts', :year_date).should eq('/posts/poems/1916/the-road-not-taken/')
      @article.path('/foo/bar/', :no_date).should eq('/foo/bar/poems/the-road-not-taken/')
      @article.path('/foo/bar/', :no_date).should eq('/foo/bar/poems/the-road-not-taken/')
      @article.path('/foo/bar/', :year_month_day_date).should eq('/foo/bar/poems/1916/01/01/the-road-not-taken/')
      @article.path('/foo/bar/', :year_month_date).should eq('/foo/bar/poems/1916/01/the-road-not-taken/')
      @article.path('/foo/bar/', :year_date).should eq('/foo/bar/poems/1916/the-road-not-taken/')
    end
  end
end
