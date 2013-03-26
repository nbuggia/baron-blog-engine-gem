module Baron

  class Config < Hash
    
    Defaults = {

      # cache duration (seconds)
      :cache => 28800,
      
      # token to represent root in the app
      :root => 'home',

      # used by the RSpec tests to show where the sample data is stored
      :sample_data_path => '',
      
      # default name to use for the blog's author
      :author => ENV['USER'],

      # default title for the site
      :title => Dir.pwd.split('/').last,

      # used to divide the different elements of the page title
      :title_delimiter => "&rsaquo;",
      
      # symbol used to represent trucated text (article summary)
      :truncation_marker => '&hellip;',

      # root URL of the site
      :url => 'http://localhost:3000/',

      # date function block
      :date => lambda {|now| now.strftime("%d/%m/%Y") },

      # use markdown
      :markdown => :smart,

      # length of summary and delimiter
      :summary => {:max => 150, :delim => /~\n/},

      # extension for article files
      :ext => 'txt',

      # common path prefix for article permalinks
      :permalink_prefix => '',

      # :year_date, :year_month_date, :year_month_day_date, :no_date
      :permalink_date_format => :year_month_day_date,

      # number of most recent articles to return to custom pages
      :article_max => 5,

      # name of the theme to use         
      :theme => 'default',

      # account id for google analytics account  
      :google_analytics => '',

      # HTML Meta Tag verification code for google webmaster account
      :google_webmaster => '',

      # account name for your disqus account www.disqus.com
      :disqus_shortname => false
    }

    def get_feed_permalink
      "#{self[:url]}feed.atom"
    end 

    def initialize obj
      self.update Defaults
      self.update obj
    end

    def set key, val = nil, &block
      if val.is_a? Hash
        self[key].update val
      else
        self[key] = block_given?? block : val
      end
    end

  end # Config
  
end