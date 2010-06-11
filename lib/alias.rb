require 'yaml'
require 'alias/manager'
require 'alias/validator'
require 'alias/creator'
require 'alias/creators/constant_creator'
require 'alias/creators/instance_method_creator'
require 'alias/creators/class_method_creator'
require 'alias/creators/class_to_instance_method_creator'
require 'alias/creators/any_to_instance_method_creator'
require 'alias/util'
require 'alias/console'
require 'alias/version'

# Most of the core Alias actions are run through Alias::Manager except for Alias.create. 
# See Alias::Manager for an explanation of how aliases are created.
module Alias
  extend self

  # Creates aliases from Alias.config_file if it exists and merges them with any explicit aliases. This method takes
  # the same keys used by config files (see Alias.config_file) and also the following options:
  # * :file : Specifies a config file to override Alias.config_file. If set to false, no config file is loaded.
  # Examples:
  #   # Loads any default files and the ones in :aliases. 
  #   # Sets global verbosity for creators.
  #   create :aliases=>{:constant=>{"Array"=>"A"}}, :verbose=>true
  #   # Loads the given file and sets verbosity just for the :instance_method creator.
  #   create :file=>"some file", :verbose=>[:instance_method]
  def create(options={})
    file_config = load_config_file(options.delete(:file))
    new_config = Util.recursive_hash_merge(file_config, options)
    manager.verbose = new_config[:verbose] if new_config[:verbose]
    manager.force = new_config[:force] if new_config[:force]
    (new_config[:aliases] || {}).each do |creator_type, aliases|
      manager.create_aliases(creator_type, aliases)
    end
    @config = Util.recursive_hash_merge(config, new_config)
  end

  # By default, looks for existing files in config/alias.yml and then ~/.alias.yml. A config file has the following keys:
  # [:aliases] This takes a hash mapping creators to their config hashes. Valid creators are :instance_method, :class_method, :constant,
  #            :class_to_instance_method and :any_to_instance_method.
  # [:verbose] Sets whether creators are verbose with boolean or array of creator symbols. A boolean sets verbosity for all creators whereas
  #            the array specifies which creators. Default is false.
  # [:force] Sets whether creators force optional validations with boolean or array of creator symbols. Works the same as :verbose. Default is false.
  def config_file
    @config_file ||= File.exists?("config/alias.yml") ? 'config/alias.yml' : "#{ENV['HOME']}/.alias.yml"
  end

  # Contains primary Alias::Manager object which is used throughout Alias.
  def manager
    @manager ||= Manager.new
  end

  #:stopdoc:
  def add_to_config_file(new_aliases, file)
    file ||= File.directory?('config') ? 'config/alias.yml' : "#{ENV['HOME']}/.alias.yml"
    existing_aliases = read_config_file(file)
    existing_aliases[:aliases] = Util.recursive_hash_merge existing_aliases[:aliases], new_aliases
    save_to_file file, existing_aliases.to_yaml
    puts "Saved created aliases to #{file}."
  end

  def save_to_file(file, string)
    File.open(File.expand_path(file), 'w') {|f| f.write string }
  end

  def read_config_file(file)
    file_config = File.exists?(File.expand_path(file)) ? YAML::load_file(File.expand_path(file)) : {}
    file_config = Util.symbolize_keys file_config
    file_config[:aliases] = file_config[:aliases] ? Util.symbolize_keys(file_config.delete(:aliases)) : {}
    file_config
  end

  def load_config_file(file)
    return {} if file == false
    @config_file = file if file
    read_config_file(config_file)
  end
  
  def config
    @config ||= {}
  end
  #:startdoc:
end
