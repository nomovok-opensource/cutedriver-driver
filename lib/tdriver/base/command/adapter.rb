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

    class Adapter

      def self.make_command( options )

        # parent sut
        sut = options[ :sut ]

        # name of the requested command
        command_name = options[ :options ][ :name ]

        # command implementation module
        command_implementation = nil

        # predefined controller given by caller
        controllers = options[ :options ][ :controller ]

        # if no predefined controllers available
        if controllers.blank?

          # retrieve sut controllers
          controllers = sut.instance_variable_get( :@controllers )

        else

          # caller defined controllers
          controllers = Array( controllers )

        end

        # iterate through each controller and try if command controller specific command class is available
        controllers.each_with_index do | controller, index |

          begin

            # try to retrieve command implementation module
            command_implementation = eval("TDriver::Commands::#{ controller.to_s }::#{ command_name }")

            # continue if success
            break

          rescue NameError

            # module not found, retry with another controller

          end

        end

        # fail if no command implementation was found
        raise RuntimeError, "no suitable command implementation found for #{ command_name.inspect } command" if command_implementation.nil?

        # create a new command object
        command_object = TDriver::Command::Abstraction.new( options )
        
        # apply command implementation to command object
        command_object.extend( command_implementation )

        # return command object
        command_object

      end # self.make_command

    end # Adapter

  end # Commands

end # TDriver
