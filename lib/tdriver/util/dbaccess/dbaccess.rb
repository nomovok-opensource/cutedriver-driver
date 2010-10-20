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
	    # db_type::
		# host::
		# username::
		# password::
		# database_name::
		# query_string::
	    # == returns
	    # Array<Array<String>>:: Returns an Array of rows, where each row is and Array of Strings
	    # == throws
	    # DbTypeNotDefinedError:: 
	    # ArgumentError:: 
	    def self.query( dbc, query_string )
			# Create first instance of this class if it doesn't exist
			self.instance
			
			db_type = dbc.db_type
			host = dbc.host
			username = dbc.username
			password = dbc.password
			database_name = dbc.database_name
			
			# Check creation parameters
		    Kernel::raise DbTypeNotDefinedError.new( "Database type need to be either 'mysql' or 'sqlite'!" ) if  db_type == nil 
            Kernel::raise DbTypeNotSupportedError.new( "Database type '#{db_type}' not supported! Type need to be either 'mysql' or 'sqlite'!" ) unless  db_type == DB_TYPE_MYSQL or  db_type == DB_TYPE_SQLITE
			if db_type == DB_TYPE_MYSQL
				Kernel::raise ArgumentError.new("Host must be provided as a non empty string.") if host.nil? or host.class != String or host.empty?
				Kernel::raise ArgumentError.new("Username must be provided as a non empty string.") if username.nil? or username.class != String or username.empty?
				Kernel::raise ArgumentError.new("Password must be provided as a string.") if password.nil? or password.class != String
			end
			Kernel::raise ArgumentError.new("The database name must be provided as a non empty string.") if database_name.nil? or database_name.class != String or database_name.empty?
			Kernel::raise ArgumentError.new("The query qtring must be provided as a non empty string.") if query_string.nil? or query_string.class != String or query_string.empty?
			
			# Check for exsting connection for that host and create it if needed
			if !@@_connections.has_key?( host + db_type + database_name ) # make connection ID unique by using host, type and db on the key
				dbc.dbh = self.instance.connect_db( db_type, host, username, password, database_name )
				@@_connections[ host + db_type + database_name ] = dbc
			end
			
				query_result = @@_connections[ host + db_type + database_name ].dbh.query( query_string )
			
			# Return a uniform set of results as an array of rows, rows beeing an array of values ( Array<Array<String>> )
			result = Array.new
			if db_type == DB_TYPE_MYSQL and !query_result.nil?
				query_result.num_rows.times do |i|
					result << query_result.fetch_row
				end				
		    elsif db_type == DB_TYPE_SQLITE and !query_result.nil?
				# Create Array<SQLite3::ResultSet::ArrayWithTypesAndFields<String>> type result
				# it effectively behaves the same as with Array<Array<String>> but the inner Arrays have .fields and .types properties 
				# which return the column name and type for each value on the row (Array) returned.
				while ( row = query_result.next )
					result << row
				end
		    end
			return result
		end
		
		
		# Retunrs the number of affected rows on the latest sql query on the server  
	    # == params
	    # db_type::
		# host::
		# username::
		# password::
		# database_name::
		# query_string::
	    # == returns
	    # Array<Array<String>>:: Returns an Array of rows, where each row is and Array of Strings
	    # == throws
	    # DbTypeNotDefinedError:: 
	    # ArgumentError:: 
		def self.affected_rows(dbc)
			# Check for exsting connection for that host and create it if needed
			if !@@_connections.has_key?( dbc.host + dbc.db_type + dbc.database_name ) # make connection ID unique by using host, type and db on the key
				dbc.dbh = self.instance.connect_db(  dbc.db_type, dbc.host, dbc.username, dbc.password, dbc.database_name )
				@@_connections[ host + db_type + database_name ] = dbc
			end
			result = 0
			if db_type == DB_TYPE_MYSQL
				result = @@_connections[ host + db_type + database_name ].dbh.affected_rows
			elsif db_type == DB_TYPE_SQLITE
				result = @@_connections[ host + db_type + database_name ].dbh.changes
			end
			return result
		end
		
		
		# Function establishes a connection to mysql server if needed
	    # == params
	    # db_type::
		# host::
		# username::
		# password::
		# database_name::
		# == returns
		# MySql:: MySql object that encapsulated the connection into MySQL database
		# SQLite3::Database SQLite Database object that encapsulated the connection into SQLite database
		# == throws
		# SqlConnectError:: in case there is a problem with the connectivity
		def connect_db(  db_type, host, username, password, database_name )

			# if mysql API and connection are not initialized, then initialize the mysql API
			if (  db_type == DB_TYPE_MYSQL ) && ( @@_mysql.nil? )
				require 'mysql'
				@@_mysql = Mysql::init
            elsif  db_type == DB_TYPE_SQLITE
                require 'sqlite3'
			end

			begin
				dbh = @@_mysql.connect( host, username, password, database_name) if  db_type == DB_TYPE_MYSQL
				dbh.query 'SET NAMES utf8' if db_type == DB_TYPE_MYSQL # set the utf8 encoding
                dbh = SQLite3::Database.new( database_name ) if db_type == DB_TYPE_SQLITE				
			rescue
				Kernel::raise SqlConnectError.new( $!.message )
			end
			
			return dbh

		end

	end # class

end # module

