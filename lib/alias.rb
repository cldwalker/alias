$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))
require "yaml"
require 'alias/creator'
# require 'alias/search'
require 'alias/core_extensions'
# require "lib/forwardable"
# require "lib/object"

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
  
  def setup(options={})
    config_hash = load_config_file(options[:file])
    config_hash.each do |k,v|
      creator.create_aliases_for_type(k, v)
    end
    self
  end
  
  def creator
    @creator ||= Creator.new
  end
end