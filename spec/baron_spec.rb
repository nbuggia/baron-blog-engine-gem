require 'spec_helper'

##
# Integration testing for the Baron Blog Engine to make sure things are
# working end-to-end

shared_examples_for "Server Response" do
  it "should be valid" do
    @response.status.should == 200
    @response.body.length.should > 0
  end
end

shared_examples_for "Server HTML Response" do
  it "should be instrumented" do
    @response.body.should include(GOOGLE_ANALYTICS) unless GOOGLE_ANALYTICS.empty?
  end

  it "returns HTML content type" do
      @response['Content-Type'].should == 'text/html'
  end
  
  it "should generate valid HTML" do
    @response.body.scan(/<html/).count.should == 1
    @response.body.scan(/<\/html>/).count.should == 1
    @response.body.scan(/<head>/).count.should == 1
    @response.body.scan(/<\/head>/).count.should == 1
    @response.body.scan(/<body/).count.should == 1
    @response.body.scan(/<\/body>/).count.should == 1
  end
end

describe "Baron" do  
  before :all do
    @config = load_config
    @baron = Rack::MockRequest.new(Baron::Server.new(@config))
  end

  describe "GET /" do
    before :all do
      @response = @baron.get('/')
    end
    
    it_behaves_like "Server Response"
    it_behaves_like "Server HTML Response"
    
    it "is instrumented for Google Webmaster Tools" do
      @response.body.should include(GOOGLE_WEBMASTER) unless GOOGLE_WEBMASTER.empty?
    end    
  end
  
  describe "GET /archives" do
    before :all do
      @response = @baron.get('/archives')
    end

    it_behaves_like "Server Response"
    it_behaves_like "Server HTML Response"    
  end

  describe "GET custom page" do
    before :all do
      @response = @baron.get('/about')
    end

    it_behaves_like "Server Response"
    it_behaves_like "Server HTML Response"    
  end

  describe "GET category home page" do
    before :all do
      @response = @baron.get('/north-of-boston/')
    end

    it_behaves_like "Server Response"
    it_behaves_like "Server HTML Response"
  end
        
  describe "GET single article" do    
    before :all do
      @response = @baron.get('/poems/the-road-not-taken')
    end
    
    it_behaves_like "Server Response"
    it_behaves_like "Server HTML Response"    
  end
  
  describe "GET pagination" do
    before :all do
      config = load_config()
      config.set(:article_max, 2)
      @baron = Rack::MockRequest.new(Baron::Server.new(config))
    end
    
    it "should not render a page out of bounds" do
      @baron.get('/page/0/').status.should == 404
      @baron.get('/page/100/').status.should == 404
    end
    
    it "should not render a mal-formed URL" do
      @baron.get('/page/foobar/').status.should == 404
    end

    it "should render a valid request" do
      response = @baron.get('/page/2/')
      response.status.should == 200
      response.body.length.should > 0
      response.body.should include(GOOGLE_WEBMASTER) unless GOOGLE_WEBMASTER.empty?
    end
  end
  
  describe "GET error page" do
    it "returns proper error data" do
      response = @baron.get('/fake-url-of-impossible-page-give-me-your-404-error')
      response.status.should == 404
      response.body.should include('Page not found')
      response.body.should include('404')
      # should not render in the layout.rhtml if <html is in the first 100 chars
      response.body.should_not include("<meta name=\"description\" content="">")
    end
    
  end
  
  describe "GET /feed.atom" do    
    before :all do
      @response = @baron.get('/feed.atom')
    end
    
    it_behaves_like "Server Response"
    
    it "returns expected content" do
      @response.body.should include(@config[:title])
      @response.body.should include("http://localhost/feed.atom")
      @response.body.scan(/<entry>/).count.should == 5
      @response.body.scan(/<\/entry>/).count.should == 5
      @response.body.should include('<feed')
      @response.body.should include('</feed>')
    end
    
    it "returns atom content type" do
      @response['Content-Type'].should == 'application/atom+xml'
    end
  end
  
  describe "GET /robots.txt" do
    before :all do
      @response = @baron.get('/robots.txt')
    end
    
    it_behaves_like "Server Response"
    
    it "returns text content type" do
      @response['Content-Type'].should == 'text/plain'
    end
  end
  
  describe "Redirect URLs" do
    it "should canonicalize pagination at page 1" do
      @response = @baron.get('/page/1/')
      @response.status.should == 301
      @response['Location'].should == '/'
      @response = @baron.get('/page/1')
      @response.status.should == 301
      @response['Location'].should == '/'
    end    
  end
  
  # add a method to test CSS, and a downloaded file, like a ppt

  describe "Helper Functions" do
    it "should return a titleized string" do
      "the quick red fox".titleize.should == "The Quick Red Fox"
    end
  end
  
end
