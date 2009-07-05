$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require 'yaml'
require 'alias/manager'
require 'alias/validator'
require 'alias/creator'
require 'alias/constant_creator'
require 'alias/instance_method_creator'
require 'alias/class_method_creator'
require 'alias/delegate_to_class_method_creator'
require 'alias/util'
require 'alias/console'

module Alias
  extend self

  # Creates aliases from Alias.config_file if it exists and merges them with any explicit aliases. This method takes
  # the same keys used by config files (see Alias.config_file) and also the following options:
  # * :file : Specifies a config file to override Alias.config_file. If set to false, no config_file is loaded.
  def create(options={})
    file_config = load_config_file(options.delete(:file))
    file_config[:aliases] = file_config[:aliases] ? Util.symbolize_keys(file_config.delete(:aliases)) : {}
    config.merge! file_config.merge(options)
    manager.verbose = config[:verbose] if config[:verbose]
    manager.force = config[:force] if config[:force]
    config[:aliases].each do |creator_type, aliases|
      manager.create_aliases(creator_type, aliases)
    end
    self
  end

  # Set to config/aliases.yml if it exists. Otherwise set to ~/.aliases.yml. A config file has the following keys:
  # [:aliases] This takes a hash mapping creators to their config hashes. Valid creators are :instance_method, :class_method, :constant
  #            and :delegate_to_class_method.
  # [:verbose] Sets whether creators are verbose with boolean or array of creator symbols. A boolean sets verbosity for all creators whereas
  #            the array specifies which creators. Default is false.
  # [:force] Sets whether creators force optional validations with boolean or array of creator symbols. Works the same as :verbose. Default is false.
  def config_file
    @config_file ||= File.exists?("config/aliases.yml") ? 'config/aliases.yml' : "#{ENV['HOME']}/.aliases.yml"
  end

  #:stopdoc:
  def load_config_file(file)
    return {} if file == false
    @config_file = file if file
    loaded_config = File.exists?(File.expand_path(config_file)) ? YAML::load_file(File.expand_path(config_file)) : {}
    Util.symbolize_keys loaded_config
  end
  
  def config
    @config ||= {}
  end

  def manager
    @manager ||= Manager.new
  end
  #:startdoc:
end
