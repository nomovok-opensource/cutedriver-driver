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

$scenarios = 0
$templates = {} unless defined?( $templates )

$scenario_files = {}

module Generators

  abort("") unless defined?( RDoc )

	class TDriverFeatureTestGenerator

    def self.for( options )

      new( options )

    end

    def initialize( options )

      @options = options

      @already_processed_files = []

      @current_module_tests = []

      @current_module = nil

      @output = { :files => [], :classes => [], :modules => [], :attributes => [], :methods => [], :aliases => [], :constants => [], :requires => [], :includes => []}

    end

    def generate( files )

      # process files
      files.each{ | file |
        
        process_file( file ) unless @already_processed_files.include?( file.file_absolute_name )

      }

      p "total scenarios: %s" % $scenarios

      #p @already_processed_files

    end

    def process_file( file )

      @module_path = []
      
      @current_file = file
  
      process_modules( file.modules )    

    end

    def process_modules( modules )

      modules.each{ | _module | 

        unless @already_processed_files.include?( _module.full_name )

          @module_path.push( _module.name )

          process_module( _module ) 

          @module_path.pop

        end

      }

    end

    def process_methods( methods )

      results = []

      methods.each{ | method | 

        scenarios = process_method( method ) 

        results << { :header => $templates[:feature_method] % [ "%s#%s" % [ @module_path.join("::"), method.name ], method.name, @module_path.join("::") ], :scenarios => scenarios, :file => generate_name( method.name ), :module_path => @module_path, :name => method.name } if scenarios.count > 0

      }

      results

    end

    def process_arguments( arguments )

      # tokenize string
      tokenizer = RubyLex.new( arguments )

      # get first token
      token = tokenizer.token

      # set previous token to nil by default
      previous_token = nil

      args = []
      
      capture = false
      capture_depth = []

      # loop while tokens available
      while token

        if [ RubyToken::TkLBRACE, RubyToken::TkLPAREN, RubyToken::TkLBRACK ].include?( token.class )
        
          capture_depth << token
        
          capture = true

        elsif [ RubyToken::TkRBRACE, RubyToken::TkRPAREN, RubyToken::TkRBRACK ].include?( token.class )

          capture_depth.pop
          
          capture = false if capture_depth.empty?

        # argument name
        elsif capture == false
        
          if token.kind_of?( RubyToken::TkIDENTIFIER )

          args << [ token.name, nil, false ]

          # &blocks and *arguments are handled as optional parameters
          args.last[ -1 ] = true if [ RubyToken::TkBITAND, RubyToken::TkMULT ].include?( previous_token.class )
                  
          # detect optional argument
          elsif token.kind_of?( RubyToken::TkASSIGN )

            # mark arguments as optional
            args.last[ -1 ] = true

            opt = true

          end

        end

        # store previous token
        previous_token = token

        # get next token
        token = tokenizer.token

      end

      args

    end

    def generate_scenarios( mode, arguments_table = nil )

        results = []

        # first scenario with all required arguments
        if mode.to_s =~ /method/

          required_arguments = arguments_table.select{ | argument | argument.last == false }.to_a.collect{ | scenario | scenario.first } # Array conversion for ruby 1.9 compatibility

          results << $templates[ mode ] % [ @current_method.name, "required", "(s)", @current_method.name, required_arguments.join(", ") ]

        elsif mode.to_s =~ /attribute/

          name = @current_attribute.first.name

          name << "=" if @current_attribute.count > 1

          results << $templates[ mode ] % [ name, name ]

        end

        unless arguments_table.nil?

          # scenarios with one of each optional argument.. and eventually with all arguments
          arguments_table.select{ | argument | argument.last == true }.to_a.collect{ | scenario | scenario 
            # Array conversion for ruby 1.9 compatibility
            scenario = required_arguments << scenario.first

            results << $templates[ mode ] % [ @current_method.name, "optional", " '%s'" % scenario.last.first, @current_method.name, scenario.join(", ") ]

          }

        end

        results

    end

    def process_method( method )

      scenarios = []

      if ( method.visibility == :public && @module_path.first =~ /MobyBehaviour/ )

        arguments_table = process_arguments( method.params )

        @current_method = method

        scenarios = generate_scenarios( :scenario_method, arguments_table )
          
        $scenarios += scenarios.count

      else

      end

      scenarios

    end

    # verify if 
    def has_method?( target, method_name )

        target.method_list.select{ | method | 
        
          method.name == method_name 
          
        }.count > 0
    
    end

    def process_attributes( attributes )

      results = []

      attributes.each{ | attribute | 

         scenarios = process_attribute( attribute ) 

         attr_name = attribute.name.gsub("=",'')

         results << { :header => $templates[:feature_attribute] % [ "%s#%s" % [ @module_path.join("::"), attribute.name ], attr_name, @module_path.join("::") ], :scenarios => scenarios, :file => generate_name( attr_name ), :module_path => @module_path, :name => attr_name } if scenarios.count > 0

      }

      results

    end

    def process_attribute( attribute )

      result = []

      if ( @module_path.first =~ /MobyBehaviour/ )

        @current_attribute = [ attribute ]

        #p @module_path

        scenarios = []

        case attribute.rw
      
          when 'RW'
            # verify first that if attribute is overwritten as method 
            unless has_method?( @current_module[ :object ], attribute.name )
              scenarios << generate_scenarios( :scenario_attribute )
              scenarios.pop if scenarios.last == []
            end

            # verify first that if attribute is overwritten as method 
            unless has_method?( @current_module[ :object ], "%s=" % attribute.name )
              @current_attribute << "W"
              scenarios << generate_scenarios( :scenario_attribute )
              scenarios.pop if scenarios.last == []
            end

          when 'W'
            # verify first that if attribute is overwritten as method 
            unless has_method?( @current_module[ :object ], "%s=" % attribute.name )
              @current_attribute << "W"
              scenarios << generate_scenarios( :scenario_attribute )
              scenarios.pop if scenarios.last == []
            end
          
          when 'R'

            # verify first that if attribute is overwritten as method 
            unless has_method?( @current_module[ :object ], attribute.name )
              scenarios << generate_scenarios( :scenario_attribute )
              scenarios.pop if scenarios.last == []
            end

        else

          abort( "Unknown attribute rw status: %s" % attribute.rw )

        end

        if scenarios.count > 0

          #puts $templates[:feature]
          result << scenarios 
          #puts scenarios

          $scenarios += scenarios.count

        end


      else

       #puts "%s method: %s" % [ method.visibility.to_s, method.name ]

      end
  
      result

    end

    def generate_name( method )

      name = @module_path[ 1 .. -1 ].join("_")

      begin

        n = name.bytes.to_a

        result = ""

        n.each_with_index{ | byte, index |

          if byte == 95

            result << byte.chr 
            next

          end

          unless index == 0

            prefix = ""

            if (65..90).include?( byte ) or (48..57).include?( byte )
          
              prefix = "_"

              unless ( index + 1) > ( n.count - 1 )

                next_byte = n[ index + 1 ]

                # do not add underscore if next character is in uppercase or numeric
                prefix = "" if (65..90).include?( next_byte ) or (48..57).include?( next_byte ) or next_byte == 95

              else

                prev_byte = n[ index - 1 ]

                prefix = "" if ( 65..90 ).include?( prev_byte ) or ( 48..57 ).include?( prev_byte ) or prev_byte == 95

              end

            end

            result << prefix + byte.chr.downcase

          else

            # first char, don't care if uppercase
            result << byte.chr

          end

        }

        name = result.gsub( /_+/, "_")

      rescue

        name = name.downcase

      end

      name << "_" << method

      name.gsub!(/[?!=]/){ | char | char = "_0x%x" % char[0] }

      ( name + ".feature" ).downcase

    end

    def generate_feature( data )

      path = File.join( data[:file] )

      open( path, 'w' ){ | file | 

        file << data[:header]

        file << data[:scenarios]

      }

    end

    def process_module( _module )

      @already_processed_files << _module.full_name

      @current_module = { :object => _module, :scenarios => [] }

      # process methods
      methods = process_methods( _module.method_list )

      # process attributes
      attributes = process_attributes( _module.attributes )

      unless ( methods.empty? && attributes.empty? )

        methods.each{ | method |

          generate_feature( method )

          puts method[:file]

          puts method[:header]

          puts method[:scenarios]

        }

        
        attributes.each{ | method |

          generate_feature( method )

          puts method[:file]

          puts method[:header]

          puts method[:scenarios]

        }

      end

      # process if any child modules 
      process_modules( _module.modules ) unless _module.modules.empty?

    end

  end

end
