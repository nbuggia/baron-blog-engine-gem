module Baron

  class PageController
    def initialize articles_parts, categories, max_articles, params, theme, config
      @categories, @params, @theme, @config = categories, params, theme, config
      stop_at = (:all == max_articles) ? articles_parts.count : max_articles
      @articles = articles_parts.take(stop_at).map { |file_parts| Article.new(file_parts, @config) }
      @article = @articles.first
    end
    
    def render_html partial_template, layout_template
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
  
end