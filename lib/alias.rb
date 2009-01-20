$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require "yaml"
require 'alias/manager'
require 'alias/creator'
require 'alias/constant_creator'
require 'alias/instance_creator'
require 'alias/klass_creator'
require 'alias/core_extensions'

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
    config_hash = load_config_file(options[:file])
    config.merge! config_hash
    config['verbose'] = options[:verbose] if !options[:verbose].nil?
    manager.verbose = config['verbose'] if config.has_key?('verbose')
    config.each do |k,v|
      next if ['verbose'].include?(k)
      manager.create_aliases(k, v)
    end
    self
  end
  
  def config
    @config ||= {}
  end
  
  def config=(value); @config = value; end
    
  def manager
    @manager ||= Manager.new
  end
end