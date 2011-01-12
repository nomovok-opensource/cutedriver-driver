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

# Utility for handling operator data inputs database

module MobyUtil

	class OperatorData

		# == description
		# Function to fetch a translation for a given logical name from the localisation DB
		#
		# == arguments
		# operator_data_lname
		#  String
		#   description: operator data identifier
		#   example: "op_welcome_message""
		#
		# operator
		#  String
		#   description: Operator column name to be used when fetching operator data
		#	example: "Orange"
		#
		# table_name
		#  String
		#   description: Name of the operator data table to use from the operator table DB
		#   example: "operator_data_week201042"
		#
		# == returns
		# String
		#  description: Operator data string
		#
		# == throws
		# OperatorDataColumnNotFoundError
		#  description: If the desired operator data is not found
		#
		# OperatorDataColumnNotFoundError
		#  description: If the desired data column name to be used for the output is not found
		#
		# SqlError
		#  description: if there is and sql error while executing the query
		#
		def self.retrieve( operator_data_lname, operator, table_name )
			
		    Kernel::raise OperatorDataNotFoundError.new( "Search string parameter cannot be nil" ) if operator_data_lname == nil

			# Get Localization parameters for DB Connection
			db_type =  $parameters[ :operator_data_db_type, nil ].to_s.downcase
			host =  $parameters[ :operator_data_server_ip ]
			username = $parameters[ :operator_data_server_username ]
			password = $parameters[ :operator_data_server_password ]
			database_name = $parameters[ :operator_data_server_database_name ]
			
			db_connection = DBConnection.new(  db_type, host, database_name, username, password )
			
			search_string = "#{ operator_data_lname }' AND `Operator` = '#{ operator }"			
			query_string =  "select `Value` from `#{ table_name }` where `LogicalName` = '#{ search_string }' and `LogicalName` <> '#MISSING'"

			begin
				result = MobyUtil::DBAccess.query( db_connection, query_string )
			rescue
			    # if data column to be searched is not found then Kernel::raise error for search column not found
			    Kernel::raise OperatorDataColumnNotFoundError.new( "Search column 'Value' not found in database" ) unless $!.message.index( "Unknown column" ) == nil
			    Kernel::raise SqlError.new( $!.message )
		    end

			# Return always the first column of the row
			Kernel::raise OperatorDataNotFoundError.new("No matches found for search string '#{ operator_data_lname }' in search column 'LogicalName' for opreator #{ operator }" ) if ( result.empty?)
			# Result is an Array of rows (Array<String>)! We want the first column of the first row.
			return result[0][0]
			
		end

	end # class

end # module

