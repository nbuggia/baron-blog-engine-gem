require 'spec_helper'

##
# Integration testing for the Baron Blog Engine to make sure things are
# working end-to-end

shared_examples_for "Server Response" do
  it "should be valid" do
    expect(@response.status).to eq(200)
    expect(@response.body.length).to be > 0
  end
end

shared_examples_for "Server HTML Response" do
  it "should be instrumented" do
    expect(@response.body).to include(GOOGLE_ANALYTICS) unless GOOGLE_ANALYTICS.empty?
  end

  it "returns HTML content type" do
      expect(@response['Content-Type']).to eq('text/html')
  end
  
  it "should generate valid HTML" do
    expect(@response.body.scan(/<html/).count).to eq(1)
    expect(@response.body.scan(/<\/html>/).count).to eq(1)
    expect(@response.body.scan(/<head>/).count).to eq(1)
    expect(@response.body.scan(/<\/head>/).count).to eq(1)
    expect(@response.body.scan(/<body/).count).to eq(1)
    expect(@response.body.scan(/<\/body>/).count).to eq(1)
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
      expect(@response.body).to include(GOOGLE_WEBMASTER) unless GOOGLE_WEBMASTER.empty?
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
      expect(@baron.get('/page/0/').status).to eq(404)
      expect(@baron.get('/page/100/').status).to eq(404)
    end
    
    it "should not render a mal-formed URL" do
      expect(@baron.get('/page/foobar/').status).to eq(404)
    end

    it "should render a valid request" do
      response = @baron.get('/page/2/')
      expect(response.status).to eq(200)
      expect(response.body.length).to be > 0
      expect(response.body).to include(GOOGLE_WEBMASTER) unless GOOGLE_WEBMASTER.empty?
    end
  end
  
  describe "GET error page" do
    it "returns proper error data" do
      response = @baron.get('/fake-url-of-impossible-page-give-me-your-404-error')
      expect(response.status).to eq(404)
      expect(response.body).to include('Page not found')
      expect(response.body).to include('404')
      # Should not render in the layout.rhtml if <html is in the first 100 chars
      expect(response.body).to_not include("<meta name=\"description\" content="">")
    end
    
  end
  
  describe "GET /feed.atom" do    
    before :all do
      @response = @baron.get('/feed.atom')
    end
    
    it_behaves_like "Server Response"
    
    it "returns expected content" do
      expect(@response.body).to include(@config[:title])
      expect(@response.body).to include("http://localhost/feed.atom")
      expect(@response.body.scan(/<entry>/).count).to eq(5)
      expect(@response.body.scan(/<\/entry>/).count).to eq(5)
      expect(@response.body).to include('<feed')
      expect(@response.body).to include('</feed>')
    end
    
    it "returns atom content type" do
      expect(@response['Content-Type']).to eq('application/atom+xml')
    end
  end
  
  describe "GET /robots.txt" do
    before :all do
      @response = @baron.get('/robots.txt')
    end
    
    it_behaves_like "Server Response"
    
    it "returns text content type" do
      expect(@response['Content-Type']).to eq('text/plain')
    end
  end
  
  describe "Redirect URLs" do
    it "should canonicalize pagination at page 1" do
      @response = @baron.get('/page/1/')
      expect(@response.status).to eq(301)
      expect(@response['Location']).to eq('/')

      @response = @baron.get('/page/1')
      expect(@response.status).to eq(301)
      expect(@response['Location']).to eq('/')
    end    
  end

end