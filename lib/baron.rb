$:.unshift File.dirname(__FILE__)

# std libs
require 'yaml'
require 'date'
require 'erb'
require 'time'

# 3rd party
require 'rack'
require 'digest'
require 'rdiscount'

# baron specific
require 'baron/page_controller'
require 'baron/blog_engine'
require 'baron/config'
require 'baron/models/article'
require 'baron/models/theme'

module Baron
  def self.env      
    ENV['RACK_ENV'] || 'production'   
  end
  
  def self.env= env  
    ENV['RACK_ENV'] = env             
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
      
      path, ext = @request.path_info.split('.')
      extension = ext.to_s.empty? ? '.html' : ".#{ext}"

      redirected_url, status = @blog_engine.process_redirects(@request.path_info)

      if status
        @response.status = status
        @response['Location'] = redirected_url
      else
        baron_response = @blog_engine.process_request(@request.path_info, env)
        @response.body = [baron_response[:body]]
        @response.status = baron_response[:status]      
        @response['Content-Length'] = baron_response[:body].bytesize.to_s unless baron_response[:body].empty?
        @response['Content-Type'] = Rack::Mime.mime_type(extension)
        @response['Cache-Control'] = (Baron.env == 'production') ? "public, max-age=#{@config[:cache]}" : "no-cache, must-revalidate"
        @response['ETag'] = %("#{Digest::SHA1.hexdigest(baron_response[:body])}")
      end
      
      @response.finish
    end
  end
end