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

module Kernel

  def warn_caller( message, remove_eval = true )

    # verify that message argument type is correct
    raise TypeError, "wrong argument type #{ message.class } for message (expected String)" unless message.kind_of?( String )

    # verify that remove_eval argument type is correct
    raise TypeError, "wrong argument type #{ remove_eval.class } for remove evaluate calls value (expected TrueClass or FalseClass)" unless [ TrueClass, FalseClass ].include?( remove_eval.class )

    # retrieve caller method, file and line number
    begin

      # remove evals if required
      caller_stack = ( remove_eval == true ? caller.select{ | str | str !~ /^\(eval\)\:/ and str !~ /`eval'$/ } : caller )

      # retrieve filename, line number and method name
      /^(.+?):(\d+)(?::in `(.*)')?/.match( caller_stack.reverse[ -2 ].to_s )

      # store matches
      file, line, method = $1, $2, $3

    rescue

      # could not retrieve filename, line number and method name
      file, line, method = [ '##', '##', 'unknown' ]

    end 
  
    # print warning to STDOUT
    warn message.gsub( '$1', file.to_s ).gsub( '$2', line.to_s ).gsub( '$3', method.to_s )

  end

end

module MobyUtil

  # Helper class to store verify block for 
  # constant verifications for sut state
  class VerifyBlock 

    attr_accessor :block,:expected, :message,:source, :timeout

    def initialize(block, expected, message = nil, timeout = nil, source = "")

      @block = block
      @expected = expected
      @message = message
      @timeout = timeout
      @source = source

    end

  end

  class KernelHelper

    # Function to determine if given value is boolean
    # == params
    # value:: String containing boolean
    # == returns
    # TrueClass::
    # FalseClass::
    def self.boolean?( value )

      /^(true|false)$/i.match( value.to_s ).kind_of?( MatchData ) rescue false

    end

    # Function to return boolean of given value
    # == params
    # value:: String containing boolean
    # == returns
    # TrueClass::
    # FalseClass::
    def self.to_boolean( value, default = nil )

      /^(true|false)$/i.match( value.to_s ) ? $1.downcase == 'true' : default

    end

    # Function to return class constant from a string
    # == params
    # constant_name:: String containing path
    # == returns
    # Class
    def self.get_constant( constant_name )

      begin

        constant_name.split("::").inject( Kernel ){ | scope, const_name | scope.const_get( const_name ) }

      rescue 

        Kernel::raise NameError.new( "Invalid constant %s" % constant_name )

      end

    end

    def self.parse_caller( at )

      if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at

        file = Regexp.last_match[ 1 ]
        line = Regexp.last_match[ 2 ].to_i
        method = Regexp.last_match[ 3 ]

        [ file, line, method ]

      end

    end

    def self.deprecated( deprecated_name, new_name = "" )

      output = "warning: #{ deprecated_name } is deprecated"

      output += "; use #{ new_name } instead" unless new_name.empty?

      $stderr.puts output

    end

    # Searches for the given source file for a line
    #
    # === params
    # from_file:: String defining the file to load. If at_line is nil, this argument can also contain a path and line number separated by : (eg. some_dir/some_file.rb:123).
    # at_line:: (optional) Integer, number of the line (first line is 1).
    # === returns
    # String:: Contents of the line
    # === throws
    # RuntimeError:: from_file is not correctly formed, the file cannot be loaded or the line cannot be found.
    def self.find_source( backtrace )

      result = "\n"

      begin

        # split with colon 
        call_stack = backtrace.to_s.split(':')
          
        # TODO: document me      
        line_number = ( call_stack.size == 2 ? call_stack[ 1 ].to_i : call_stack[ call_stack.size - 2 ] ).to_i

        file_path = ""
        
        # TODO: document me      
        if ( call_stack.size == 2 )
        
          file_path = call_stack[ 0 ]
          
        else
        
          # TODO: document me      
          ( call_stack.size - 2 ).times do | index |
          
            file_path << "%s:" % call_stack[ index ]
            
          end
          
          # remove the trailing colon
          file_path.slice!(-1)
          
        end
        
        # TODO: document me      
        lines_to_read = line_number >= 2 ? 3 : line_number
        #puts "lines to read: " << lines_to_read.to_s

        # TODO: document me      
        start_line = line_number #- (lines_to_read <= 1 ? 0 : 1)
        #puts "start line:" << start_line.to_s

        # expand file path and name 
        filename = File.expand_path( file_path.to_s )

        # open source file
        File.open( filename, "r") { | source |

          # read lines
          lines = source.readlines
          
          # raise exception if line number is larger than total number of lines
          Kernel::raise RuntimeError.new(
          
            "Unable to fetch line %s from source file %s due to it is out of range (total lines: %s)" %  [ start_line, filename, lines.size ]
            
          ) if start_line > lines.size

          # TODO: document me
          lines_to_read = ( lines.size - start_line + 1 ) < 3 ? ( lines.size - start_line + 1 ) : lines_to_read
          
          # the array is zero based, first line is at position 0
          lines_to_read.times do | index |

            # add "=>" to line which failed                       
            result << ( ( line_number == ( start_line + index ) ) ? "=> " : "   " ) + lines[ start_line + index - 1 ]
            
          end

        }

      rescue Exception => e

        result << "Unable to load source lines.\n#{ e.inspect }"

      end

      # return result string
      result

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # KernelHelper

end # MobyUtil
