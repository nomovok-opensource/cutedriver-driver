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

module MobyUtil

  # Plugin service implementation
  class PluginService

    include Singleton

    # intialize plugin service
    def initialize

      @@registered_plugins = {}

    end

    # return all or plugins of given type
    def registered_plugins( type = nil )

      # return all or plugins of given type
      Hash[ @@registered_plugins.select{ | key, value | type.nil? || value[ :type ] == type } ]

    end

    # returns true if plugin is registered, plugin type can be given as optional parameter
    def plugin_registered?( plugin_name, type = nil )
    
      # check if given plugin is registered
      if @@registered_plugins.has_key?( plugin_name )
      
        unless type.nil?
        
          # plugin registered, compare that given plugin type matches
          @@registered_plugins[ plugin_name ][ :type ] == type
                
        else
        
          # plugin registered, no specific plugin type given 
          true
        
        end
      
      else
      
        # plugin not registered, not found from @@registered_plugins hash
        false
      
      end

    end

    def enable_plugin( plugin_name )
        
      ( @@registered_plugins[ plugin_name ][ :enabled ] = true ) rescue Kernel::raise( ArgumentError.new( "No such plugin registered %s" % [ plugin_name ] ) )
      
    end

    def disable_plugin( plugin_name )

      ( @@registered_plugins[ plugin_name ][ :enabled ] = false ) rescue Kernel::raise( ArgumentError.new( "No such plugin registered %s" % [ plugin_name ] ) )
      
    end

    def plugin_enabled?( plugin_name )

      ( @@registered_plugins[ plugin_name ][ :enabled ] ) rescue false
          
    end

    def register_plugin( plugin_module )
 
      # retrieve plugin name
      plugin_name = plugin_data_value( plugin_module, :plugin_name )

      # throw exception if plugin is already registered
      Kernel::raise ArgumentError.new( "Plugin %s is already registered" % [ plugin_name ] ) if @@registered_plugins.has_key?( plugin_name )

      # plugin configuration
      @@registered_plugins[ plugin_name ] = { 
        :type => plugin_data_value( plugin_module, :plugin_type ), 
        :plugin_module => plugin_module, 
        :enabled => true 
      } 

      # register plugin
      plugin_module.register_plugin

    end

    def unregister_plugin( plugin_name )

      # unregister plugin, raise exception if plugin is not registered
      ( @@registered_plugins[ plugin_name ][ :plugin_module ].unregister_plugin ) rescue Kernel::raise( ArgumentError.new( "Unregister failed due to plugin %s is not registered" % [ plugin_name ] ) )

      # remove from the plugins hash
      @@registered_plugins.delete( plugin_name )

    end

    def load_plugin( plugin_name )

      begin

        # load plugin implementation
        require plugin_name 

      rescue LoadError => exception

        Kernel::raise RuntimeError.new( 

          "Error while loading plugin %s. Please verify that the plugin is installed properly (%s: %s)" % [ plugin_name, exception.class, exception.message ]

        )

      end

    end

    def call_plugin_method( plugin_name, method_name, *args )

      begin

        plugin_module = @@registered_plugins[ plugin_name ][ :plugin_module ]
        
      rescue
      
        Kernel::raise( ArgumentError.new( "No such plugin registered %s" % [ plugin_name ] ) )

      end

      begin

        plugin_module.send( method_name.to_sym, *args )

      rescue Exception => exception

        raise PluginError.new( "Error occured during calling %s method for %s (%s: %s)" % [ method_name, plugin_name, exception.class, exception.message ] )

      end

    end

  private

    def reset_plugins_list

      @@registered_plugins = {}

    end

    def delete_plugin( plugin_name )

      # remove from the plugins hash
      @@registered_plugins.delete( plugin_name )

    end

    def plugin_data_value( plugin_module, value_name, optional = false )
      
      begin

        result = plugin_module.send( value_name.to_sym )

      rescue NoMethodError

        Kernel::raise RuntimeError.new( "Plugin must have %s value defined" % [ value_name.to_s ] ) if !optional

      rescue => exception

        Kernel::raise exception

      end

      result

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # PluginService

end # MobyUtil
