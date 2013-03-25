module Baron
  class Theme < Hash
    def initialize config
      @config = config
      self[:root] = "/themes/#{config[:theme]}"
      self[:name] = config[:theme]
      self[:file_root] = "#{@config[:sample_data_path]}themes/#{@config[:theme]}".squeeze('/')
      self[:theme_config] = "#{self[:file_root]}/theme_config.yml".squeeze('/')
    end

    def load_config filename_and_path = ''
      filename_and_path = filename_and_path.empty? ? self[:theme_config] : filename_and_path
      params = YAML.load(File.read(filename_and_path))
      params.each_pair { |key, value| self[key.downcase.to_sym] = value } unless !params
    rescue Errno::ENOENT => e
      puts "Warning: unable to load config file : " + filename_and_path
    end
      
    def root()   self[:root]    end
        
    def get_template name
      "#{self[:file_root]}/templates/#{name}.rhtml".squeeze('/')
    end
  end
end
