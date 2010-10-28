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

def safe_require( *paths )

  found = false

  paths.each{ | path |

    begin

      require path

      found = true

      break

    rescue LoadError

      #puts "path #{ path } not found"

    end

  }

  abort("Unable to load one of files: %s" % paths.inspect ) unless found

end

require 'rubygems'
require 'rdoc/rdoc'
require 'optparse'

safe_require('tdriver/version.rb',  File.expand_path( File.join( File.dirname( __FILE__ ), '../tdriver/version.rb' ) ) )
safe_require('tdriver/util/common/loader.rb',  File.expand_path( File.join( File.dirname( __FILE__ ), '../tdriver/util/common/loader.rb' ) ) )

require 'tmpdir'
require 'fileutils'

# default options
options = { 
 
  :verbose => false,
  :tests => '.',
  :delete => false

}

optparse = OptionParser.new do | opts |

  # Set a banner, displayed at the top of the help screen.
  opts.banner = "Usage: #{ $0 } [options] [source] [destination]"

  opts.separator( "" )

  opts.separator "Specific options:"

  opts.on(
  
    '-g', 
    '--generate TYPE',
      'Available types:',
      '  doc        : Generate documentation from source files.', 
      '               Feature test result files and images are optional',
      ' ',
      '               Default source folder is "behaviours/"',
      '               Default destination file is "doc/document.xml"',
      ' ',
      '  behaviours : Generate behaviour XML files from implementation.',
      '               All behaviour implementation files with .rb extension in',
      '               source folder and its subfolders will be processed.', 
      ' ',
      '               Default source folder is current folder.',
      '               Default destination folder is "behaviours/"',
      ' ',
      '  both       : Generate behaviour XML files and documentation',
      '               Behaviour XML files are saved to temp. folder and deleted',
      '               after documentation XML is saved. Copies also all XSLT ',
      '               templates to destination folder.', 
      ' ',
      '               Default source folder (implementation) is current folder.',
      '               Default destination folder is "doc/document.xml"',
      ' '
      
  ) do | mode |

    case mode.downcase.to_s
    
      when 'doc'
        options[ :generate ] = mode.to_sym
        options[ :source ] ||= 'behaviours/'
        options[ :destination ] ||= 'doc/document.xml'

      when 'behaviours'
        options[ :generate ] = mode.to_sym
        options[ :source ] ||= '.'
        options[ :destination ] ||= 'behaviours/'
            
      when 'both'
        options[ :generate ] = mode.to_sym
        options[ :source ] ||= '.'
        options[ :destination_behaviours ] = File.expand_path( File.join( Dir.tmpdir, "tdriver-devtools-behaviours" ) ) 
        options[ :destination ] ||= 'doc/document.xml'
            
    else

      puts "Invalid value for generate option: #{ mode }", ""
      puts opts, ""
      exit
      
    end
      
  end

=begin
  opts.on( 
    '-b', 
    '--behaviours [FOLDER]', 
    'Source folder for behaviour XML files (DOC)' 
  ) do | folder |
  
  end
=end

  opts.on( 
    '-i', 
    '--images [FOLDER]', 
    'Source folder for all images used in documentation' 
  ) do | folder |
  
  end

  opts.on( 
    '-t', 
    '--tests [FOLDER]', 
    'Source folder for feature test result files', ' ' 
  ) do | folder |

    options[ :tests ] = folder
  
  end

=begin
  opts.on( 
    '-o', 
    '--output FOLDER', 
      'User defined destionation folder for documentation and',
      'behaviours XML files. Default output folder is either',
      '"doc" or "behaviours"', ' '
       
  ) do | folder |
  
  end
=end

  opts.on( 
    '-d', 
    '--delete', 
    'Delete all existing behaviour XML files from output folder before generating new.', 
    'Warning! Please option use this option with caution' ) do 
    
    options[:delete] = true
    
  end

  opts.separator ""
  opts.separator "Common options:"

  opts.on( '-v', '--version', 'Testability Driver version information' ) do

    puts ENV['TDRIVER_VERSION']
    exit

  end

  opts.on( '-V', '--verbose', 'Output more information' ) do

    options[ :verbose ] = true

  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on_tail("-h", "--help", "Display this message") do

    puts '', opts, ''
    exit

  end

  # show help if no command line arguments given
  if ARGV.empty? 
  
    puts '', opts, ''
    exit
    
  end

