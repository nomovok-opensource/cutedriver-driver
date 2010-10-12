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

# Utility for handling localisation database

module MobyUtil

	class Localisation

		# Function for fetching a translation from the localisation DB
		# == params
		# logical_name:: Symbol containing the logical name that acts as a key when fetching translation
		# language:: String containing language to be used in fetching the translation
		# table_name:: String containing the name of table to be used when fetching translation
		# == returns
		# String:: Value of the localisation
		# Array<String>:: Array of values when multiple translations found
		# == throws
		# LogicalNameNotFoundError:: in case the localisation for logical name not found
		# LanguageNotFoundError:: in case the language not found
		# TableNotFoundError:: in case the table name not found
		# SqlError:: in case of the other problem with the query
		def self.translation( logical_name, language, table_name, file_name = nil , plurality = nil, lengthvariant = nil )
		
			Kernel::raise LogicalNameNotFoundError.new( "Logical name cannot be nil" ) if logical_name == nil
			Kernel::raise LanguageNotFoundError.new( "Language cannot be nil" ) if language == nil
			Kernel::raise TableNotFoundError.new( "Table name cannot be nil" ) if table_name == nil
			
			db_type =  MobyUtil::Parameter[ :localisation_db_type, nil ].to_s.downcase
			host =  MobyUtil::Parameter[ :localisation_server_ip ]
			username = MobyUtil::Parameter[ :localisation_server_username ]
			password = MobyUtil::Parameter[ :localisation_server_password ]
			database_name = MobyUtil::Parameter[ :localisation_server_database_name ]
			
			query_string = "select `#{ language }` from #{ table_name } where lname = '#{ logical_name }'"
			query_string += " and `FNAME` = '#{ file_name }'" unless file_name.nil?
			query_string += " and `PLURALITY` = '#{ plurality }'" unless plurality.nil?
			query_string += " and `LENGTHVAR` = '#{ lengthvariant }'" unless lengthvariant.nil?
			query_string += " and `#{ language }` <> \'#MISSING\'"
			
			begin
				# Returns a uniform set of results as an array of rows, rows beeing an array of values ( Array<Array<String>> )
				result = MobyUtil::DBAccess.query( db_type, host, username, password, database_name, query_string )
			rescue
				# if column referring to language is not found then Kernel::raise error for language not found
				Kernel::raise LanguageNotFoundError.new( "No language '#{ language }' found" ) unless $!.message.index( "Unknown column" ) == nil
				Kernel::raise SqlError.new( $!.message )
			end

			# Return only the first column of the row or and array of the values of the first column if multiple rows have been found
			Kernel::raise LogicalNameNotFoundError.new( "No translation found for logical name '#{ logical_name }' in language '#{ language }' with given plurality and lengthvariant." ) if ( result.empty?)
			if result.length > 1
				# Result is an Array of rows (Array<String>)! We want the first column of each row.
				result_array = Array.new
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

