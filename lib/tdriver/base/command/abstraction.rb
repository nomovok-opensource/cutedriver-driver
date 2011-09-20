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

module TDriver

  class Command

    class Abstraction

      attr_accessor :sut

      # class initialization
      def initialize( options )

        @options = options

        @sut = @options[ :sut ]

        @object = @options[ :object ]

      end

      def sut_parameters

        $parameters[ @sut.id ]

      end 

      def test_object_adapter

        @sut.instance_variable_get( :@test_object_adapter )

      end

      def test_object_factory

        @sut.instance_variable_get( :@test_object_factory )

      end

    end # Abstraction

  end # Commands

end # TDriver