end

# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

case options[ :generate ]

  when :behaviours

    $source = File.expand_path( ARGV[ 0 ] || options[ :source ] )
    $destination = File.expand_path( ARGV[ 1 ] || options[ :destination ] )

    destination_folder = File.expand_path( $destination )

    if MobyUtil::FileHelper.folder_exist?( destination_folder )

        if options[ :delete ] == true

          Dir.glob( File.join( destination_folder, '**', '**', '*.xml' ) ) do |entry|

            begin
            
              File.delete( entry )

            rescue Exception => exception
            
              warn("Unable to delete file %s (%s: %s)" % [ entry, exception.class, exception.message ] )
            
            end
  
          end
        
        end
    
    else
        
      begin

        MobyUtil::FileHelper.mkdir_path( destination_folder )        

      rescue Exception => exception
      
        raise RuntimeError.new("Unable to create destination folder %s (%s: %s)" % [ destination_folder, exception.class, exception.message ])
      
      end
    
    end

    # run behaviour xml generator
    require File.expand_path( File.join( File.dirname( __FILE__ ), 'behaviour/xml/generate.rb' ) )

    puts ''

  when :doc

    $source = File.expand_path( ARGV[0] || options[ :source ] )
    $tests = File.expand_path( options[ :tests ] )
    $destination = File.expand_path( ARGV[1] || options[ :destination ] )

    destination_folder = File.dirname( $destination )

    begin

      unless MobyUtil::FileHelper.folder_exist?( destination_folder )

        MobyUtil::FileHelper.mkdir_path( destination_folder )        
      
      end

    rescue Exception => exception
    
      raise RuntimeError.new("Unable to create destination folder %s (%s: %s)" % [ destination_folder, exception.class, exception.message ])
    
    end

    require File.expand_path( File.join( File.dirname( __FILE__ ), 'doc/generate.rb' ) ) #'lib/tdriver-devtools/behaviour/xml/generate.rb'


  when :both
  
    destination_folder = options[ :destination_behaviours ]

    begin
      unless MobyUtil::FileHelper.folder_exist?( destination_folder )
        MobyUtil::FileHelper.mkdir_path( destination_folder )        
      else
        Dir.glob( File.join( destination_folder, '*.xml' ) ) do |entry|
          begin
            File.delete( entry )
          rescue Exception => exception
            warn("Unable to delete file %s (%s: %s)" % [ entry, exception.class, exception.message ] )
          end
        end
      end
    rescue Exception => exception
      raise RuntimeError.new("Unable to create destination folder %s (%s: %s)" % [ destination_folder, exception.class, exception.message ])
    end

    $source = File.expand_path( ARGV[ 0 ] || options[ :source ] )
    $destination = destination_folder

    # run 'implementation to behaviour xml' generator
    require File.expand_path( File.join( File.dirname( __FILE__ ), 'behaviour/xml/generate.rb' ) )

    # documentation
    $source = destination_folder
    $tests = File.expand_path( options[ :tests ] )
    $destination = File.expand_path( ARGV[1] || options[ :destination ] )
    destination_folder = File.dirname( $destination )

    begin
      unless MobyUtil::FileHelper.folder_exist?( destination_folder )
        MobyUtil::FileHelper.mkdir_path( destination_folder )        
      end
    rescue Exception => exception
      raise RuntimeError.new("Unable to create destination folder %s (%s: %s)" % [ destination_folder, exception.class, exception.message ])
    end

    require File.expand_path( File.join( File.dirname( __FILE__ ), 'doc/generate.rb' ) )

    begin
        
      FileUtils.cp( Dir.glob( File.expand_path( File.join( File.dirname( __FILE__ ), 'doc/xslt/*.xsl' ) ) ), destination_folder )

      puts "Template XSLT file(s) copied to destination folder succesfully\n\n"

    rescue Exception => exception
    
      warn("Error while copying template xslt files to destination due to %s (%s)" % [ exception.message, exception.class ] )
    
    end

else

  puts '', optparse, ''

end

=begin

  puts "Being verbose" if options[:verbose]
  puts "Being quick" if options[:quick]
  puts "Logging to file #{options[:logfile]}" if options[:logfile]

  ARGV.each do|f|
   puts "Resizing image #{f}..."
   sleep 0.5
  end

=end
