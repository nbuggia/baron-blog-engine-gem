module Baron
  
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
    
    def title
      self[:title] || 'Untitled'
    end
    
    def date
      @config[:date].call(self[:date])
    end

    def date_iso8601
      # "2009-10-26T04:47:09Z"
      self[:date].strftime("%FT%T%:z")
    end
    
    def author
      self[:author] || @config[:author]
    end
    
    def category
      self[:category]
    end
    
    def permalink
      "http://#{(@config[:url].sub("http://", '') + self.path).squeeze('/')}"
    end
    
    def slug
      self[:slug]
    end
    
    protected 
    
    def load_article filename_and_path
      metadata, self[:body] = File.read(filename_and_path).split(/\n\n/, 2)
      YAML.load(metadata).each_pair { |key, value| self[key.downcase.to_sym] = value }
    end
    
    def markdown text
      if (options = @config[:markdown])
        Markdown.new(text.to_s.strip, *(options.eql?(true) ? [] : options)).to_html
      else
        text.strip
      end
    end

  end

end