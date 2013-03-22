require 'yaml'
require 'date'
require 'erb'
require 'rack'
require 'digest'
require 'rdiscount'

$:.unshift File.dirname(__FILE__)

# Converts a number into an ordinal, 1=>1st, 2=>2nd, 3=>3rd, etc
class Fixnum
  def ordinal
    case self % 100
      when 11..13; "#{self}th"
    else
      case self % 10
        when 1; "#{self}st"
        when 2; "#{self}nd"
        when 3; "#{self}rd"
        else    "#{self}th"
      end
    end
  end
end

# Avoid a collision with ActiveSupport
class Date
  unless respond_to? :iso8601
    # Return the date as a String formatted according to ISO 8601.
    def iso8601
      ::Time.utc(year, month, day, 0, 0, 0, 0).iso8601
    end
  end
end

class String
  # Support String::bytesize in old versions of Ruby
  if RUBY_VERSION < "1.9"
    def bytesize
      size
    end
  end
  
  # Capitalize the first letter of each word in a string
  def titleize     
    self.split(/(\W)/).map(&:capitalize).join       
  end
end

module Baron
  def self.env      
    ENV['RACK_ENV'] || 'production'   
  end
  
  def self.env= env  
    ENV['RACK_ENV'] = env             
  end
  
  class PageController
    def initialize articles_parts, categories, max_articles, params, config
      @categories, @params, @config = categories, params, config
      stop_at = (:all == max_articles) ? articles_parts.count : max_articles
      @articles = articles_parts.take(stop_at).map { |file_parts| Article.new(file_parts, @config) }
      @article = @articles.first
    end
    
    def render_html partial_template, layout_template
      @theme_root = "/themes/#{@config[:theme]}"
      @content = ERB.new(File.read(partial_template)).result(binding)
      if @content[0..99].include? '<html'
        return @content
      else
        ERB.new(File.read(layout_template)).result(binding)
      end 
    end
    
    def render_rss template
      ERB.new(File.read(template)).result(binding)
    end
  end
    
  class BlogEngine
    def initialize config
      @config = config
    end

    def process_redirects request_path
      File.open(get_system_resource('redirects.txt'), 'r') do |file|
        file.each_line do |line|
          if line[0] != '#'
            command, status, source_path, destination_path = line.split(' ')
            return destination_path, status if request_path == source_path
          end
        end 
      end
    end
    
    def process_request path, env = {}, mime_type = :html
      route = (path || '/').split('/').reject { |i| i.empty? }
      route << @config[:root] if route.empty?
      mime_type = (mime_type =~ /txt|rss|json/) ? mime_type.to_sym : :html
      categories = get_all_categories
      params = {:page_name => route.first, :rss_feed => get_feed_path}
      params[:page_title] = (route.first == @config[:root] ? '' : "#{route.first.capitalize} #{@config[:title_delimiter]} ") + "#{@config[:title]}"          
    
      begin

        # RSS feed... /feed.rss
        body = if mime_type == :rss
          PageController.new(get_all_articles, categories, @config[:article_max], params, @config) . 
            render_rss(get_system_resource('feed.rss'))
            
        # Robots... /robots.txt
        elsif route.first == 'robots'
          PageController.new(get_all_articles, categories, @config[:article_max], params, @config) . 
            render_rss(get_system_resource('robots.txt'))
        
        # Home page... /
        elsif route.first == @config[:root]
          all_articles = get_all_articles
          params[:page_forward] = '/page/2/' if @config[:article_max] < all_articles.count
          PageController.new(all_articles, categories, @config[:article_max], params, @config) . 
            render_html(get_theme_template(route.first), get_theme_template('layout'))
            
        # Pagination... /page/2, /page/2/
        elsif route.first == 'page' && route.count == 2
          page_num = route.last.to_i rescue page_num = -1
          all_articles = get_all_articles
          max_pages = (all_articles.count.to_f / @config[:article_max].to_f).ceil
          raise(Errno::ENOENT, 'Page not found') if page_num < 1 or page_num > max_pages
          
          starting_article = ((page_num - 1) * @config[:article_max])
          articles_on_this_page = all_articles.slice(starting_article, @config[:article_max])

          show_next = (page_num * @config[:article_max]) < all_articles.count
          params[:page_back] = "/page/#{(page_num-1).to_s}/" if page_num > 1
          params[:page_forward] = "/page/#{(page_num+1).to_s}/" if show_next
          params[:page_title] = "Page #{page_num.to_s} #{@config[:title_delimiter]} #{@config[:title]}"
          
          PageController.new(articles_on_this_page, categories, @config[:article_max], params, @config) . 
            render_html(get_theme_template('home'), get_theme_template('layout'))
        
        # System routes... /robots.txt, /archives
        elsif route.first == 'archives' or route.first == 'robots'
          max_articles = ('archives' == route.first) ? :all : @config[:article_max]
          PageController.new(get_all_articles, categories, max_articles, params, @config) . 
            render_html(get_theme_template(route.first), get_theme_template('layout'))
        
        # Custom pages... /about, /contact-us
        elsif is_route_custom_page? route.first
          PageController.new(get_all_articles, categories, @config[:article_max], params, @config) . 
            render_html(get_page_template(route.first), get_theme_template('layout'))
      
        # Category home pages... /projects/, /photography/, /poems/, etc
        elsif is_route_category_home? route.last
          filtered_articles = get_all_articles.select { |h| h[:category] == route.last }
          params[:page_name] = route.last.gsub('-', ' ').titleize
          PageController.new(filtered_articles, categories, :all, params, @config) .
            render_html(get_theme_template('category'), get_theme_template('layout'))
      
        # Articles... /posts/2013/01/18/my-article-title, /posts/category/2013/my-article-title, etc
        else
          article = [ find_single_article(route.last) ]
          params[:page_title] = "#{article.first[:filename].gsub('-',' ').titleize} #{@config[:title_delimiter]} #{@config[:title]}"
          PageController.new(article, categories, 1, params, @config) .
            render_html(get_theme_template('article'), get_theme_template('layout'))
        end

        return :body => body, :type => mime_type, :status => 200
      
      rescue Errno::ENOENT => e
        
        # 404 Page Not Found
        params[:error_message] = 'Page not found'
        params[:error_code] = '404'
        body = PageController.new([], categories, 0, params, @config) .
                render_html(get_theme_template('error'), get_theme_template('layout'))
        
        return :body => body, :type => :html, :status => 404
      end 
    end

    def get_all_category_folder_paths
      category_paths = Dir["#{get_articles_path}/*/"].map { |a| "#{get_articles_path}/#{File.basename(a)}" }
      # includes the default articles directory as an unnamed (e.g. empty) path
      category_paths << "#{get_articles_path}"
    end

    def get_all_articles
      get_all_category_folder_paths.map do |folder_name|
        Dir["#{folder_name}/*"].map do |e|
          if e.end_with? @config[:ext]
            parts = e.split('/')
            {
              :filename_and_path => e,
              :date => parts.last[0..9],
              :filename => parts.last[11..(-1 * (@config[:ext].length + 2))].downcase,  # trims date and extention 
              :category => parts[parts.count-2] == 'articles' ? '' : parts[parts.count-2]
            }
          end
        end
      end .
        flatten .
        delete_if { |a| a == nil } .
        sort_by { |hash| hash[:date] } .
        reverse # sorts by decending date 
    end

    def get_all_categories
      Dir["#{get_articles_path}/*/"].map do |a| 
        folder_name = File.basename(a)
        {
          :name => folder_name.titleize,
          :node_name => folder_name.gsub(' ', '-'),
          :path => "/#{@config[:permalink_prefix]}/#{folder_name.gsub(' ', '-')}/".squeeze('/'),
          :count => Dir["#{get_articles_path}/#{folder_name}/*"].count 
        }
      end .
        sort_by { |hash| hash[:name] }
    end
    
    def find_single_article article_slug
      get_all_articles.each { |fileparts| return fileparts if fileparts[:filename] == article_slug }
      raise Errno::ENOENT, 'Article not found'
    end    
    
    def is_route_custom_page? path_node
      (Dir["#{get_pages_path}/*"]).include?("#{get_pages_path}/#{path_node}.rhtml")
    end
    
    def is_route_category_home? path_node
      get_all_categories.each { |h| return true if h[:node_name] == path_node }
      return false
    end

    def get_pages_path()          "#{@config[:sample_data_path]}pages/"                                             end
    def get_articles_path()       "#{@config[:sample_data_path]}articles"                                           end
    def get_page_template(name)   "#{@config[:sample_data_path]}pages/#{name}.rhtml"                                end
    def get_theme_template(name)  "#{@config[:sample_data_path]}themes/#{@config[:theme]}/templates/#{name}.rhtml"  end
    def get_system_resource(name) "#{@config[:sample_data_path]}resources/#{name}"                                  end
    def get_feed_path()           "#{@config[:url]}/feed.rss"                                                       end 
  end

  class Article < Hash
    def initialize file_parts, config = {}
      @config = config
      self[:filename_and_path] = file_parts[:filename_and_path]
      self[:slug] = file_parts[:filename]
      self[:category] = file_parts[:category].empty? ? '' : file_parts[:category]
      self[:date] = Date.parse(file_parts[:date].gsub('/', '-')) rescue Date.today
      load_article(file_parts[:filename_and_path])
    end
    
    def summary length = nil
      config = @config[:summary]
      sum = if self[:body] =~ config[:delim]
        self[:body].split(config[:delim]).first
      else
        self[:body].match(/(.{1,#{length || config[:length] || config[:max]}}.*?)(\n|\Z)/m).to_s
      end
      markdown(sum.length == self[:body].length ? sum : sum.strip.sub(/\.\Z/, @config[:truncation_marker]))
    end

    def body
      markdown self[:body].sub(@config[:summary][:delim], '') rescue markdown self[:body]
    end

    def path prefix = '', date_format = ''
      permalink_prefix = prefix.empty? ? @config[:permalink_prefix] : prefix
      permalink_date_format = date_format.empty? ? @config[:permalink_date_format] : date_format
      date_path = case permalink_date_format
      when :year_date; self[:date].strftime("/%Y")
      when :year_month_date; self[:date].strftime("/%Y/%m")
      when :year_month_day_date; self[:date].strftime("/%Y/%m/%d")
      else ''
      end
      
      "/#{permalink_prefix}/#{self[:category]}#{date_path}/#{slug}/".squeeze('/')      
    end
    
    def title()     self[:title] || 'Untitled'                                                end
    def date()      @config[:date].call(self[:date])                                          end
    def author()    self[:author] || @config[:author]                                         end
    def category()  self[:category]                                                           end
    def permalink() "http://#{(@config[:url].sub("http://", '') + self.path).squeeze('/')}"   end
    def slug()      self[:slug]                                                               end
    
    protected 
    
    def load_article filename_and_path
      metadata, self[:body] = File.read(filename_and_path).split(/\n\n/, 2)
      YAML.load(metadata).each_pair { |k,v| self[k.downcase.to_sym] = v }
    end
    
    def markdown text
      if (options = @config[:markdown])
        Markdown.new(text.to_s.strip, *(options.eql?(true) ? [] : options)).to_html
      else
        text.strip
      end
    end
  end

  class Config < Hash
    Defaults = {
      :cache => 28800,                                      # cache duration (seconds)
      :root => 'home',                                      # site home page
      :sample_data_path => '',                              # used by the RSpec tests to show where the sample data is stored
      :author => ENV['USER'],                               # blog author
      :title => Dir.pwd.split('/').last,                    # site title
      :title_delimiter => "&rsaquo;",                       # used to divide the different elements of the page title
      :truncation_marker => '&hellip;',                     # symbol used to represent trucated text (article summary)
      :url => 'http://localhost/',                          # root URL of the site
      :date => lambda {|now| now.strftime("%d/%m/%Y") },    # date function
      :markdown => :smart,                                  # use markdown
      :summary => {:max => 150, :delim => /~\n/},           # length of summary and delimiter
      :ext => 'txt',                                        # extension for articles
      :permalink_prefix => '',                              # common path prefix for article permalinks
      :permalink_date_format => :year_month_day_date,       # :year_date, :year_month_date, :year_month_day_date, :no_date
      :article_max => 5,                                    # number of most recent articles to return to custom pages
      :theme => 'default',                                  # name of the theme to use
      :google_analytics => '',                              # account id for google analytics account
      :google_webmaster => '',                              # HTML Meta Tag verification code for google webmaster account
      :disqus_shortname => false                            # account name for your disqus account www.disqus.com
    }

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
  end

  class Server
    attr_reader :config, :site

    def initialize config = {}, &block
      @config = config.is_a?(Config) ? config : Config.new(config)
      @config.instance_eval(&block) if block_given?
      @blog_engine = Baron::BlogEngine.new(@config)
    end

    def call env
      @request = Rack::Request.new env
      return [400, {}, []] unless @request.get?

      @response = Rack::Response.new
      path, mime = @request.path_info.split('.')     
      redirected_url, status = @blog_engine.process_redirects(path)

      if status
        @response.status = status
        @response['Location'] = redirected_url
      else
        baron_response = @blog_engine.process_request(path, env, *(mime ? mime : []))
        @response.body = [baron_response[:body]]
        @response.status = baron_response[:status]      
        @response['Content-Length'] = baron_response[:body].bytesize.to_s unless baron_response[:body].empty?
        @response['Content-Type'] = Rack::Mime.mime_type(".#{baron_response[:type]}")
        @response['Cache-Control'] = if Baron.env == 'production'
          "public, max-age=#{@config[:cache]}"
        else
          "no-cache, must-revalidate"
        end

        @response['ETag'] = %("#{Digest::SHA1.hexdigest(baron_response[:body])}")
      end
      
      @response.finish
    end
  end
end