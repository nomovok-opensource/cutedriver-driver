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

# Utility for handling user data inputs database

module MobyUtil

	class OperatorData
		
		# Function for fetching translation  
		# == params
		# language:: String containing language to be used in fetching the translation
		# logical_name:: Symbol containing the logical name that acts as a key when fetching translation
		# table_name:: String containing the name of table to be used when fetching translation
		# == returns
		# String:: value of the localisation
		# == throws
		# OperatorDataNotFoundError:: in case the localisation for logical name not found
		# MySqlConnectError:: in case of the other problem with the connectivity 
		def self.retrieve( operator_data_lname )
			
		    Kernel::raise OperatorDataNotFoundError.new( "Search string parameter cannot be nil" ) if operator_data_lname == nil

			# Get Localization parameters for DB Connection 
			db_type =  MobyUtil::Parameter[ :operator_data_db_type, nil ].to_s.downcase
			host =  MobyUtil::Parameter[ :operator_data_server_ip ]
			username = MobyUtil::Parameter[ :operator_data_server_username ]
			password = MobyUtil::Parameter[ :operator_data_server_password ]
			database_name = MobyUtil::Parameter[ :operator_data_server_database_name ]
			table_name = MobyUtil::Parameter[ :operator_data_server_database_tablename]
			operator = MobyUtil::Parameter[ :operator_selected ]
			search_string = "#{ operator_data_lname }' AND `Operator` = '#{ operator }"			
			
			query_string =  "select `Value` from `#{ table_name }` where `LogicalName` = '#{ search_string }' and `LogicalName` <> '#MISSING'"
			
			begin
				result = MobyUtil::DBAccess.query( db_type, host, username, password, database_name, query_string )
			rescue            
			    # if data column to be searched is not found then Kernel::raise error for search column not found
			    Kernel::raise OperatorDataNotFoundError.new( "Search column 'Value' not found in database" ) unless $!.message.index( "Unknown column" ) == nil
			    Kernel::raise MySqlConnectError.new( $!.message )
		    end

			# Return always the first column of the row
			Kernel::raise OperatorDataNotFoundError.new("No matches found for search string '#{ operator_data_lname }' in search column 'LogicalName' for opreator #{ operator }" ) if ( result.empty?)
			return result[0][0] # array of rows! We want the first column of the first row
			
		end

	end # class

end # module

