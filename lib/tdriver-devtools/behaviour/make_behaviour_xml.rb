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
#!/usr/bin/env ruby
require 'rdoc/rdoc'

# delete doc
#`rm -rf doc`

module RDoc

=begin
	class Stats
		
		alias old_print print

		def print(*args)

			puts "---------------"

			old_print

			puts ""

		end

	end
=end

	class RDoc

		# install custom generator to RDoc
		def install_generator( name, filename )

  			GENERATORS[ name.to_s.downcase ] = Generator.new(
				filename,
				"#{ name.to_s.upcase }Generator".intern,
				name.to_s.downcase
			)

		end

	end

end

if ARGV.count == 0
	
	puts "\nUsage: #{ $0 } filename.rb\n\n"
	exit

else

	ARGV.each{ | filename | 

		abort("\nUnable to create behaviours XML due to implementation file %s not found\n\n" % [ filename ] ) unless File.exist?( File.expand_path( filename ) )

	}

end

begin

	RDoc::RDoc.new.tap{ | rdoc |

		rdoc.install_generator( 'TDriver', File.expand_path( File.join( File.dirname( __FILE__ ), 'lib/tdriver_generator.rb' ) ) )

		#rdoc.document( ['--inline-source', '--quiet', '--fmt', 'tdriver'] + ARGV )
		rdoc.document( ['--inline-source', '--fmt', 'tdriver'] + ARGV )

	}

rescue RDoc::RDocError => e

	$stderr.puts e.message

	exit( 1 )

end

