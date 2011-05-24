############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of Testability Driver. 
## 
## If you have questions regarding the use of this file, please contact 
## Nokia at testabilitydriver@nokia.com . 
## 
## This library is free software; you can redistribute it and/or 
## modify it under the terms of the GNU Lesser General Public 
## License version 2.1 as published by the Free Software Foundation 
## and appearing in the file LICENSE.LGPL included in the packaging 
## of this file. 
## 
############################################################################

module TDriver

  class PluginService

    # private methods and variables
    class << self

      private

      # TODO: document me
      def initialize_class

        reset_plugins_list

      end

      # TODO: document me
      def reset_plugins_list

        # list of registered plugins
        @registered_plugins = {}

        # list of enabled plugins
        @enabled_plugins = []

      end

      # TODO: document me
      def delete_plugin( plugin_name )

        # remove from the plugins hash
        @registered_plugins.delete( plugin_name )

        # remove plugin from enabled plugins list
        @enabled_plugins.delete( plugin_name )

      end

      # TODO: document me
      def plugin_data_value( plugin_module, value_name, optional = false )
        
        begin

          plugin_module.send( value_name.to_sym )

        rescue NoMethodError

          raise RuntimeError, "Plugin must have #{ value_name.to_s } value defined" if !optional

        rescue Exception

          raise

        end

      end

    end # self

    # TODO: document me
    def self.registered_plugins( type = nil )

      # return all or plugins of given type
      Hash[ @registered_plugins.select{ | key, value | type.nil? || value[ :type ] == type } ]

    end

    # returns true if plugin is registered, plugin type can be given as optional parameter
    def self.plugin_registered?( plugin_name, type = nil )
    
      # check if given plugin is registered
      if @registered_plugins.has_key?( plugin_name )
      
        unless type.nil?
        
          # plugin registered, compare that given plugin type matches
          @registered_plugins[ plugin_name ][ :type ] == type
                
        else
        
          # plugin registered, no specific plugin type given 
          true
        
        end
      
      else
      
        # plugin not registered, not found from registered_plugins list
        false
      
      end

    end

    # TODO: document me
    def self.enabled_plugins

      @enabled_plugins

    end

    # TODO: document me
    def self.enable_plugin( plugin_name )
      
      begin

        # enable plugin
        @registered_plugins[ plugin_name ][ :enabled ] = true

        # add name to enabled plugins list
        @enabled_plugins << plugin_name unless @enabled_plugins.include?( plugin_name )

      rescue 

        raise ArgumentError, "No such plugin registered #{ plugin_name }"

      end

    end

    # TODO: document me
    def self.disable_plugin( plugin_name )

      begin

        # disable plugin
        @registered_plugins[ plugin_name ][ :enabled ] = false

        # remove name from enabled plugins list
        @enabled_plugins.delete( plugin_name )

      rescue 

        raise ArgumentError, "No such plugin registered #{ plugin_name }"

      end
      
    end

    # TODO: document me
    def self.plugin_enabled?( plugin_name )

      @enabled_plugins.include?( plugin_name )
      
    end

    # TODO: document me
    def self.register_plugin( plugin_module )
 
      # retrieve plugin name 
      plugin_name = plugin_data_value( plugin_module, :plugin_name )

      # throw exception if plugin is already registered
      raise ArgumentError, "Plugin #{ plugin_name } is already registered" if @registered_plugins.has_key?( plugin_name )

      # plugin configuration
      @registered_plugins[ plugin_name ] = {
 
        # store plugin type
        :type => plugin_data_value( plugin_module, :plugin_type ), 

        # store plugin implementation module name
        :plugin_module => plugin_module, 

        # set plugin to enabled state
        :enabled => true 

      } 

      # register plugin
      plugin_module.register_plugin

      # add name to enabled plugins list
      @enabled_plugins << plugin_name unless @enabled_plugins.include?( plugin_name )

    end

    # TODO: document me
    def self.unregister_plugin( plugin_name )

      begin

        # call plugin unregister mechanism
        @registered_plugins[ plugin_name ][ :plugin_module ].unregister_plugin

        # remove from the plugins hash
        @registered_plugins.delete( plugin_name )

        # remove from the plugins hash
        @enabled_plugins.delete( plugin_name )

      rescue

        raise ArgumentError, "Failed to unregister plugin due to plugin #{ plugin_name.inspect } is not registered"

      end

    end

    # TODO: document me
    def self.load_plugin( plugin_name )

      begin

        # load plugin implementation
        require plugin_name 

      rescue LoadError

        raise RuntimeError, "Error while loading plugin #{ plugin_name.to_s }. Please verify that the plugin is installed properly (#{ $!.class }: #{ $!.message })"

      end

    end

    # TODO: document me
    def self.call_plugin_method( plugin_name, method_name, *args )

      begin

        @registered_plugins.fetch( plugin_name ){

          # in case if plugin not found from registered plugins list
          raise ArgumentError, "No such plugin registered #{ plugin_name }"

        }[ :plugin_module ].send( method_name.to_sym, *args )

      rescue ArgumentError

        # raise argument errors as is
        raise      

      rescue 

        # raise all other exceptions as PluginError
        raise MobyUtil::PluginError, "Error occured during calling #{ method_name } method for #{ plugin_name } (#{ $!.class }: #{ $!.message })"

      end

    end

    # initialize plugin service 
    initialize_class

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # PluginService

end

module MobyUtil

  # deprecated plugin service implementation; please use TDriver::PluginService instead of this
  class PluginService

    # deprecated
    def self.instance

      # retrieve caller information
      file, line = caller.first.split(":")

      # show warning
      warn "#{ file }:#{ line } warning: deprecated method MobyUtil::PluginService.instance#method; please use static class TDriver::PluginService#method instead"

      # redirect to new implementation
      TDriver::PluginService

    end

  end

end
