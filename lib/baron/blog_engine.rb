module Baron

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
    
    def process_request path, env = {}
      route = (path || '/').split('/').reject { |i| i.empty? }
      route << @config[:root] if route.empty?
      categories = get_all_categories
      params = {:page_name => route.first, :feed_permalink => @config.get_feed_permalink}
      params[:page_title] = (route.first == @config[:root] ? '' : "#{route.first.capitalize} #{@config[:title_delimiter]} ") + "#{@config[:title]}"          
      theme = Theme.new(@config)
      theme.load_config
    
      begin
        # Atom feed /feed.atom
        body = if route.first == 'feed.atom'
          PageController.new(get_all_articles, categories, @config[:article_max], params, theme, @config) . 
            render(get_system_resource('feed.atom'))
            
        # Robots /robots.txt
        elsif route.first == 'robots.txt'
          PageController.new(get_all_articles, categories, @config[:article_max], params, theme, @config) . 
            render(get_system_resource('robots.txt'))
        
        # Home page /
        elsif route.first == @config[:root]
          all_articles = get_all_articles
          params[:page_forward] = '/page/2/' if @config[:article_max] < all_articles.count
          PageController.new(all_articles, categories, @config[:article_max], params, theme, @config) . 
            render_html(theme.get_template(route.first), theme.get_template('layout'))
            
        # Pagination /page/2, /page/2/
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
          
          PageController.new(articles_on_this_page, categories, @config[:article_max], params, theme, @config) . 
            render_html(theme.get_template('home'), theme.get_template('layout'))
        
        # System routes /robots.txt, /archives
        elsif route.first == 'archives' or route.first == 'robots'
          max_articles = ('archives' == route.first) ? :all : @config[:article_max]
          PageController.new(get_all_articles, categories, max_articles, params, theme, @config) . 
            render_html(theme.get_template(route.first), theme.get_template('layout'))
        
        # Custom pages /about, /contact-us
        elsif is_route_custom_page? route.first
          PageController.new(get_all_articles, categories, @config[:article_max], params, theme, @config) . 
            render_html(get_page_template(route.first), theme.get_template('layout'))
      
        # Category home pages /projects/, /photography/, /poems/, etc
        elsif is_route_category_home? route.last
          filtered_articles = get_all_articles.select { |h| h[:category] == route.last }
          params[:page_name] = titlecase(route.last.gsub('-', ' '))
          PageController.new(filtered_articles, categories, :all, params, theme, @config) .
            render_html(theme.get_template('category'), theme.get_template('layout'))
      
        # Articles /posts/2013/01/18/my-article-title, /posts/category/2013/my-article-title, etc
        else
          article = [ find_single_article(route.last) ]
          params[:page_title] = "#{titlecase(article.first[:filename].gsub('-',' '))} #{@config[:title_delimiter]} #{@config[:title]}"
          PageController.new(article, categories, 1, params, theme, @config) .
            render_html(theme.get_template('article'), theme.get_template('layout'))
        end

        return { body: body, status: 200 }
      
      rescue Errno::ENOENT => e     
        # 404 Page Not Found
        params[:error_message] = 'Page not found'
        params[:error_code] = '404'
        body = PageController.new([], categories, 0, params, theme, @config) .
                render_html(theme.get_template('error'), theme.get_template('layout'))
        return { body: body, status: 404 }
      end 
    end

    def get_all_category_folder_paths
      category_paths = Dir["#{get_articles_path}/*/"].map do |a| 
        "#{get_articles_path}/#{File.basename(a)}"
      end
      # includes the default articles directory as an unnamed (e.g. empty) path
      category_paths << "#{get_articles_path}"
    end

    def get_all_articles
      get_all_category_folder_paths.map do |folder_name|
        Dir["#{folder_name}/*"].map do |e|
          if e.end_with? @config[:ext]
            parts = e.split('/')
            {
              filename_and_path: e,
              date: parts.last[0..9],
              # trims date and extention 
              filename: parts.last[11..(-1 * (@config[:ext].length + 2))].downcase,
              filename_without_extension: parts.last[0..(-1 * (@config[:ext].length + 2))].downcase,
              category: parts[parts.count-2] == 'articles' ? '' : parts[parts.count-2]
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
          name: titlecase(folder_name),
          node_name: folder_name.gsub(' ', '-'),
          path: "/#{@config[:permalink_prefix]}/#{folder_name.gsub(' ', '-')}/".squeeze('/'),
          count: Dir["#{get_articles_path}/#{folder_name}/*"].count,
          top_articles: [ filename: "foobar", filename: "foobar2" ]
        }
      end .
        sort_by { |hash| hash[:name] }
    end

    # TODO: refactor. Does the same thing as 'get all articles'
    # Returns the most recent 5 articles for each category as a hash
    #
    # category - the node_name for the category
    def get_top_articles category
      Dir["#{get_articles_path}/#{category}/*"].map do |e|
         if e.end_with? @config[:ext]
             parts = e.split('/')
             {
               #filename_and_path: e,
               #date: parts.last[0..9],
               # trims date and extention 
               #filename: parts.last[11..(-1 * (@config[:ext].length + 2))].downcase,
               filename_without_extension: parts.last[0..(-1 * (@config[:ext].length + 2))].downcase,
               #category: parts[parts.count-2] == 'articles' ? '' : parts[parts.count-2]
             }
         end
       end .
         #flatten .
         delete_if { |a| a == nil } .
         sort_by { |hash| hash[:date] } .
         reverse . # sorts by decending date 
         take(5)
    end

    def find_single_article article_slug
      get_all_articles.each do |fileparts| 
        return fileparts if fileparts[:filename] == article_slug
      end
      raise Errno::ENOENT, 'Article not found'
    end    
    
    def is_route_custom_page? path_node
      (Dir["#{get_pages_path}/*"]).include?("#{get_pages_path}/#{path_node}.rhtml")
    end
    
    def is_route_category_home? path_node
      get_all_categories.each { |h| return true if h[:node_name] == path_node }
      return false
    end

    def get_pages_path
      "#{@config[:sample_data_path]}pages/"
    end
    
    def get_articles_path
      "#{@config[:sample_data_path]}articles".squeeze('/')
    end
      
    def get_page_template name
      "#{@config[:sample_data_path]}pages/#{name}.rhtml".squeeze('/')
    end
    
    def get_system_resource name
      "#{@config[:sample_data_path]}resources/#{name}".squeeze('/')
    end

    private

    # Capitalize the first letter of each word in a string
    def titlecase str
      str.split(/(\W)/).map(&:capitalize).join       
    end  
  end

end