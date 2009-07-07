module Alias
  # This module contains the main methods to be accessed from a ruby shell i.e. irb. Simply extend Alias::Console in your ruby shell.
  module Console
    # See Alias::Manager.create_aliases for usage.
    def create_aliases(*args)
      Alias.manager.console_create_aliases(*args)
    end

    # Saves aliases to a file. If no file is given, defaults to config/alias.yml if the config directory exists (for Rails).
    # Otherwise defaults to ~/.alias.yml.
    def save_aliases(file=nil)
      Alias.manager.save_aliases(file)
    end

    # Searches aliases with a search term as defined by Alias::Manager.search. If no arguments given, all aliases are listed.
    def search_aliases(*args)
      args.empty? ? Alias.manager.all_aliases : Alias.manager.search(*args)
    end
  end
end