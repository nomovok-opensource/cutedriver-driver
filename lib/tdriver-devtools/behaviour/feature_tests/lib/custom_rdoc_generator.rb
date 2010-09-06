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

      @scenarios = []

      @output = { :files => [], :classes => [], :modules => [], :attributes => [], :methods => [], :aliases => [], :constants => [], :requires => [], :includes => []}

    end

    def generate( files )

      # process files
      files.each{ | file |
        
        process_file( file ) unless @already_processed_files.include?( file.file_absolute_name )

      }

      p "scenarios: %s" % $scenarios

      p @already_processed_files

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

      methods.each{ | method | process_method( method ) }

    end

    def process_arguments( arguments )

      # tokenize string
      tokenizer = RubyLex.new( arguments )

      # get first token
      token = tokenizer.token

      # set previous token to nil by default
      previous_token = nil

      args = []

      # loop while tokens available
      while token

        # argument name
        if token.kind_of?( RubyToken::TkIDENTIFIER )

          args << [ token.name, nil, false ]

          # &blocks and *arguments are handled as optional parameters
          args.last[ -1 ] = true if [ RubyToken::TkBITAND, RubyToken::TkMULT ].include?( previous_token.class )

        # detect optional argument
        elsif token.kind_of?( RubyToken::TkASSIGN )

          # mark arguments as optional
          args.last[ -1 ] = true

        end

        # store previous token
        previous_token = token

        # get next token
        token = tokenizer.token

      end

      args

    end

    def generate_scenarios( arguments_table )

        # first scenario with all required arguments
        required_arguments = arguments_table.select{ | argument | argument.last == false }.collect{ | scenario | scenario 

          p "scenario: %s\n\n" % scenario

          scenario

        }

        # scenarios with one of each optional argument.. and eventually with all arguments
        arguments_table.select{ | argument | argument.last == true }.collect{ | scenario | scenario 

          scenario = required_arguments << scenario

          p "scenario: %s\n\n" % [ scenario.inspect ]

          #p "scenario: %s\n\n" % [ opposite_scenario.inspect ]

        }

        required_arguments

    end

    def process_method( method )

      if ( method.visibility == :public && @module_path.first =~ /MobyBehaviour/ )

        p @module_path

        p method.name

        p method.params

        arguments_table = process_arguments( method.params )

        scen = generate_scenarios( arguments_table )

        p "minimum:"
        p scen

        scenarios = 1

        scenarios += arguments_table.select{ | argument | argument.last == true }.count

        $scenarios += scenarios

        p arguments_table

        @current_module

        puts "scenarios: %s" % scenarios

        puts ""

      else

       #puts "%s method: %s" % [ method.visibility.to_s, method.name ]

      end

    end

    # verify if 
    def has_method?( target, method_name )

        target.method_list.select{ | method | 
        
          method.name == method_name 
          
        }.count > 0
    
    end

    def process_attributes( attributes )

      attributes.each{ | attribute | process_attribute( attribute ) }

    end

    def process_attribute( attribute )

      if ( @module_path.first =~ /MobyBehaviour/ )

        p @module_path

        scenarios = 0

        case attribute.rw
      
          when 'RW'
            # verify first that if attribute is overwritten as method 
            scenarios += 1 unless has_method?( @current_module[ :object ], attribute.name )

            # verify first that if attribute is overwritten as method 
            scenarios += 1 unless has_method?( @current_module[ :object ], "%s=" % attribute.name )

          when 'W'
            # verify first that if attribute is overwritten as method 
            scenarios += 1 unless has_method?( @current_module[ :object ], "%s=" % attribute.name )
          
          when 'R'
            # verify first that if attribute is overwritten as method 
            scenarios += 1 unless has_method?( @current_module[ :object ], attribute.name )

        else

          abort( "Unknown attribute rw status: %s" % attribute.rw )

        end

        $scenarios += scenarios

        p attribute.name

        puts "scenarios: %s" % scenarios

        puts ""

      else

       #puts "%s method: %s" % [ method.visibility.to_s, method.name ]

      end

    end

    def process_module( _module )

      @already_processed_files << _module.full_name

      @current_module = { :object => _module, :scenarios => [] }

      # process methods
      process_methods( _module.method_list )

      # process attributes
      process_attributes( _module.attributes )

      @scenarios << @current_module

      # process if any child modules 
      process_modules( _module.modules ) unless _module.modules.empty?

    end

  end

end
