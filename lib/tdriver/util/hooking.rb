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

	class Hooking

		include Singleton

		attr_accessor :wrappee_count
		attr_accessor :wrapped_methods
		attr_accessor :benchmark

		# list of non-wrappable methods
		@@non_wrappable_methods = [ 'instance' ]

		def initialize

			# default values
			@wrapped_methods = {}

			@wrappee_count = 0
			@benchmark = {}

			@logger_method = nil
			@logger_instance = nil

		end

		# Function to set logger instance used by wrapper
		# == params
		# logger_instance:: Instance of TDriver logger
		# == returns
		def set_logger_instance( logger_instance )

			@logger_instance = logger_instance

			nil

		end

		# Function to create logger event - this method is called from wrapper
		# == params
		# text:: Text sent from wrapper
		# arguments:: Not in use
		# == returns
		def log( text, *arguments )

			@logger_instance.log( "debug", "#{ text }" ) unless @logger_instance.nil?

			nil

		end

		# Function to hook all instance and static methods of target Class/Module
		# == params
		# base:: Target Class or Module
		# == returns
		def hook_methods( _base )

			hook_static_methods( _base )
			hook_instance_methods( _base )

			nil

		end

		def add_wrapper( wrapper )

			@wrapped_methods.merge!( wrapper )
			@wrappee_count += 1

		end

		# Function to update method runtime & calls count for benchmark
		# == params
		# method_name:: Name of the target method
		# start_time:: Name of the target method
		# == returns
		# String:: Unique name for wrappee method
		def update_method_benchmark( method_name, start_time, end_time )

			@benchmark[ method_name ].tap{ | hash | 

				hash[ :time_elapsed ] += ( end_time - start_time ) #( end_time < start_time ? ( ( 86400 - start_time.to_f ) + end_time.to_f ) : ( end_time - start_time ) )
				hash[ :times_called ] += 1  

			}

		end

		def print_benchmark( rules = {} )

			# :sort => :total_time || :times_called || :average_time

			rules = { :sort => :total_time, :order => :ascending, :show_uncalled_methods => true }.merge( rules )

			puts "%-80s %15s %25s %25s" % [ 'Name:', 'Times called:', 'Total time elapsed:', 'Average time/call:' ]
			puts "%-80s %15s %25s %25s" % [ '-' * 80, '-' * 15, '-' * 25, '-' * 25 ]

			# calculate average time for method
			( table = @benchmark ).each{ | key, value |
				table[ key ][ :average_time ] = ( value[ :times_elapsed ] == 0 || value[ :times_called ] == 0 ) ? 0 : value[ :time_elapsed ] / value[ :times_called ] 
			}

			table = table.sort{ | method_a, method_b | 

			case rules[ :sort ]

				when :name
					method_a[ 0 ] <=> method_b[ 0 ]

				when :times_called
					method_a[ 1 ][ :times_called ] <=> method_b[ 1 ][ :times_called ]

				when :total_time
					method_a[ 1 ][ :time_elapsed ] <=> method_b[ 1 ][ :time_elapsed ]

				when :average_time
					method_a[ 1 ][ :average_time ] <=> method_b[ 1 ][ :average_time ]

			else

				Kernel::raise ArgumentError.new("Invalid sorting rule, valid rules are :name, :total_time, :time_elapsed or :average_time")

			end

			}

			case rules[ :order ]

				when :ascending
					# do nothing

				when :descending
					table = table.reverse

			else

				Kernel::raise ArgumentError.new("Invalid sort order rule, valid rules are :ascending, :descending")	

			end

			table.each{ | method | 

				puts "%-80s %15s %25.15f %25.15f" % [ method[ 0 ], method[ 1 ][ :times_called ], method[ 1 ][ :time_elapsed ], method[ 1 ][ :average_time ] ] unless !rules[ :show_uncalled_methods ] && method[ 1 ][ :times_called ] == 0

			}

		end


	private

		# Function to hook a method 
		# == params
		# base:: Class or Module
		# method_name:: Name of the method  
		# method_type:: public, private or static
		# == returns
		def hook_method( base, method_name, method_type )

			# create only one wrapper for each method
			unless MobyUtil::Hooking.instance.wrapped_methods.has_key?( "#{ base.name }::#{ method_name }" )

				# evaluate the generated wrapper source code
				eval("base.#{ base.class.name.downcase }_eval( \"#{ make_wrapper( base, method_name.to_s, method_type.to_s )}\" )") if [ Class, Module ].include?( base.class )

			end

			nil

		end

		# Function to hook static methods for given Class or Module
		# == params
		# base:: Target Class or Module
		# == returns
		def hook_static_methods( _base )

			if [ Class, Module ].include?( _base.class )

				_base.singleton_methods( false ).each { | method_name |

					hook_method( _base, method_name, "static" ) unless @@non_wrappable_methods.include?( method_name )

				} 

			end

			nil
		end

		# Function to hook instance methods for given Class or Module
		# == params
		# base:: Target Class or Module
		# == returns
		def hook_instance_methods( _base )

			if [ Class, Module ].include?( _base.class )        

				{ :public => _base.public_instance_methods( false ), :private => _base.private_instance_methods( false ) }.each { | method_type, methods |

					methods.each { | method_name | hook_method( _base, method_name, method_type.to_s ) unless /__wrappee_\d+/i.match( method_name ) }

				}

			end

			nil
		end

		# Function to retrieve method path (e.g. Module1::Module2::Class1)
		# == params
		# base:: Target Class or Module
		# == returns
		# String:: Method path
		def method_path( _base )

			if [ Class, Module ].include?( _base.class )

				_base.name

			else

				_base.class.name

			end

		end

		# Function to generate unique name for wrappee method
		# == params
		# method_name:: Name of the target method
		# == returns
		# String:: Unique name for wrappee method
		def create_wrappee_name( method_name )

			wrappee_name = "non_pritanble_method_name" if ( wrappee_name = ( /[a-z0-9_]*/i.match( method_name ) ) ).length == 0 

			wrappee_name = "__wrappee_#{ @wrappee_count }__#{ wrappee_name }"

		end

		# Function for create source code of wrapper for method 
		# == params
		# base:: Class or Module
		# method_name:: Name of the method  
		# method_type:: public, private or static
		# == returns
		# String:: source code
		def make_wrapper( base, method_name, method_type = nil )

			# method name with namespace
			base_and_method_name = "#{ base.name }::#{ method_name }"

			# add method to benchmark table
			@benchmark[ base_and_method_name ] = { :time_elapsed => 0 , :times_called => 0 } if ENV[ 'TDRIVER_BENCHMARK' ].to_s.downcase == 'true'

			# create new name for original method 
			original_method_name = create_wrappee_name( method_name )

			# add method to wrapper methods list
			@wrapped_methods.merge!( base_and_method_name => nil )
			@wrappee_count += 1

			case method_type

				when 'public', 'private', 'static'

					source = "
							#{
							# this is needed if method is static
							"class << self" if method_type == 'static' 

							}

								# create a copy of original method
								alias_method :#{ original_method_name }, :#{ method_name }

								#{ 

									if method_type == 'static'

										# undefine original version if static method
										"self.send( :undef_method, :#{ method_name } )"

									else

										# method visiblity unless method type is static
										"#{ method_type }"

									end

						
								}

								def #{ method_name }( *args, &block )

									# log method call
									MobyUtil::Hooking.instance.log( '#{ method_path( base ) }.#{ method_name }', nil )

									#{

										if ENV[ 'TDRIVER_BENCHMARK' ].to_s.downcase == 'true'
							
											"# store start time for performance measurement
											start_time = Time.now

											# call original method
											result = self.method(:#{ original_method_name }).call( *args, &block )

											# store performance results to benchmark hash
											MobyUtil::Hooking.instance.update_method_benchmark( '#{ base_and_method_name }', start_time, Time.now )

											# return results
											result"

										else

											"# call original method
											result = self.method(:#{ original_method_name }).call( *args, &block )"

										end

									}

								end


							#{ 

							# this is needed if method is static
							"end" if method_type == 'static' 

							}" 

			end

		end

	end # Hooking

end # MobyUtil
