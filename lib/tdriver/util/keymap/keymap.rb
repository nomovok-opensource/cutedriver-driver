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

  class KeymapUtilities

    def self.fetch_keycode( keycode, keymap_hash )

      # retrieve default keymap name from hash
      keymap = keymap_hash[ :default_keymap ]

      # convert symbol to string representation for further processing
      keycode_string = keycode.to_s

      # collect all loaded keymaps, exclude :default_keymap key from hash
      keymaps = keymap_hash.keys.select{ | item | ![ :default_keymap, :all ].include?( item ) } 

      begin

        # check if environment defined in keycode, e.g. :qt_kDown
        if keycode_string.include?( '_' )

          if /(#{ keymaps.collect{ | env | "#{ env.to_s }_" }.join('|') })(.+)/i.match( keycode_string )

            # set new keymap value and convert to symbol, e.g. :qt from :qt_kDown
            keymap = $1.chop.to_sym

            # set correct keycode value and convert to symbol, e.g. :kDown from :qt_kDown 
            keycode = $2.to_sym

          end

          # retrieve symbol from keymap
          keymap_hash[ keymap ][ keycode ]

        else

          begin

            # try to retrieve from default keymap; raises exception if key not found
            keymap_hash[ keymap ][ keycode ]

          rescue 

            # if we didn't find the key, let's try finding from mixed keymap; mixed keymap has all loaded keycodes
            # keycodes are merged to existing hash when loading new keymap on top
            # raises exception if key not found
            keymap_hash[ :all ][ keycode ]

          end

        end

      rescue

			  raise ArgumentError, "Scan code for #{ keycode.inspect } not defined in #{ keymap } keymap"

      end

    end

  end # KeymapUtilities

end # TDriver
