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
  
  def load_config_file(file=nil)
    if file.nil?
      if File.exists?("config/aliases.yml")
        file = "config/aliases.yml"
      elsif File.exists?("aliases.yml")
        file = "aliases.yml"
      end
    end
    file ? YAML::load(File.read(file)) : {}
  end
  
  def init(options={})
    config.merge! Util.symbolize_keys(load_config_file(options.delete(:file)).merge(options))
    config.each do |k,v|
      next if [:verbose].include?(k)
      manager.create_aliases(k, v)
    end
    self
  end
  
  def config
    @config ||= {}
  end

  def manager
    @manager ||= Manager.new
  end
end
