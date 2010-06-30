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


module MobyBase

	# Class to create SUT objects
	# Hides actual SUT object from the clients -> clients should be able to use the instantiated SUT object as if it was any SUT 
	class SUTFactory

		include Singleton

		# Initialize the singleton
		def initialize()

			reset

		end

		# Create/reset hash to store sut ids for all current suts
		def reset

			@_sut_list = {}

		end

		def mapped_sut?( sut_id )

			MobyUtil::Parameter[ :mappings, {} ].has_key?( sut_id.to_sym )
		end


		def get_mapped_sut( sut_id )

			MobyUtil::Parameter[ :mappings ][ sut_id.to_sym ].to_sym

		end

		# Function to create the actual SUT objects based on the 'sut' attribute.
		# === params
		# sut_type:: sut_type - sut type, supportes all types defined by SUTFactory constants
		# id:: id - unique identifier for identifying particular SUT from each other. Is propagated to proper initializers.
		# === returns
		# return:: SUT object
		# raise:: 
		# ArgumentError:: SUT ID '%s' not found from tdriver_parameters.xml
		def make( sut_id )

			# cast into symbol just in case string was passed
			sut_id = sut_id.to_sym

			sut_id = get_mapped_sut( sut_id ) if mapped_sut?( sut_id )

			# if sut is already connected, return existing sut
			return get_sut_from_list( sut_id ) if sut_exists?( sut_id )

			#mapped_id = MobyUtil::Parameter[ sut_id, nil ].to_sym

			# check if the sut or an alias exists in tdriver_parameters.xml
			#mapped_id = find_sut_or_mapping( sut_id )

			# if sut is already connected, return existing sut
			#return get_sut_from_list( mapped_id ) if (mapped_id != sut_id and sut_exists?( mapped_id ))

			Kernel::raise ArgumentError.new( "The SUT '#{ sut_id }' was not defined in TDriver parameters XML" ) if MobyUtil::Parameter[ sut_id, nil ].nil?

			# retrieve sut type from parameters, raise exception if sut type was not found
			Kernel::raise RuntimeError.new( "SUT type not defined for #{ sut_id } in TDriver parameters/templates XML" ) if ( sut_type = MobyUtil::Parameter[ sut_id ][ :type, nil ] ).nil?

			sut_type_symbol = sut_type.downcase.to_sym

			# retrieve plugin name that implements given sut
			sut_plugin = MobyUtil::Parameter[ sut_id ][ :sut_plugin, nil ]

			# verify that sut plugin is defined in sut configuration
			Kernel::raise RuntimeError.new( "SUT plugin not defined for %s (%s)" % [ sut_id, sut_type ] ) if sut_plugin.nil?

			# flag to determine that should exception be raised; allow one retry, then set flag to true if error still occures
			raise_exception = false

			begin

				# verify that sut plugin is registered
				if MobyUtil::PluginService.instance.plugin_registered?( sut_plugin, :sut )
	
					# create sut object
					created_sut = MobyUtil::PluginService.instance.call_plugin_method( sut_plugin, :make_sut, sut_id )

				else

					# raise error if sut was not registered
					Kernel::raise NotImplementedError.new( "No plugin/implementation for SUT type: %s" % [ sut_type ] )

				end

			rescue Exception => exception

				# if sut was not registered, try to load it
				MobyUtil::PluginService.instance.load_plugin( sut_plugin ) if exception.kind_of?( NotImplementedError )

				if !raise_exception

					raise_exception = true
					retry 
				else

					# still errors, raise original exception
					Kernel::raise exception

				end

			end

			# sut type version, default: nil    
			created_sut.instance_eval { 
				@ui_type = sut_type; 
				@ui_version = MobyUtil::Parameter[ sut_id ][ :version, nil ]; 
				@input = MobyUtil::Parameter[ sut_id ][ :input_type, nil ]; 
			}
			
			# add behaviours to sut
			created_sut.extend( MobyBehaviour::ObjectBehaviourComposition )

			# retrieve list of optional extension plugins
			@extension_plugins = MobyUtil::Parameter[ sut_id ][ :extension_plugins, "" ].split( ";" )

			# load optional extension plugins
			if @extension_plugins.count > 0

				@extension_plugins.each{ | plugin_name |

					raise_exception = false

					begin

						# verify that extension plugin is registered
						unless MobyUtil::PluginService.instance.plugin_registered?( plugin_name, :extension )

							# raise error if sut was not registered
							Kernel::raise NotImplementedError.new( "Extension plugin not found %s" % [ plugin_name ] )

						end

					rescue Exception => exception

						# if sut was not registered, try to load it
						MobyUtil::PluginService.instance.load_plugin( plugin_name ) if exception.kind_of?( NotImplementedError )

						if !raise_exception

							raise_exception = true
							retry 
						else

							# still errors, raise original exception
							Kernel::raise exception

						end

					end

				}

			end

			# apply sut generic behaviours
			created_sut.apply_behaviour!( 
				:object_type => [ 'sut' ], 
				:sut_type => [ '*', sut_type.upcase ], 
				:input_type => [ '*', created_sut.input.to_s ],
				:version => [ '*', created_sut.ui_version.to_s ]
			)

			@_sut_list[ sut_id ] = { :sut => created_sut, :is_connected => true }

			created_sut

		end

		def disconnect_sut( id )

			#cast into symbol just in case string was passed
			id = id.to_sym
			Kernel::raise RuntimeError.new( "Not connected to device: #{ id  }" ) unless sut_exists?( id ) && @_sut_list[ id ][ :is_connected ] 

			@_sut_list[ id ][ :sut ].disconnect
			@_sut_list[ id ][ :is_connected ] = false

		end 

		def reboot_sut( id )

			id = id.to_sym
			Kernel::raise RuntimeError.new( "Not connected to device: #{ id }" ) unless sut_exists?( id ) && @_sut_list[ id ][ :is_connected ]
			
			@_sut_list[ id ][ :sut ].reboot
			disconnect_sut( id )
		end

		def connected_suts

			@_sut_list

		end

	private

		# gets sut from sut-factorys list - if not connected tries to reconnect first
		def get_sut_from_list( id )

			if !@_sut_list[ id ][ :is_connected ]

				@_sut_list[ id ][ :sut ].connect( id )
				@_sut_list[ id ][ :is_connected ] = true

			end

			@_sut_list[ id ][ :sut ]
		end

		def sut_exists?( sut_id )

			@_sut_list.has_key?( sut_id )

		end

		# Finds the sut definition matching the id, either directly or via a mapping
		#
		# === params
		# id:: Symbol defining the id of the sut to search for
		# === returns
		# Symbol:: Either id if it was found in the parameter file or the id of a sut mapped to this id, or nil if no direct or mapped match was found
		# === raises
		# ArgumentError:: The id argument was not a Symbol
		def find_sut_or_mapping( id )

			Kernel::raise ArgumentError.new( "The id argument was not a Symbol." ) unless id.kind_of?( Symbol )

			begin

				# check if direct match exists
				return id if MobyUtil::Parameter[ id ]

			rescue MobyUtil::ParameterNotFoundError

				# check if a mapping is defined for the id
				begin        

					# return nil if no mapping exists
					return nil if ( mapped_id = MobyUtil::Parameter[ :mappings ][ id ] ).nil?                

					# check if the mapped to sut id exists
					return mapped_id if MobyUtil::Parameter[ ( mapped_id = mapped_id.to_sym ) ]

				rescue MobyUtil::ParameterNotFoundError

					# no mappings defined in tdriver_parameters.xml or the mapped to sut was not found
					return nil

				end # check if mapping exists

			end # check if direct match exists

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # SUTFactory

end # MobyBase
