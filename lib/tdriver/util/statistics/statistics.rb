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

# Utility for storing statistics regarding TDriver usage
#
#
# Usage:
# 
# 1. report installation
# MobyUtil::Stats.report('install', 'message')
# will report installation event, message is optional
#
# 2. report activation of TDriver
# MobyUtil::Stats.report('install', 'message')
# will report TDriver activation event, message is optional
#
# 3. report exception raised by TDriver
# MobyUtil::Stats.report('exception', 'message describing the exception')
# will report exception thrown by TDriver, message describes the the exception
#

module MobyUtil  

	class Stats

		def self.report( action, message )

			return nil if defined?( $_TDRIVER_DISABLE_STATS_REPORTING )

      require 'rubygems'
      require 'uri'
      require 'socket'
      require 'net/http'
      require 'date'

			report_thread = Thread.new{

				begin
					# TODO: override possibility for the url using parameters?
					url = URI.parse('http://127.0.0.1/tdriver/stats/create/new_stat')
					
					resp, data = Net::HTTP.new( url.host, url.port ).post( 
						url.path, 
						"stat[action]=#{ action }" <<
						"&stat[host]=#{ Socket.gethostname }" <<
						"&stat[time_stamp]=#{ DateTime.now.strftime( "%Y%m%d%H%M%S" ) }" <<
						"&stat[message]=#{ message }" <<
						"&stat[user]=#{ 'NO' }" << 
						"&stat[ip]=#{ 'NO' }" << 
						"&stat[mac]=#{ 'NO' }" << 
						"&stat[platform]=#{ RUBY_PLATFORM.to_s }" <<
						"&stat[version]=#{ ENV['TDRIVER_VERSION'] }" <<
						"&commit=#{ 'Create' }",
						{ 'Content-Type' => 'application/x-www-form-urlencoded' }
					)

				rescue Exception => e

					#puts "Exception:#{e.message} trace:#{e.backtrace.inspect}"             

				end

			}

			report_thread

		end	    

		TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

	end # Stats

end # MobyUtil
