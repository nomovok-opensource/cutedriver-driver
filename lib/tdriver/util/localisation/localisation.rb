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

      #translation type
      translation_type="localisation"


      # Get logical name identifiers
      translation_identifier_arr=MobyUtil::Parameter[ :localisation_logical_string_identifier, 'qtn_|txt_' ].split('|')
      user_data_identifier_arr=MobyUtil::Parameter[ :user_data_logical_string_identifier, 'uif_' ].split('|')
      operator_data_identifier_arr=MobyUtil::Parameter[ :operator_data_logical_string_identifier, 'operator_' ].split('|')

      translation_identifier_arr.each do |identifier|
        if logical_name.to_s.index(identifier)==0
          translation_type="localisation"
        end
      end

      user_data_identifier_arr.each do |identifier|
        if logical_name.to_s.index(identifier)==0
          translation_type="user_data"
        end
      end

      operator_data_identifier_arr.each do |identifier|
        if logical_name.to_s.index(identifier)==0
          translation_type="operator_data"
        end
      end

			# Get parameters for DB Connection

      case translation_type
        
      when "localisation"
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

      when "user_data"
        db_type =  MobyUtil::Parameter[ :user_data_db_type, nil ].to_s.downcase
			  host =  MobyUtil::Parameter[ :user_data_server_ip ]
			  username = MobyUtil::Parameter[ :user_data_server_username ]
			  password = MobyUtil::Parameter[ :user_data_server_password ]
			  database_name = MobyUtil::Parameter[ :user_data_server_database_name ]
        language = MobyUtil::Parameter[ :language, language ]
        table_name = MobyUtil::Parameter[ :user_data_server_database_tablename]

        query_string = "select `#{ language }` from #{ table_name } where lname = \'#{ logical_name }' and `#{ language }` <>\'#MISSING\'"

      when "operator_data"
        db_type =  MobyUtil::Parameter[ :operator_data_db_type, nil ].to_s.downcase
        host =  MobyUtil::Parameter[ :operator_data_server_ip ]
        username = MobyUtil::Parameter[ :operator_data_server_username ]
        password = MobyUtil::Parameter[ :operator_data_server_password ]
        database_name = MobyUtil::Parameter[ :operator_data_server_database_name ]
        table_name = MobyUtil::Parameter[ :operator_data_server_database_tablename]
        operator = MobyUtil::Parameter[ :operator_selected ]
			  search_string = "#{ logical_name }' AND `Operator` = '#{ operator }"

        query_string =  "select `Value` from `#{ table_name }` where `LogicalName` = '#{ search_string }' and `LogicalName` <> '#MISSING'"

      end


			begin
				result = MobyUtil::DBAccess.query( db_type, host, username, password, database_name, query_string )
			rescue
				# if column referring to language is not found then Kernel::raise error for language not found
				Kernel::raise LanguageNotFoundError.new( "No language '#{ language }' found" ) unless $!.message.index( "Unknown column" ) == nil
				Kernel::raise SqlError.new( $!.message )
			end

			# Return only the first column of the row or and array of the values of the first column if multiple rows have been found
			Kernel::raise LogicalNameNotFoundError.new( "No translation found for logical name '#{ logical_name }' in language '#{ language }' with given plurality and lengthvariant." ) if ( result.empty?)
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

