#!/usr/bin/env ruby
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
require 'rdoc/rdoc'

module RDoc

  class RDoc

    # install custom generator to RDoc
    def install_generator( name, module_name, filename )

        GENERATORS[ name.to_s.downcase ] = Generator.new( filename, module_name.intern , name.to_s.downcase )

    end

  end

end


if $source.nil?

  abort "Usage: #{ $0 } SOURCE_FILES [DESTINATION_FOLDER]"
  
else

  $source = File.expand_path( ARGV[ 0 ] || $source )

  $destination = File.expand_path( ARGV[ 1 ] || $destination )

  abort("File or folder %s not found" % $source ) unless File.exist?( $source )

end

begin

  RDoc::RDoc.new.tap{ | rdoc |

    rdoc.install_generator( 
      'tdriver_behaviour_xml', 
      'TDriverBehaviourGenerator', 
      File.expand_path( File.join( File.dirname( __FILE__ ), 'rdoc_behaviour_xml_generator.rb' ) ) 
    )

    rdoc.document( 
      [
        '--inline-source', 
        '--op', $destination, 
        '--fmt', 'tdriver_behaviour_xml'
      ] << $source
    )

  }

rescue RDoc::RDocError => exception

  abort exception.message

end

