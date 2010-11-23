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

class String

  def not_empty( message = "String must not be empty", exception = ArgumentError )

    raise exception.new( message ) if self.empty? 

  end

  # Function determines if string is "true" or "false"
  # == params
  # string:: String
  # == returns
  # TrueClass/FalseClass 
  def boolean?

    /^(true|false)$/i.match( self ).kind_of?( MatchData )

  end    

  # Function determines if string is numeric
  # == params
  # string:: Numeric string
  # == returns
  # TrueClass/FalseClass 
  def numeric?

    /[0-9]+/.match( self ).kind_of?( MatchData )

  end  

  # Function converts "true" or "false" to boolean 
  # == params
  # string:: String
  # == returns
  # TrueClass/FalseClass 
  def to_boolean

    if /^(true|false)$/i.match( value.to_s )
    
      $1.downcase == 'true'
      
    else
    
      #default
      Kernel::raise TypeError.new( "Unable to convert string \"#{ self }\" to boolean (Expected \”true\" or \"false\")" )

    end

  end    

end

module MobyUtil

  class StringHelper    

    # Function determines if string is "true" or "false"
    # == params
    # string:: String
    # == returns
    # TrueClass/FalseClass 
    def self.boolean?( string )

      # raise exception if argument type other than String
      #Kernel::raise ArgumentError.new("Invalid argument format %s (Expected: %s)" % [ string.class, "String" ]) unless string.kind_of?( String )
      string.check_type( String, "Wrong argument type $1 (Expected $2)" )

      /^(true|false)$/i.match( string ).kind_of?( MatchData )

    end    

    # Function determines if string is numeric
    # == params
    # string:: Numeric string
    # == returns
    # TrueClass/FalseClass 
    def self.numeric?( string )

      # raise exception if argument type other than String

      Kernel::raise ArgumentError.new("Invalid argument format %s (Expected: %s)" % [ string.class, "String" ]) unless string.kind_of?( String )

      /[0-9]+/.match( string ).kind_of?( MatchData )

    end  

    # Function converts "true" or "false" to boolean 
    # == params
    # string:: String
    # == returns
    # TrueClass/FalseClass 
    def self.to_boolean( string )          

      if MobyUtil::StringHelper::boolean?( string )

        /true/i.match( string ).kind_of?( MatchData )

      else

        Kernel::raise ArgumentError.new("Invalid value '%s' for boolean (Expected: %s)" % [ string, "'true', 'false'" ] )

      end      

    end    

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # StringHelper

end # MobyUtil
