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
module Generators
  
	class TDriverGenerator                 

		TYPE = {

			:file		=> 1, 
			:class		=> 2, 
			:module		=> 3 

		}

		VISIBILITY  = {

			:public		=> 1, 
			:private	=> 2, 
			:protected	=> 3 

		}

		PROCESS_METHODS = { 

			:method_list 	=> :process_method, 
			:aliases 	=> :process_alias,
			:constants 	=> :process_constant, 
			:requires 	=> :process_require, 
			:includes 	=> :process_include, 
			:attributes 	=> :process_attribute 

		}

		def TDriverGenerator.for( options )

			new( options )

		end

		def initialize( options ) #:not-new:

			@options = options

			@current_behaviour = nil

			@behaviours = {}

			# set up a hash to keep track of all the classes/modules we have processed
			@already_processed = {}

			@module_template = template( "templates/behaviour.module" )
			@method_template = template( "templates/behaviour.method" )

			@xml_behaviour_template = template( "templates/behaviour.xml" )
			@xml_method_template = template( "templates/behaviour.xml.method" )
			@xml_argument_template = template( "templates/behaviour.xml.argument" )
			@xml_exception_template = template( "templates/behaviour.xml.exception" )

			# set up a hash to keep track of all of the objects to be output
			@output = {
				:files => [], 
				:classes => [], 
				:modules => [], 
				:attributes => [], 
				:methods => [], 
				:aliases => [], 
				:constants => [], 
				:requires => [], 
				:includes => []
			}
		end

		# Rdoc passes in TopLevel objects from the code_objects.rb tree (all files)
		def generate( files )
                             
			# Each object passed in is a file, process it
			files.each { | file | 

				process_file( file )

			}

		end

	private

		def process_comment( comment )

			hash = { :nodoc => [] }

			section = :nodoc # hash.keys.first

			comment.lines.each{ | line |

				# remove line feed
				line.gsub!( /\n/, '' )

				#match = nil

				#if /^\s*#[ ]*(.*)$/.match( line )
				if /^\s*#\s(.*)$/.match( line )

					match = $1

					if /^==\s{1,}(.*)\s*$/.match( match )

						section = $1.gsub( /\s/, '_' ).to_sym

						hash[ section ] = [] 

						next

					end

				end

				hash[ section ] << match.rstrip unless section.nil? || match.nil? || match.empty?

			}

			hash

		end

		def parse_to_sections( array )

			result = []

			tag = nil

			array.each{ | line |

				if /^\w/.match( line )

					result << { :section => line }

					tag = nil

				end

				if /^\s/.match( line )

					raise RuntimeError.new( "No section defined for '%s'" % [ line ] ) if result.last.nil?

					#if /^\s{1}(\w+)\s*(.*)$/.match( line )
					if /^\s+(\w+):\s*(.*)$/.match( line )

						tag = $1

						value = $2.strip

					elsif /^\s+(.*)$/.match( line )

						raise RuntimeError.new( "No tag defined for '%s'" % [ line ] ) unless tag

						value = $1.strip

					end

					# store empty array to tag key if none already exists
					( result.last[ tag.to_sym ] ||= [] ).tap{ | values |

						values.concat( [ value ] )

					}

				end
			}

			result

		end

		def process_header_comment( module_header )

			# process data
			module_header.each_pair{ | key, value |

				case key
	
					when :behaviour, :description, :nodoc
						# do nothing

					when :objects, :sut_type, :sut_version, :input_type, :requires

						module_header[ key ] = value.to_s.split(";")

				else

					puts "Unknown module header tag: %s" % key

				end

			}

		end

		def process_method_comment( method )

			#p array

			#p array.class

			#array.each{ | method |

				#p method

				method.each_pair{ | key, value |

					#p key, value

					#next

					case key

						when :nodoc, :method_name

							# do nothing
							method[ key ] = value.to_s.strip

						when :example, :description

							method[ key ] = value.join('\n')

						when :see
							method[ key ] = value.to_s.gsub(/\s+/, "").split(",")

						when :arguments, :returns, :exceptions

							method[ key ] = parse_to_sections( value )

						else

							puts "Unknown method header tag: %s" % key

					end

				}

			#}

			method
			#array

		end

		def apply_macros( template_string, macros )

			template_string.clone.tap{ | template |

				macros.each{ | hash |

					#p hash[ :value ]

					h = hash[:value]

					h = h.first if h.kind_of?( Array )

					h ||= ""

					template.gsub!( hash[ :key ], h )

				}

			}

		end

		def behaviour_methods_arguments( arguments )

			( arguments || [] ).collect{ | argument | 
			 
				apply_macros( 
					@xml_argument_template,
					[
						{ :key => '$ARGUMENT_NAME', :value => argument[ :section ] },
						{ :key => '$ARGUMENT_TYPE', :value => argument[ :type ].first },
						{ :key => '$ARGUMENT_DESCRIPTION', :value => argument[ :description ].join( '\n' ) },
						{ :key => '$ARGUMENT_EXAMPLE', :value => argument[ :example ].first },
						{ :key => '$ARGUMENT_DEFAULT', :value => argument[ :default ].first }

					]

				)

			}.join()

		end

		def behaviour_methods_exceptions( exceptions )

			( exceptions || [] ).collect{ | exception | 

				apply_macros( 
					@xml_exception_template, 
					[
						{ :key => '$EXCEPTION_NAME', :value => exception[ :section ] },
						{ :key => '$EXCEPTION_DESCRIPTION', :value => exception[ :description ].join('\n') }

					] 
				)
			}.join 

		end

		def behaviour_methods( methods )

			methods.collect{ | method | 

				apply_macros( 
					@xml_method_template, 
					[
						{ :key => '$METHOD_NAME', :value => method[ :method_name ] },
						{ :key => '$METHOD_DESCRIPTION', :value => method[ :description ] },
						{ :key => '$METHOD_EXAMPLE', :value => method[ :example ] },
						{ :key => '$METHOD_ARGUMENTS', :value => behaviour_methods_arguments( method[ :arguments ] ) }, 
						{ :key => '$METHOD_EXCEPTIONS', :value => behaviour_methods_exceptions( method[ :exceptions ] ) }

					] 
				) 

			}.join

		end

		def generate_behaviour( module_header, methods )

			puts apply_macros( 
				@xml_behaviour_template, 
				[
					{ :key => '$REQUIRED_PLUGIN', :value => module_header[ :requires ] || [].join( ";" ) },
					{ :key => '$BEHAVIOUR_NAME', :value => module_header[ :behaviour ] || [].first },
					{ :key => '$OBJECT_TYPE', :value => module_header[ :objects ] || [].join( ";" ) },
					{ :key => '$SUT_TYPE', :value => module_header[ :sut_type ] || [].join( ";" ) },
					{ :key => '$INPUT_TYPE', :value => module_header[ :input_type ] || [].join( ";" ) },
					{ :key => '$VERSION', :value => module_header[ :sut_version ] || [].join( ";" ) },
					{ :key => '$MODULE_NAME', :value => module_header[ :module ] },
					{ :key => '$BEHAVIOUR_METHODS', :value => behaviour_methods( methods ) }
				]

			).gsub( /\n\n\n/, "\n\n" ) unless module_header[:module].to_s == "MobyBehaviour" #.empty?

		end






		def process_object( file )

			PROCESS_METHODS.each_pair{ | list, method |

				file.send( list ).each{ | child | send( method, child ) }

			} 

