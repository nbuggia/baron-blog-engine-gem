#
# Baron configuration

require 'baron'

baron = Baron::Server.new do
  #
  # Add your settings here
  # set [:setting], [value]
  # 
  # set :author,                  ENV['USER']                               # blog author
  # set :title,                   Dir.pwd.split('/').last                   # site title
  # set :root,                    "index"                                   # page to load on /
  # set :date,                    lambda {|now| now.strftime("%d/%m/%Y") }  # date format for articles
  # set :markdown,                :smart                                    # use markdown + smart-mode
  # set :disqus,                  false                                     # disqus id, or false
  # set :summary,                 :max => 150, :delim => /~/                # length of article summary and delimiter
  # set :ext,                     'txt'                                     # file extension for articles
  # set :cache,                   28800                                     # cache duration, in seconds
  # set :custom_pages             "about, contact-us"                       # custom pages, should match filename
  # set :permalink_prefix,        ""                                        # common path prefix for article permalinks
  # set :permalink_date_format,   :no_date,                                 # :year_date, :year_month_date, :year_month_day_date, :no_date
  
  set :disqus, true
  set :title, 'test blog'
  set :date, lambda {|now| now.strftime("%B #{now.day.ordinal} %Y") }
  set :permalink_prefix, 'posts'
  set :theme, 'test'
  set :permalink_date_format, :no_date
  set :article_max, 2
end

#
# Rack configuration

use Rack::Static, :urls => ['/themes', '/downloads', '/images']
use Rack::CommonLogger

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end

# RUN!
run baron


