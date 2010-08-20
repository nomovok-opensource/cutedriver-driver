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

	class Parameter

		include Singleton

		@@initialized = false

	private

		def initialize

			# this can be done only once due to following method removes --tdriver_parameters argument from ARGV
			@@filename_from_command_list_arguments = parse_command_line_arguments

			# initialize and load templates, default parameters and user defined parameter file
			reset( true, true, true, true )

			# parameter singleton is now initialized
			@@initialized = true

		end

		def parse_command_line_arguments

			# reset user_defined_file_defined_in_command_line_arguments flag	
			@@user_defined_parameters_file_defined_in_command_line_arguments = false

			filename = nil

			# use command line argument if one exists. 
			ARGV.each_index do | index |

				if ARGV[ index ].to_s == '--matti_parameters'

					Kernel::raise ArgumentError.new( "MATTI parameters command line argument given without a filename" ) if ARGV.count == index + 1 
					puts "--matti_parameters is deprecated, use -tdriver_parameters instead"

					filename = MobyUtil::FileHelper.expand_path( ARGV[ index + 1 ] )

					# remove argument from ARGV array; some testing framework fails due to invalid argument
					ARGV.delete_at( index + 1 )
					ARGV.delete_at( index )

					@@user_defined_parameters_file_defined_in_command_line_arguments = true

					break

				end

				if ARGV[ index ].to_s == '--tdriver_parameters'

					Kernel::raise ArgumentError.new( "TDriver parameters command line argument given without a filename" ) if ARGV.count == index + 1 

					filename = MobyUtil::FileHelper.expand_path( ARGV[ index + 1 ] )

					# remove argument from ARGV array; some testing framework fails due to invalid argument
					ARGV.delete_at( index + 1 )
					ARGV.delete_at( index )

					@@user_defined_parameters_file_defined_in_command_line_arguments = true

					break

				end

			end

			Kernel::raise MobyUtil::FileNotFoundError.new( "User defined TDriver parameters file %s does not exist" % [ filename ] ) if filename && !File.exist?( filename )

			filename

		end

	protected

		def reset_flags

			# reset loaded_parameter_files list
			@@loaded_parameter_files = []

			# reset templates_loaded flag
			@@templates_loaded = false

			# reset default_parameters_loaded flag
			@@default_parameters_loaded = false

		end

		def reset( load_template_files = true, load_parameter_defaults = true, load_default_parameters = true, load_command_line_parameters = true )

			reset_flags

			# load parameter templates
			load_templates if load_template_files

      # load global parameters (root level, e.g. MobyUtil::Parameter[ :logging_outputter_enabled ])
			@@parameters = MobyUtil::ParameterTemplates.instance.get_template_from_xml( 'global' )

			# load and merge with default parameters 
			@@parameters.merge_with_hash!( load_default_parameter_files ) if load_parameter_defaults

			# use filename from command line argument if one exists otherwise use default.
			filename = load_command_line_parameters ? @@filename_from_command_list_arguments : nil 

			# idoim: use default parameters file if nil
			filename ||= MobyUtil::FileHelper.expand_path( "tdriver_parameters.xml" ) if load_default_parameters

			# load parameters file unless file does not exist
			load_parameters_xml( filename ) if filename && File.exist?( filename )

		end

		def load_templates

			@@templates_loaded = true

			MobyUtil::ParameterTemplates.instance.load_templates()

		end

		def load_default_parameter_files

			@@default_parameters_loaded = true

			# load default parameter values
			MobyUtil::ParameterXml.instance.parse( 

				MobyUtil::ParameterXml.instance.merge_files( 'defaults/', 'parameters', '/parameters/*' ){  | filename |

					@@loaded_parameter_files << filename unless @@loaded_parameter_files.include?( filename )

				}

			)

		end

	public

		# reset parameters class
		def reset_parameters

			MobyUtil::ParameterXml.instance.reset

			reset( true, true, true, true ) 

		end

		# load additional parameter xml files
		def load_parameters_xml( filename, reset = false ) 

			reset_parameters if reset == true

			filename = MobyUtil::FileHelper.expand_path( filename )

			Kernel::raise MobyUtil::FileNotFoundError.new( "Parameters file %s does not exist" % [ filename ] ) if !File.exist?( filename )

			@@parameters.merge_with_hash!( 

				MobyUtil::ParameterXml.instance.parse_file( filename )

			)

			@@loaded_parameter_files << filename

		end

		# empty parameters hash
		def clear

			MobyUtil::ParameterXml.instance.reset

			reset_flags

			@@parameters.clear

		end

	# static methods

		# Function for returning the value of a parameter. If the parameters is not yet populated it populates 
		# it with default file (tdriver_home/tdriver_parameters.xml)
		# == params
		# key:: Symbol containing the name of the parameter to be returned
		# == returns
		# String:: value of the parameter, or nil if not found
		def self.[]( key, *default )

			self.instance unless @@initialized

			@@parameters[ key, *default ]

		end

		def self.fetch( key, *default, &block )

			self.instance unless @@initialized

			@@parameters.method(:[]).call( key, *default, &block )

		end

		# Function for setting the value of a parameter. If the parameters is not yet populated it populates
		# it with default file (tdriver_home/tdriver_parameters.xml)
		# == params
		# key:: Symbol containing the name of the parameter to be modified
		# == returns
		# String:: new value of the parameter, or nil if not found
		def self.[]=( key, value )

			self.instance unless @@initialized

			Kernel::raise ParameterNotFoundError.new( "Unable to set parameter value due to nil is not valid key; Parameter key must be type of String or Symbol" ) unless key

			@@parameters[ key ] = value

		end

		def self.inspect

			self.instance unless @@initialized

			@@parameters.inspect

		end

		def self.to_s

			self.instance unless @@initialized

			@@parameters.to_s

		end

		def self.parameters

			self.instance unless @@initialized

			@@parameters

		end

		def self.configured_suts

			self.instance unless @@initialized

			MobyUtil::ParameterXml.instance.sut_list

		end

		def self.files

			@@loaded_parameter_files

		end

		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # Parameter

end # MobyUtil
