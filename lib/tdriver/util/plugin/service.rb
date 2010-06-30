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

			reset_plugins_list

		end

		# return all or plugins of given type
		def registered_plugins( type = nil )

			plugins( :type, type )

		end

		# returns true if plugin is registered, plugin type can be given as optional parameter
		def plugin_registered?( plugin_name, type = nil )

			# check if given plugin is registered
			result = is_plugin_registered?( plugin_name )
		
			# if plugin type defined, compare plugin type with given 
			result = ( plugin_value( plugin_name, :type ) == type ) if !type.nil? && result
			
			# return result
			result

		end

		def enable_plugin( plugin_name )

			Kernel::raise ArgumentError.new( "No such plugin registered %s" % [ plugin_name ] ) unless is_plugin_registered?( plugin_name )

			set_plugin_value( plugin_name, :enabled, true )

		end

		def disable_plugin( plugin_name )

			Kernel::raise ArgumentError.new( "No such plugin registered %s" % [ plugin_name ] ) unless is_plugin_registered?( plugin_name )

			set_plugin_value( plugin_name, :enabled, false )
		end

		def plugin_enabled?( plugin_name )

			Kernel::raise ArgumentError.new( "No such plugin registered %s" % [ plugin_name ] ) unless is_plugin_registered?( plugin_name )

			plugin_value( plugin_name, :enabled )

		end

		def register_plugin( plugin_module )

			# retrieve plugin name
			plugin_name = plugin_data_value( plugin_module, :plugin_name )

			# throw exception if plugin is already registered
			Kernel::raise ArgumentError.new( "Plugin %s is already registered" % [ plugin_name ] ) if is_plugin_registered?( plugin_name )

			# plugin configuration
			set_plugin_values( 
				plugin_name, 
				{ 
					:type => plugin_data_value( plugin_module, :plugin_type ), 
					:plugin_module => plugin_module, 
					:enabled => true 
				} 
			)

			# register plugin
			plugin_module.register_plugin

		end

		def unregister_plugin( plugin_name )

			Kernel::raise ArgumentError.new( "Unregister failed due to plugin %s is not registered" % [ plugin_name ] ) unless plugin_registered?( plugin_name )

			# remove from the plugins list
			delete_plugin( plugin_name )

			# unregister plugin
			plugin_module.unregister_plugin

		end

		def load_plugin( plugin_name )

			begin

				# load plugin implementation
				require plugin_name 

			rescue LoadError => exception

				Kernel::raise RuntimeError.new( 

					"Error while loading plugin %s. Please verify that the plugin is installed properly." % [ plugin_name ]

				)

			end

		end

		def call_plugin_method( plugin_name, method_name, *args )

			begin

				plugin_value( plugin_name, :plugin_module ).method( method_name.to_sym ).call( *args )

			rescue Exception => exception

				raise PluginError.new( "Error occured during calling %s method for %s. Reason: %s (%s)" % [ method_name, plugin_name, exception.message, exception.class ] )

			end

		end

	private

		def is_plugin_registered?( plugin_name )

			@@registered_plugins.has_key?( plugin_name )

		end

		def reset_plugins_list

			@@registered_plugins = {}

		end

		def get_plugin( plugin_name )

			@@registered_plugins[ plugin_name ]

		end

		def plugins( expected_key = nil, expected_value = nil )

			# return all or plugins of given type
			Hash[ @@registered_plugins.select{ | key, value | expected_key.nil? || expected_value.nil? || value[ expected_key ] == expected_value } ]

		end

		def set_plugin_value( plugin_name, name, value )

			@@registered_plugins[ plugin_name ][ name.to_sym ] = value

		end

		def set_plugin_values( plugin_name, hash = {} )

			@@registered_plugins[ plugin_name ] = ( @@registered_plugins[ plugin_name ] ||= {} ).merge!( hash )

		end

		def plugin_value( plugin_name, name )

			@@registered_plugins[ plugin_name ][ name.to_sym ]

		end

		def delete_plugin( plugin_name )

			# remove from the plugins hash
			@@registered_plugins.delete( plugin_name )

		end

		def plugin_data_value( plugin_module, value_name, optional = false )

			begin

				result = plugin_module.method( value_name.to_sym ).call

			rescue NameError

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
