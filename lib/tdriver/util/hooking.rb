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
			
			$mobyutil_hooking_instance = self
      $mobyutil_hooking_elapsed_time = []

      $mobyutil_hooking_start_benchmark_time = Time.now  
      $mobyutil_hooking_last_call_end_time = Time.now
  
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


			unless @logger_instance.nil?

				@logger_instance.debug( "%s" % text ) # if @logger_instance.enabled

			end

			#@logger_instance.log( "debug", "%s" % text ) unless @logger_instance.nil?

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
		# time_elapsed_in_subcalls:: 
		# total_time_elapsed:: 
		def update_method_benchmark( method_name, time_elapsed_in_subcalls, total_time_elapsed )

			@benchmark[ method_name ].tap{ | hash | 

				hash[ :time_elapsed ] += ( total_time_elapsed - time_elapsed_in_subcalls ) 
				hash[ :time_elapsed_total ] += total_time_elapsed
				hash[ :times_called ] += 1  

			}

		end

		def print_benchmark( rules = {} )

		  #total_run_time = $mobyutil_hooking_last_call_end_time - $mobyutil_hooking_start_benchmark_time

      total_run_time = 0

			# :sort => :total_time || :times_called || :average_time

			rules = { :sort => :total_time, :order => :ascending, :show_uncalled_methods => true }.merge( rules )

			puts "%-80s %8s %15s %15s %9s %15s" % [ 'Name:', 'Calls:', 'Time total:', 'W/O subcalls:', '%/run', 'Total/call:' ]
			puts "%-80s %8s %15s %15s %9s %15s" % [ '-' * 80, '-' * 8, '-' * 15, '-' * 15, '-' * 8, '-' * 15 ]

			# calculate average time for method
			( table = @benchmark ).each{ | key, value |
			
				table[ key ][ :average_time ] = ( value[ :times_elapsed_total ] == 0 || value[ :times_called ] == 0 ) ? 0 : value[ :time_elapsed_total ] / value[ :times_called ] 
				
	      total_run_time += value[ :time_elapsed ]

			}

			table = table.sort{ | method_a, method_b | 

			case rules[ :sort ]

				when :name
					method_a[ 0 ] <=> method_b[ 0 ]

				when :times_called
					method_a[ 1 ][ :times_called ] <=> method_b[ 1 ][ :times_called ]

				when :total_time
					method_a[ 1 ][ :time_elapsed_total ] <=> method_b[ 1 ][ :time_elapsed_total ]

				when :total_time_no_subs
					method_a[ 1 ][ :time_elapsed ] <=> method_b[ 1 ][ :time_elapsed ]

        when :percentage
        
          ( ( method_a[ 1 ][ :time_elapsed ].to_f / total_run_time.to_f ) * 100 ) <=> ( ( method_b[ 1 ][ :time_elapsed ].to_f / total_run_time.to_f ) * 100 )

				when :average_time
					method_a[ 1 ][ :average_time ] <=> method_b[ 1 ][ :average_time ]

			else

				Kernel::raise ArgumentError.new("Invalid sorting rule, valid rules are :name, :times_called, :total_time, :total_time_no_subs, :percentage or :average_time")

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

      total_percentage = 0.0
      total_time_elapsed_total = 0.0
      total_average = 0.0
      total_calls = 0

			table.each{ | method | 

				puts "%-80s %8s %15.8f %15.8f %8.3f%% %15.8f" % [ 
				  method[ 0 ], 
				  method[ 1 ][ :times_called ], 
				  method[ 1 ][ :time_elapsed_total ], 
				  method[ 1 ][ :time_elapsed ], 
				  
          ( ( method[ 1 ][ :time_elapsed ].to_f / total_run_time.to_f ) * 100 ),
				  
				  method[ 1 ][ :average_time ] 
			  ] unless !rules[ :show_uncalled_methods ] && method[ 1 ][ :times_called ] == 0

        total_percentage += ( ( method[ 1 ][ :time_elapsed ].to_f / total_run_time.to_f ) * 100 )

        total_calls += method[ 1 ][ :times_called ]
        total_time_elapsed_total += method[ 1 ][ :time_elapsed_total ]        
        total_average += method[ 1 ][ :average_time ]

			}

			puts "%-80s %8s %15s %15s %9s %15s" % [ '-' * 80, '-' * 8, '-' * 15, '-' * 15, '-' * 8, '-' * 15 ]

			puts "%-80s %8s %15.6f %15.6f %8.3f%% %15.8f" % [ 'Total:', total_calls, total_time_elapsed_total, total_run_time, total_percentage, total_average ]

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

				{ :public => _base.public_instance_methods( false ), :private => _base.private_instance_methods( false ), :protected => _base.protected_instance_methods( false ) }.each { | method_type, methods |

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
			@benchmark[ base_and_method_name ] = { :time_elapsed => 0 , :times_called => 0, :time_elapsed_total => 0 } if ENV[ 'TDRIVER_BENCHMARK' ].to_s.downcase == 'true'

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
									$mobyutil_hooking_instance.log( '#{ method_path( base ) }.#{ method_name }', nil )

									#{

										if ENV[ 'TDRIVER_BENCHMARK' ].to_s.downcase == 'true'
							
											"# store start time for performance measurement
											start_time = Time.now
                      
                      # Time elapsed in sub calls
                      $mobyutil_hooking_elapsed_time << 0.0

                      begin

											  # call original method
											  result = send(:#{ original_method_name }, *args, &block )

                      rescue Exception => exception

                        raise exception
                      
                      ensure
    
                        # calculate actual elapsed time, including time elapsed in sub calls
                        elapsed_time = ( ( $mobyutil_hooking_last_call_end_time = Time.now ) - start_time )

                        # elapsed time in sub calls
                        elapsed_time_in_subcalls = $mobyutil_hooking_elapsed_time.pop || 0
                                                
                        # add elapsed time to caller method 
                        $mobyutil_hooking_elapsed_time[ -1 ] += elapsed_time unless $mobyutil_hooking_elapsed_time.empty?

											  # store performance results to benchmark hash
											  $mobyutil_hooking_instance.update_method_benchmark( '#{ base_and_method_name }', elapsed_time_in_subcalls, elapsed_time )

                      end

											# return results
											result"

										else

											"# call original method
  									  result = send(:#{ original_method_name }, *args, &block )"

										end

									}

								end

							private :#{ original_method_name }

							#{ 

							# this is needed if method is static
							"end" if method_type == 'static' 

							}" 

			end

		end

	end # Hooking

end # MobyUtil
