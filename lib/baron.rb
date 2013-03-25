$:.unshift File.dirname(__FILE__)

# std libs
require 'yaml'
require 'date'
require 'erb'

# 3rd party
require 'rack'
require 'digest'
require 'rdiscount'

# baron specific
require 'baron/utils'
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