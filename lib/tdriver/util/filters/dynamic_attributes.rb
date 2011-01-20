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

	class DynamicAttributeFilter

		include Singleton

		attr_accessor :filter_string

		def initialize

			@filter_string = "" # coma separated list of symbol names in the filter

			@attributes = []

			@files = []

		end

		def update_filter( backtrace )

			begin

				if backtrace.collect{ | stack_point |

						next if stack_point =~ /^\(eval\)/ # skip eval trace lines

						read_attributes_from_file( $1 ) unless @files.include?( $1 ) if stack_point =~ /([\w\/:_\-\.\\\s\']+\.rb):\d+/

				}.include?( true )

					# new symbols added, update filter string
					update_filter_string

				end

			rescue Exception => exception

				puts exception

				puts exception.backtrace

			end
		end

		# Adds a hard coded symbol to be added to every filter.
		# Used in situations when variables are used to identify
		# attributes e.g:
		# var = 'text'
		# app.Object.attribute(var)
		def add_hardcoded_symbol( symbol )

			$stderr.puts "warning: DynamicAttributeFilter#add_hardcoded_symbol is deprecated, please use DynamicAttributeFilter#add_attribute instead."

			# update filter if new symbols added
			update_filter_string if add_attribute_to_filter( symbol )

		end

    def has_attribute?( symbol )
    
      @attributes.include?( symbol.to_s )
    
    end

		def add_attribute( symbol )

			# update filter if new symbols added
			update_filter_string if add_attribute_to_filter( symbol )

		end

		def add_attributes( symbols )

			# update filter if new symbols added
			update_filter_string if symbols.collect{ | symbol | add_attribute_to_filter( symbol ) }.include?( true )

		end

	private

		# == returns
		# Boolean:: determine that was symbol added to attributes list or not
		def add_attribute_to_filter( symbol )

			symbol = symbol.to_s

			unless @attributes.include?( symbol )

				# add symbol to atributes list
				@attributes << symbol

				true

			else

				false

			end
			
		end

		def update_filter_string

			@filter_string = @attributes.join( "," )

		end

		# This method will parse a file to collect its symbols and add them to the @filter
		# It will skip already parsed files
		# == params
		# String:: File path to the file to parse for symbols
		# == returns
		#
		# == throws
		#
		def read_attributes_from_file( file_name )

			#DEBUG 
			#puts "File skipped :" + file_name if @files.include?( file_name )

			unless @files.include?( file_name )

				open( file_name ) do | file |

					file.each do | line |

						# Line Parser
						next if ( line.nil? or line =~ /^#/ ) # ignore comments

						line_symbols = 
							(
								# :attribute => value
								line.scan( /[^:]\:(\w+)\s*\=\>/ ) 	

							).concat( 

								# .attribute( 'name' )
								line.scan( /\.attribute\s*[\(\s]{1}\s*["']{1}(\w+)["']{1}[\)\s]{1}/ ) 

							).concat( 

								# .attribute( :name )
								line.scan( /\.attribute\s*[\(\s]{1}\s*[:]{1}(\w+)[\)\s]{1}/ ) 
							)

						next if line_symbols.empty? # skip lines with no symbols	

						# store found attributes
						@attributes.concat( line_symbols.collect{ | value | value[ 0 ] }.compact ).uniq!
					end

				end 

				# store filename that we don't scan the file again...
				@files << file_name

				# do not change this or evaluate anything after this line; update filter behaviour depends of this return value
				true

			end

		end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	end # DynamicAttributeFilter
  
end # MobyUtil
