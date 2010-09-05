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

      tokenizer = RubyLex.new( arguments )

      token = tokenizer.token

      previous_token = nil

      args = []

      while token

        # argument name
        if token.kind_of?( RubyToken::TkIDENTIFIER )

          args << [ token.name, false ]

          # &blocks and *arguments are handled as optional parameters
          args.last[ -1 ] = true if [ RubyToken::TkBITAND, RubyToken::TkMULT ].include?( previous_token.class )

        # detect optional argument
        elsif token.kind_of?( RubyToken::TkASSIGN )

          args.last[ -1 ] = true

        end

        previous_token = token

        token = tokenizer.token

      end

      args

    end

    def process_method( method )

      if ( method.visibility == :public && @module_path.first =~ /MobyBehaviour/ )

        p @module_path

        p method.name

        p method.params

        arguments_table = process_arguments( method.params )

        scenarios = 1

        scenarios += arguments_table.select{ | argument | argument.last == true }.count

        $scenarios += scenarios

        p arguments_table

        puts "scenarios: %s" % scenarios

        puts ""

      else

       #puts "%s method: %s" % [ method.visibility.to_s, method.name ]

      end

    end

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
            scenarios += 1 unless has_method?( @current_module, attribute.name )

            # verify first that if attribute is overwritten as method 
            scenarios += 1 unless has_method?( @current_module, "%s=" % attribute.name )

          when 'W'
            # verify first that if attribute is overwritten as method 
            scenarios += 1 unless has_method?( @current_module, "%s=" % attribute.name )
          
          when 'R'
            # verify first that if attribute is overwritten as method 
            scenarios += 1 unless has_method?( @current_module, attribute.name )

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

      @current_module = _module

      process_methods( _module.method_list )

      process_attributes( _module.attributes )

      # process if any child modules 
      process_modules( _module.modules ) unless _module.modules.empty?

    end

  end

end

