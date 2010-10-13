############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of TDriver. 
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

module MobyBehaviour

  module QT

    # == description
    # This module contains demonstration implementation containing tags for documentation generation using gesture as an example
    #
    # == behaviour
    # QtExampleGestureBehaviour
    #
    # == requires
    # *
    # == input_type
    # touch
    #
    # == sut_type
    # qt
    #
    # == sut_version
    # *
    #
    # == objects
    # *;sut
    #
    module Gesture

      # == description
      # example desc
      #
      # == returns
      # String
      #  description: Return value type
      #  example: "World"
      # == arguments
      # value
      #  Integer
      #   description: Example argument1
      #   example: 10
      attr_accessor :z
   
      # == description
      # Cause a flick operation on the screen. 
      #
      # == arguments
      # direction
      #  Integer
      #   description: Example argument1
      #   example: 10
      #  Hash
      #   description:
      #    Example argument 1 type 2
      #   example: { :optional_1 => "value_1", :optional_2 => "value_2" }
      #
      # button
      #  Symbol
      #   description: which button to use
      #   example: :Right
      #   xdefault: :Left_OVERRIDE
      #
      # optional_params
      #  String
      #   description: optinal parameters for blaa blaa blaa
      #   example: {:a => 1, :b => 2}
      #
      # == returns
      # String
      #  description: Return value type
      #  example: "World"
      # 
      # == exceptions
      # RuntimeError
      #  description:  example exception
      #
      # ArgumentError
      #  description:  example exception
      #    
      # == tables
      # custom1
      #  title: Custom table1
      #  |hdr1|hrd2|hrd2|
      #  |1.1|1.2|1.3|
      #  |2.1|2.2|2.3|
      # 
      # custom2
      #  title: Custom table2
      #  |id|value|
      #  |0|true|
      #  |1|false|
      # == info
      # See method X, table at Y
      #
      def flick( direction, button = :Left, optional_params = {} )
      begin
          nil
      end

      # == description
      # Wrapper function to return translated string for this SUT to read the values from localisation database.
      #
      # == arguments
      # logical_name
      #  String
      #   description: Logical name (LNAME) of the item to be translated.
      #   example: "txt_button_ok"
      #  Symbol
      #   description: Symbol form of the logical name (LNAME) of the item to be translated.
      #   example: :txt_button_ok
      #
      # file_name
      #  String
      #   description: Optional FNAME search argument for the translation
      #   example: "agenda"
      #
      # plurality
      #  String
      #   description: Optional PLURALITY search argument for the translation
      #   example: "a" or "singular"
      #
      # numerus
      #  String
      #   description: Optional numeral replacement of '%Ln' tags on translation strings
      #   example: "1"
      #   default: "XXYYZZ"
      #  Integer
      #   description: Optional numeral replacement of '%Ln' tags on translation strings
      #   example: 1
      # 
      # lengthvariant
      #  String
      #   description: Optional LENGTHVAR search argument for the translation (1-9)
      #   example: "1"
      #
      # == returns
      # String
      #  description: Translation matching the logical_name
      #  example: "Ok"
      # Array
      #  description: If multiple translations have been found for the search conditions an Array with all Strings be returned
      #  example: ["Ok", "OK"]
      # 
      # == exceptions
      # LanguageNotFoundError
      #  description: In case language is not found
      #
      # LogicalNameNotFoundError
      #  description: In case no logical name is not found for current language
      #
      # MySqlConnectError
      #  description: In case there are problems with the database connectivity
      #
	    def translate( logical_name, file_name = nil, plurality = nil, numerus = nil, lengthvariant = nil )

      end

      # == deprecated
      # 0.9.0
      #
      # == description
      # This method is deprecated, please use [link="#parent"]TestObject#parent[/link] instead.
      #
      def parent_object

        $stderr.puts "warning: TestObject#parent_object is deprecated, please use TestObject#parent instead."      

        @parent

      end

      # == description
	    # Function for translating all symbol values into strings using sut's translate method
	    # Goes through all items in a hash and if a value is symbol then uses that symbol as a logical
	    # name and tries to find a translation for that.
	    # == params
	    # hash:: Hash containing key, value pairs. The parameter will get modified if symbols are found from values
	    # == raises
	    # LanguageNotFoundError:: In case of language is not found
	    # LogicalNameNotFoundError:: In case of logical name is not found for current language
	    # MySqlConnectError:: In case problems with the db connectivity
	    def translate!( hash, file_name = nil, plurality = nil, numerus = nil, lengthvariant = nil )

      end

      # == description
      # Wrapper function to return translated string for this SUT to read the values from localisation database.
      #
      # == returns
      # nil
      #  description: aabbcc
      #  example: 1
      # 
	    def test2

      end


    end



  end
end

#MobyUtil::Logger.instance.hook_methods( MobyBehaviour::QT::Gesture )
