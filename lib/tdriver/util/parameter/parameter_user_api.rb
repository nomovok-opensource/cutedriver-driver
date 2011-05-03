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

  class ParameterUserAPI

    #include Singleton

    # TODO: document me
    def self.instance

      warn("warning: #{ self.name } is static class, use MobyUtil::ParameterUserAPI#method instead of using instance method")

      MobyUtil::ParameterUserAPI

    end

    # TODO: document me
    def self.[]=( key, value )

      $parameters[ key ] = value

    end

    # TODO: document me
    def self.[]( *args )

      $parameters[ *args ]

    end

    # TODO: document me
    def self.fetch( *args, &block )

      $parameters.fetch( *args, &block )

    end

    # TODO: document me
    def self.files

      $parameters.files

    end

    # TODO: document me
    def self.clear

      $parameters.clear

    end

    # TODO: document me
    def self.load_xml( filename )

      $parameters.parse_file( filename )

    end

    # TODO: document me
    def self.reset( *keys )

      $parameters.reset

    end

    # TODO: document me
    def self.inspect

      $parameters.inspect

    end

    # TODO: document me
    def self.to_s

      $parameters.to_s

    end

    # TODO: document me
    def self.keys

      $parameters.keys

    end

    # TODO: document me
    def self.values

      $parameters.values

    end

    # TODO: document me
    def self.configured_suts
    
      $parameters.configured_suts
    
    end

    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ParameterUserAPI

end # MobyUtil
