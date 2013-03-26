require_relative '../lib/baron'

GOOGLE_ANALYTICS = 'UA-XXXXXX-X'
GOOGLE_WEBMASTER = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
SAMPLE_DATA_PATH = 'spec/sample_data/'    # must contain a trailing slash

def load_config
  Baron::Config.new(:markdown => true,
                    :title => 'my blog',
                    :author => 'John Smith',
                    :url => 'http://localhost/',
                    :permalink_prefix => '',
                    :permalink_date_format => :year_month_day_date, # :year_date, :year_month_date, :year_month_day_date, :no_date
                    :article_max => 5,
                    :theme => 'typography',
                    :sample_data_path => SAMPLE_DATA_PATH,
                    :google_analytics => GOOGLE_ANALYTICS,
                    :google_webmaster => GOOGLE_WEBMASTER)
end