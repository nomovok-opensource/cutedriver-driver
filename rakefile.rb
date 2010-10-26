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

# rakefile for building and releasing Testability Driver
@__release_mode = ENV['rel_mode']
@__release_mode = 'minor' if @__release_mode == nil
  
# version information
def read_version
	version = "0"
	File.open(Dir.getwd << '/debian/changelog') do |file|
		
		line = file.gets
		arr = line.split(')')
		arr = arr[0].split('(')
		arr = arr[1].split('-')
		version = arr[0]
	end
	
	if(@__release_mode == 'release')
		return version
        elsif( @__release_mode == 'cruise' )
                return version + "." + Time.now.strftime("pre%Y%m%d")
	else
		return version + "." + Time.now.strftime("%Y%m%d%H%M%S")   
	end
end

@__revision = read_version
puts "version " << @__revision

def make_version_file(tdriver_version)

	begin
		File.delete('version.rb')
	rescue
	end	
	File.open('version.rb', 'w') { |f| f.write "ENV['TDRIVER_VERSION'] = '#{tdriver_version}'" }

end

@__gem_version = @__revision

require 'rubygems'
require 'rake/gempackagetask'

def make_spec
	#Specification for creating a Testability Driver gem

	return Gem::Specification.new do |s|
    
    gem_version     =   @__gem_version
    s.platform      =   Gem::Platform::RUBY
    s.name          =   "testability-driver"
    s.version       =   "#{gem_version}"
    s.author        =   "Testability Driver team"
    s.email         =   "testabilitydriver@nokia.com"
    s.homepage      =   "http://code.nokia.com"
    s.summary       =   "Testability Driver"

    s.bindir        =   "bin/"    
    s.executables   =   FileList['tdriver-devtools', 'start_app_perf']

		s.files         =   
		  FileList[ 
			  'README',
			  'lib/*.rb',
			  'lib/tdriver/*.rb',
			  'lib/tdriver/base/**/*',
			  'lib/tdriver/sut/**/*',
			  'lib/tdriver/verify/**/*',
			  'lib/tdriver/report/**/*',
			  'lib/tdriver/util/**/*',
			  'lib/tdriver-devtools/**/*',
			  'xml/**/*',
			  'bin/**/*',
			  'ext/**/*',
        'config/**/*'
  		].to_a

    s.require_path  =   "lib/."
    s.has_rdoc      =   false

    #s.add_dependency("libxml-ruby", "=0.9.4")
    s.add_dependency("log4r", ">=1.1.7")
    s.add_dependency("nokogiri", ">=1.4.1")
    s.add_dependency("builder", ">=2.1.2")

    s.extensions << 'ext/extconf.rb'
  
	end

end

spec = make_spec

task :default do | task |

  puts "supported tasks: gem, doc, behaviours"

end

task :behaviours do | task |

  # reset arguments constant without warnings
  ARGV.clear; ['-g', 'behaviours', 'lib/tdriver', 'behaviours'].each{ | argument | ARGV << argument }

  puts "\nGenerating behaviour XML files from implementation... "   

  require File.expand_path( File.join( File.dirname( __FILE__ ), 'lib/tdriver-devtools/tdriver-devtools.rb' ) )

end

task :doc, :tests do | task, args |
  
  test_results_folder = args[:tests] || "../tests/test/feature_xml"
      
  if args[:tests].nil?
  
    puts "\nWarning: Test results folder not given, using default location (#{ test_results_folder })"
    puts "\nSame as executing:\nrake doc[#{ test_results_folder }]\n\n"
    sleep 1
  
  else
  
    puts "Using given test results from #{ test_results_folder }"
    
  end
   
  test_results_folder = File.expand_path( test_results_folder )
   
  # reset arguments constant without warnings
  ARGV.clear; ['-g', 'both', '-t', test_results_folder, 'lib/tdriver', 'doc/document.xml'].each{ | argument | ARGV << argument }

  puts "\nGenerating documentation XML file... "   

  require File.expand_path( File.join( File.dirname( __FILE__ ), 'lib/tdriver-devtools/tdriver-devtools.rb' ) )

end

Rake::GemPackageTask.new( spec ) do | pkg |
  pkg.gem_spec = spec
  pkg.package_dir = "pkg"
end

