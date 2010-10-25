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

		# == description
		# Function for fetching user data from the user data DB
		#
		# == arguments
		# user_data_lname
		#  String
		#   description: String containing user_data_lname to be used in fetching the translation
		#   example: "uif_first_name"
		#
		# language
		#  String
		#   description: Scring containing language to be used in fetching user information
		#   example: "en"
		#
		# table_name
		#  String
		#   description: String containing the name of table to be used when user information
		#   example: "user_data_week201042"
		#
		# == returns
		# String
		#  description: User data string
		#
		# Array
		#  description: Array of values when multiple user data strings found
		#
		# == throws
		# UserDataNotFoundError
		#  description: If the desired user data is not found
		#
		# UserDataColumnNotFoundError
		#  description: If the desired data column name to be used for the output is not found
		#
		# SqlError
		#  description: If there is and sql error while executing the query
		#
		def self.retrieve( user_data_lname, language, table_name )
			
			Kernel::raise UserDataNotFoundError.new( "User data logical name can't be empty" ) if user_data_lname == nil

			# Get Localization parameters for DB Connection
			db_type =  MobyUtil::Parameter[ :user_data_db_type, nil ].to_s.downcase
			host =  MobyUtil::Parameter[ :user_data_server_ip ]
			username = MobyUtil::Parameter[ :user_data_server_username ]
			password = MobyUtil::Parameter[ :user_data_server_password ]
			database_name = MobyUtil::Parameter[ :user_data_server_database_name ]
			
			db_connection = DBConnection.new(  db_type, host, database_name, username, password )

			query_string = "select `#{ language }` from #{ table_name } where lname = \'#{ user_data_lname }' and `#{ language }` <>\'#MISSING\'"

			begin
				result = MobyUtil::DBAccess.query( db_connection, query_string )
			rescue
				# if column referring to language is not found then Kernel::raise error for language not found
				Kernel::raise UserDataColumnNotFoundError.new( "User data language column '#{ language }' was not found" ) unless $!.message.index( "Unknown column" ) == nil
				Kernel::raise SqlError.new( $!.message )
			end

			# Return only the first column of the row or and array of the values of the first column if multiple rows have been found
			Kernel::raise UserDataNotFoundError.new( "No user data for '#{ user_data_lname }' found for language '#{ language }'" ) if ( result.empty?)
			if result.length > 1
				result_array = Array.new # array of rows! We want the first column of the first row
				result.each do |row|
					result_array << row[0]
				end
				return result_array
			else
				# Result is an Array of rows (Array<String>)! We want the first column of the first row.
				return result[0][0]
			end

		end

	end # class

end # module

