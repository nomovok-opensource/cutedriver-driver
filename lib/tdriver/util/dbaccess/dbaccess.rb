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

# Utility for handling database connections

module MobyUtil

	class DBAccess

    DB_TYPE_MYSQL = 'mysql'
    DB_TYPE_SQLITE = 'sqlite'

	include Singleton

		# Initialize the singleton
		# connection is maintained as long as the connectivity parameters remain the same
		# this is to avoid constant connect as this takes time
		def initialize
			@@_connections = {}
			@@_mysql = nil
		end

		
		# Function for fetching SQL data  
	    # == params
	    # result_column:: string containing the desired data column name to be used for the output
	    # table_name:: string containing the name of table to be used
	    # search_column:: string containing the name of the data column to be searched
	    # search_string:: string containing information about the criteria the search column must match
	    # == returns
	    # String:: value of the localisation
	    # == throws
	    # ResultColumnNotFoundError:: in case the desired data column name to be used for the output is not found
	    # TableNotFoundError:: in case the table name is not found
	    # SearchColumnNotFoundError:: in case the name of the data column to be searched is not found
	    # SearchStringNotFoundError:: when information about the criteria the search column must match is not found
	    # MySqlConnectError:: in case there is a problem with the connectivity
	    def self.query( db_type, host, username, password, database_name, query_string )
			# Create first instance of this class if it doesn't exist
			self.instance
			
			# Check creation parameters
		    Kernel::raise DbTypeNotDefinedError.new( "Database type need to be either 'mysql' or 'sqlite'!" ) if  db_type == nil 
            Kernel::raise DbTypeNotSupportedError.new( "Database type '#{db_type}' not supported! Type need to be either 'mysql' or 'sqlite'!" ) unless  db_type == DB_TYPE_MYSQL or  db_type == DB_TYPE_SQLITE
			if db_type == DB_TYPE_MYSQL
				Kernel::raise ArgumentError.new("Host must be provided as a non empty string.") if host.nil? or host.class != String or host.empty?
				Kernel::raise ArgumentError.new("Username must be provided as a non empty string.") if username.nil? or username.class != String or username.empty?
				Kernel::raise ArgumentError.new("Password must be provided as a non empty string.") if password.nil? or password.class != String or password.empty?
			end
			Kernel::raise ArgumentError.new("The database name must be provided as a non empty string.") if database_name.nil? or database_name.class != String or database_name.empty?
			Kernel::raise ArgumentError.new("The query qtring must be provided as a non empty string.") if query_string.nil? or query_string.class != String or query_string.empty?
			
			# Check for exsting connection for that host and create it if needed
			if !@@_connections.has_key?( host + db_type + database_name ) # make connection ID unique by using host, type and db on the key
				connector = self.instance.connect_db(  db_type, host, username, password, database_name )
				@@_connections[ host + db_type + database_name ] = DBConnection.new(  db_type, host, database_name, connector )
			end
			
			return @@_connections[ host + db_type + database_name ].connector.query( query_string )
			
			#### TODO return same format of row/array of rows regardless of DB type
			# if db_type == DB_TYPE_MYSQL
				# Kernel::raise OperatorDataNotFoundError.new( "No matches found for search string '#{ operator_data_lname }' in search column 'LogicalName'" ) if ( result.nil? || result.num_rows <= 0 )
				# return result.fetch_row[ 0 ]
		    # elsif db_type == DB_TYPE_SQLITE
				# first_row = result.next()
				# Kernel::raise OperatorDataNotFoundError.new( "No user data for '#{ user_data_lname }' was found for language '#{ language }'" ) if ( first_row.nil? )
				# return first_row[0]
		    # end
			
		end
	
		
		# Function establishes a connection to mysql server if needed     
		# == throws
		# MySqlConnectError:: In case the connection fails
		# == returns
		# MySql:: Class that encapsulated the connection into MySQL database
		def connect_db(  db_type, host, username, password, database_name )

			# if mysql API and connection are not initialized, then initialize the mysql API
			if (  db_type == DB_TYPE_MYSQL ) && ( @@_mysql.nil? )
				require 'mysql'
				@@_mysql = Mysql::init
            elsif  db_type == DB_TYPE_SQLITE
                require 'sqlite3'
			end

			begin
				connector = @@_mysql.connect( host, username, password, database_name) if  db_type == DB_TYPE_MYSQL
				# set the utf8 encoding
				connector.query 'SET NAMES utf8' if db_type == DB_TYPE_MYSQL
                connector = SQLite3::Database.new( database_name ) if db_type == DB_TYPE_SQLITE				
			rescue
				Kernel::raise MySqlConnectError.new( $!.message )
			end
			
			return connector

		end

	end # class

end # module

