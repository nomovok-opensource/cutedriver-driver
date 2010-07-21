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

# Utility for handling user data database

module MobyUtil

	class UserData

		# Function for fetching user data
		# == params
		# language:: String containing language to be used in fetching the translation
		# logical_name:: Symbol containing the logical name that acts as a key when fetching translation
		# table_name:: String containing the name of table to be used when fetching translation
		# == returns
		# String:: value of the localisation
		# == throws
		# UserDataNotFoundError:: in case the localisation for logical name not found
		# MySqlConnectError:: in case of the other problem with the connectivity 
		def self.retrieve( user_data_lname )
			
			Kernel::raise UserDataNotFoundError.new( "User data logical name can't be empty" ) if user_data_lname == nil
			
			# Get Localization parameters for DB Connection 
			db_type =  MobyUtil::Parameter[ :user_data_db_type, nil ].to_s.downcase
			host =  MobyUtil::Parameter[ :user_data_server_ip ]
			username = MobyUtil::Parameter[ :user_data_server_username ]
			password = MobyUtil::Parameter[ :user_data_server_password ]
			database_name = MobyUtil::Parameter[ :user_data_server_database_name ]
			language = MobyUtil::Parameter[ :language ]
			table_name = MobyUtil::Parameter[ :user_data_server_database_tablename ] 

			query_string = "select `#{ language }` from #{ table_name } where lname = \'#{ user_data_lname }' and `#{ language }` <>\'#MISSING\'"
			
			begin
				result = MobyUtil::DBAccess.query( db_type, host, username, password, database_name, query_string )
			rescue        
				# if column referring to language is not found then Kernel::raise error for language not found
				Kernel::raise UserDataNotFoundError.new( "No user data for '#{ user_data_lname }' was found" ) unless $!.message.index( "Unknown column" ) == nil
				Kernel::raise MySqlConnectError.new( $!.message )
			end    
			
			# Return only the first column of the row or and array of the values of the first column if multiple rows have been found
			Kernel::raise UserDataNotFoundError.new( "No user data for '#{ user_data_lname }' found for language '#{ language }'" ) if ( result.empty?)
			if result.length > 1
				result_array = Array.new
				result.each do |row|
					result_array << row[0]
				end
			else
				return result[0][0] # array of rows! We want the first column of the first row
			end
			
		end

	end # class

end # module

