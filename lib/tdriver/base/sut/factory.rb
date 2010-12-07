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
	def make( sut_attributes )

      sut_id = retrieve_sut_id_from_hash( sut_attributes )

	  sut_id = get_mapped_sut( sut_id ) if mapped_sut?( sut_id )

	  # if sut is already connected, return existing sut
	  return get_sut_from_list( sut_id ) if sut_exists?( sut_id )


	  # retrieve sut from parameters
      sut = MobyUtil::Parameter[ sut_id, nil ]

	  # raise exception if sut was not found
	  Kernel::raise ArgumentError.new( "%s not defined in TDriver parameters XML" % [ sut_id ]) if sut.nil?
	  
	  # retrieve sut type from parameters
	  sut_type = sut[ :type, nil ]
	  
	  # raise exception if sut type was not found
	  Kernel::raise RuntimeError.new( "SUT parameter 'type' not defined for %s in TDriver parameters/templates XML" % [ sut_id ] ) if sut_type.nil?

	  sut_type_symbol = sut_type.downcase.to_sym

	  # retrieve plugin name that implements given sut
	  sut_plugin = sut[ :sut_plugin, nil ]
	  sut_env = sut[ :env, '*' ]

	  # verify that sut plugin is defined in sut configuration
	  Kernel::raise RuntimeError.new( "SUT parameter 'sut_plugin' not defined for %s (%s)" % [ sut_id, sut_type ] ) if sut_plugin.nil?
	  
	  # flag to determine that should exception be raised; allow one retry, then set flag to true if error still occures
	  raise_exception = false

	  begin

		# verify that sut plugin is registered
		if MobyUtil::PluginService.instance.plugin_registered?( sut_plugin, :sut )
		  
		  # create sut object
		  created_sut = MobyUtil::PluginService.instance.call_plugin_method( sut_plugin, :make_sut, sut_id )

		else

		  # raise error if sut was not registered
		  Kernel::raise NotImplementedError.new( "No plugin implementation found for SUT type: %s" % [ sut_type ] )

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
#								   :sut_type => [ '*', sut_type.upcase ], 
								   :sut_type => [ '*', sut_type ], 
								   :input_type => [ '*', created_sut.input.to_s ],
								   :env => [ '*', sut_env.to_s ],
								   :version => [ '*', created_sut.ui_version.to_s ]
								   )

	  @_sut_list[ sut_id ] = { :sut => created_sut, :is_connected => true }

	  created_sut

	end

	def disconnect_sut( sut_attributes )

      sut_id = retrieve_sut_id_from_hash( sut_attributes )

	  Kernel::raise RuntimeError.new( 
									 
									 "Unable disconnect SUT due to %s is not connected" % [ sut_id ] 
									 
									 ) unless sut_exists?( sut_id ) && @_sut_list[ sut_id ][ :is_connected ] 
	  
	  @_sut_list[ sut_id ][ :sut ].disconnect
	  
	  @_sut_list[ sut_id ][ :is_connected ] = false

	end 

	def reboot_sut( sut_attributes )

      sut_id = retrieve_sut_id_from_hash( sut_attributes )

	  Kernel::raise RuntimeError.new( 
									 
									 "Unable to reboot SUT due to %s is not connected" % [ sut_id ] 
									 
									 ) unless sut_exists?( sut_id ) && @_sut_list[ sut_id ][ :is_connected ]
	  
	  @_sut_list[ sut_id ][ :sut ].reboot

	  disconnect_sut( sut_id )

	end

	def connected_suts

	  @_sut_list

	end

	private

    def retrieve_sut_id_from_hash( sut_attributes )

	  # usability improvement: threat sut_attribute as SUT id if it is type of Symbol or String
	  sut_attributes = { :id => sut_attributes.to_sym } if [ String, Symbol ].include?( sut_attributes.class )

      # verify that sut_attributes is type of Hash
      sut_attributes.check_type( [ Hash, Symbol, String ], "Wrong argument type $1 for 'sut_attributes' (expected $2)" )

      # legacy support: support also :Id
      sut_attributes[ :id ] = sut_attributes.delete( :Id ) if sut_attributes.has_key?( :Id )

      sut_attributes.require_key( :id, "Required SUT identification key $1 not defined in 'sut_attributes'" )
      
      sut_attributes[ :id ].to_sym

    end

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
	# sut_id:: Symbol defining the id of the sut to search for
	# === returns
	# Symbol:: Either id if it was found in the parameter file or the id of a sut mapped to this id, or nil if no direct or mapped match was found
	# === raises
	# ArgumentError:: The id argument was not a Symbol
	def find_sut_or_mapping( sut_id )

      sut_id.check_type( Symbol, "Wrong argument type $1 for SUT id (expected $2)" )
      
	  #Kernel::raise ArgumentError.new( "The id argument was not a Symbol." ) unless sut_id.kind_of?( Symbol )

	  begin

		# check if direct match exists
		return sut_id if MobyUtil::Parameter[ sut_id ]

	  rescue MobyUtil::ParameterNotFoundError

		# check if a mapping is defined for the id
		begin        

		  # return nil if no mapping exists
		  return nil if ( mapped_id = MobyUtil::Parameter[ :mappings ][ sut_id ] ).nil?                

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
