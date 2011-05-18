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

=begin
module TDriver

  class ParameterUserAPI

    class << self

      # TODO: document me
      def []=( key, value )

        $parameters[ key ] = value

      end

      # TODO: document me
      def []( *args )

        $parameters[ *args ]

      end

      # TODO: document me
      def fetch( *args, &block )

        $parameters.fetch( *args, &block )

      end

      # TODO: document me
      def files

        $parameters.files

      end

      # TODO: document me
      def clear

        $parameters.clear

      end

      # TODO: document me
      def load_xml( filename )

        $parameters.parse_file( filename )

      end

      # TODO: document me
      def reset( *keys )

        $parameters.reset

      end

      # TODO: document me
      def inspect

        $parameters.inspect

      end

      # TODO: document me
      def to_s

        $parameters.to_s

      end

      # TODO: document me
      def keys

        $parameters.keys

      end

      # TODO: document me
      def values

        $parameters.values

      end

      # TODO: document me
      def configured_suts
      
        $parameters.configured_suts
      
      end

    end # self

    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ParameterUserAPI

end # TDriver

module MobyUtil

  class ParameterUserAPI
  
    class << self
    
      def method_missing( id, *args )
      
        warn_caller "$1:$2 warning: deprecated method, use TDriver::ParameterUserAPI##{ id.to_s } instead of MobyUtil::ParameterUserAPI##{ id.to_s }"
      
        TDriver::ParameterUserAPI.__send__( id, *args )
            
      end

      # TODO: document me
      def instance

        warn_caller "$1:$2 warning: #{ self.name } is static class, use TDriver::ParameterUserAPI#method instead of using instance method"

        TDriver::ParameterUserAPI

      end
    
    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
  
  end
  
end
=end
