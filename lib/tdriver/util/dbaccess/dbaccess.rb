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
	    def self.query( type, host, username, password, database_name, query_string )
			# Create first instance of this class if it doesn't exist
			self.instance
			
			# Check creation parameters
		    Kernel::raise DbTypeNotDefinedError.new( "Database type need to be either 'mysql' or 'sqlite'!" ) if type == nil 
            Kernel::raise DbTypeNotSupportedError.new( "Database type '#{type}' not supported! Type need to be either 'mysql' or 'sqlite'!" ) unless type == DB_TYPE_MYSQL or type == DB_TYPE_SQLITE
			
			### TODO check for type host username password and dbnam,,,,, not beeing emty
			#Kernel::raise ArgumentException.new("")
			
			# Check for exsting connection for that host and create it if needed
			if !@@_connections.has_key?( host ) or @@_connections[ host ].type != type
				connector = connect_db( type, host, username, password, database_name )
				@@_connections[ host ] = DBConnection.new( type, host, connector )
			end
			
			return @@_connections[ host ].query( query_string )
			
		end
	
		
		# private methods from here
		private 
		
		# Function establishes a connection to mysql server if needed     
		# == throws
		# MySqlConnectError:: In case the connection fails
		# == returns
		# MySql:: Class that encapsulated the connection into MySQL database
		def connect_db( type, host, username, password, database_name )

			# if mysql API and connection are not initialized, then initialize the mysql API
			if ( type == DB_TYPE_MYSQL ) && ( @@_mysql.nil? )
				require 'mysql'
				@@_mysql = Mysql::init
            elsif type == DB_TYPE_SQLITE
                require 'sqlite3'
			end

			begin
				connector = @@_mysql.connect( host, username, password, database_name) if @@_connection.nil? && @@_db_type == DB_TYPE_MYSQL
				# set the utf8 encoding
				connector.query 'SET NAMES utf8' if type == DB_TYPE_MYSQL
                connector = SQLite3::Database.new( database_name ) if type == DB_TYPE_SQLITE				
			rescue
				Kernel::raise MySqlConnectError.new( $!.message )
			end
			
			return connector

		end

	end # class

end # module