=begin
			file.method_list.each { | child | process_method( child ) }

			file.aliases.each { | child | process_alias( child ) }

			file.constants.each { | child | process_constant( child ) }

			file.requires.each { | child | process_require( child ) }

			file.includes.each { | child | process_include( child ) }

			file.attributes.each { | child | process_attribute( child ) }   
=end

		end

		# process a file from the code_object.rb tree
		def process_file( file )

			@current_behaviour = nil

			@behaviours = {}
	
			@output[ :files ].push( file )

			#puts "#{file.comment}"

			# Process all of the objects that this file contains
			process_object( file )

			# Recursively process contained subclasses and modules 
			file.each_classmodule do | child |

				process_class_or_module( child )

			end

			#p @behaviours

			@behaviours.each_pair{ | key, value |

				generate_behaviour value[:header], value[:methods]

			}

		end

		def template( filename )

			open( "%s.template" % filename ).read

		end

		# Process classes and modiles   
		def process_class_or_module( obj )

			type = obj.is_module? ? ( :modules ) : ( :classes )

			# One important note about the code_objects.rb structure. A class or module
			# definition can be spread a cross many files in Ruby so code_objects.rb handles
			# this by keeping only *one* reference to each class or module that has a definition
			# at the root level of a file (ie. not contained in another class or module).
			# This means that when we are processing files we may run into the same class/module
			# twice. So we need to keep track of what classes/modules we have
			# already seen and make sure we don't create two INSERT statements for the same
			# object.

			if( !@already_processed.has_key?( obj.full_name ) ) then      

				@output[ type ].push( obj )

				@already_processed[ obj.full_name ] = true

				header = process_comment( obj.comment )
				
				process_header_comment( header )

				header[ :module ] = obj.full_name

				@behaviours[ ( @current_behaviour = obj.full_name ) ] = {
 
					:header 	=> header,

					:methods	=> []

				}

				# Process all of the objects that this class or module contains
				process_object( obj ) if obj.full_name =~ /^MobyBehaviour::/

			end

			#id = @already_processed[ obj.full_name ]
			# Recursively process contained subclasses and modules 

			obj.each_classmodule do | child | 

				process_class_or_module( child ) 

			end

		end       

		def process_method( obj )  

			#obj.source_code = get_source_code( obj )

			if obj.visibility == :public

				comment = process_comment( obj.comment || "" )

				process_method_comment( comment ) #unless comment[ :methods ].nil?

				comment[ :method_name ] = obj.name.to_str

				@behaviours[ @current_behaviour ][ :methods ] << comment

				#puts "\n%s (%s)" % [ obj.name, obj.visibility ] #{obj.param_seq}"

				#puts "#{obj.source_code}" # Source code, unformatted
				#puts "====================================="

			end

			@output[ :methods ].push( obj )

		end

		def process_alias( obj )

			@output[ :aliases ].push( obj )

		end

		def process_constant( obj )

			@output[ :constants ].push( obj )

		end

		def process_attribute( obj )

			#puts "\n%s (%s, %s)" % [ obj.name, obj.visibility, obj.rw ] #{obj.param_seq}"
			#p process_comment( obj.comment || "" )

			@output[ :attributes ].push( obj )     

		end

		def process_require(obj)

			@output[:requires].push( obj ) 

		end

		def process_include( obj )

			#p obj.name

			@output[ :includes ].push( obj )     

		end   

		# get the source code
		def get_source_code( method )

			method.token_stream.collect{ | token |

				token ? token.text : "" 
				
			}.join

		end

	end

	# dynamically add a source code attribute to the base oject of code_objects.rb
	class RDoc::AnyMethod

		attr_accessor :source_code	  

	end

end

