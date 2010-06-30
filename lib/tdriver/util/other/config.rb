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


#!/usr/bin/ruby

require 'tdriver'

#require File.expand_path( File.join( File.dirname( __FILE__ ), 'xml/xml' ) )
#require File.expand_path( File.join( File.dirname( __FILE__ ), 'common' ) )

def find_xml_element( document, name )

	document.root.xpath( "/parameters/*[@name='#{ name }']" )

end

def change_attr_value( node, attribute_name, value )
  
	node.xml.attr( attribute_name, value.to_s )

end

def change_value( path, attribute, value )

	filename = MobyUtil::FileHelper.fix_path( "#{ MobyUtil::FileHelper.tdriver_home }/tdriver_parameters.xml" )

	xml_document = MobyUtil::XML::parse_file( filename )

	node = find_xml_element( xml_document, path )
	#p node

	change_attr_value( node, attribute, value)
	#p node

	File.open( filename, "w" ){ | file_object | file_object << xml_document.xml }
  
end

#xml_document = MobyUtil::XML::parse_file( MobyUtil::FileHelper.fix_path( "#{ MobyUtil::FileHelper.tdriver_home }/tdriver_parameters.xml" ) )

#root_element = xml_document.root.xpath("/parameters/*[@id='sut_qt']")

=begin
root_element = xml_document.root.xpath("/parameters/parameter[@name='app_path']") 

p root_element.xml

root_element.xml.attr("value", "10")

p root_element.xml

p xml_document

=end

#p root_element.xml.class

=begin
  
nimi = 'sut_qt'

root_element = xml_document.root.xpath("/parameters/*[@id='#{ nimi }' or @name='#{ nimi }']/fixtures") #*[@id='#{ nimi }' or @name='#{ nimi }']")

p root_element

root_element = xml_document.root.xpath("/parameters/*[@id='#{ nimi }' or @name='#{ nimi }']")


p root_element

=end


#p root_element.xml.keys

#node = Nokogiri::XML::Node.new("<nimi>l</nimi>", xml_document.xml)

#root_element.xml.push( node )

#xml_document.root.xml.add_child( node )


#p root_element.xml.to_xml

#p xml_document.xml.to_xml


#p root_element.class

#p xml_document.xml

#exit

def help

=begin

Usage:    
Products: 
Options:
          -a arch   architecture [all] (arm, x86, all)
          -c path   custom scratchbox path [/scratchbox]
          -d        display debug messages
                    WARNING: may contain sensitive information such as password
          -e        create targets that use files.maemo.org as the repository
          -f        overwrite previously existing target if one exists
          -h        display help
          -p pass   password for the repository/rootstrap download
          -r name   release name [pre-release] (current, pre-release, previous)
                    you can use build number instead of release name
          -s        select the created target
          -t prefix custom prefix for target names [maemoX]
                    target name will be \$prefix-\$arch
          -u user   username for the repository/rootstrap download
          -A        save authentication data into .netrc in your scratchbox home
                    WARNING: your username and password will be written
                             in cleartext into your scratchbox home .netrc
          -C config use custom configuration as rootstrap [minimaldev]
                    configuration used will be \$arch-\$config
          -D        don't install debug links
          -I        don't install files to rootstrap
          -P        don't allow unauthenticated packages
          -R        don't install rootstrap
          -S        keep sources.list provided by rootstrap
          -U        save authentication data in sources.list
                    WARNING: your username and password will be written
                             in cleartext into your target's sources.list


=end

  puts <<HELP

Usage: 
  tdriver-config read [path]
    
Example:
  tdriver-config read                        - List keys from root level 
  tdriver-config read sut_qt                 - List keys from "sut_qt" hash
  tdriver-config read sut_qt/keymap/kApp   - Retrieve value of kApp
  
HELP

  exit
  
end

def print_key( key, value )
  puts "%s %s" % [ "#{key} ".ljust(65, '.'), value.kind_of?( Hash ) ? "<Multiple values>" : "\"#{ value.to_s }\"" ]    
end

def dump_hash_values( hash, path = "" )
  hash.keys.sort{ |a,b| a.to_s <=> b.to_s }.each{ | key | print_key( key, hash[ key ] ) }  
end

def resolve_hash_path( hash, path_string )
  return [ "", hash ] if path_string.nil? or ( path_string.kind_of?( String) and path_string.empty? )
  path = hash; path_array = path_string.split( "/" ); current_path = []  
  [ path_array[ -1 ], ( path_array.collect{ | key |   
    current_path = current_path + [ key ]    
    if !path.has_key?( key.to_sym );  puts "No such key/hash found (%s)\n\n" % [ current_path.join( "::" ) ]; exit; end
    path = path[ key.to_sym ]    
  }.compact)[ -1 ] ]
end

if ARGV.count < 1;

  help; 

else
  
  if ![ 'read', 'write' ].include?( ARGV[ 0 ].downcase ) #!= 'read'
    puts "Currently only read and write is supported"; help; exit
  end
  
  mode = ARGV[ 0 ].downcase == 'read' ? :read : :write 

  puts "\n"   
   
  case mode
    
  when :write
    
      change_value( ARGV[ 1 ], "value", ARGV[ 2 ])
      print_key ARGV[ 1 ], ARGV[ 2 ]
  
      # reload new settings
      #Singleton.__init__( MobyUtil::Parameter )     
      
    when :read

      require 'tdriver'

      result = resolve_hash_path( MobyUtil::Parameter.parameters, ARGV[ 1 ])

      result[ 1 ].kind_of?( Hash ) ? ( dump_hash_values result[ 1 ] ) : ( print_key result[ 0 ], result[ 1 ] )  
    
  end

  puts "\n"
    
    
end

