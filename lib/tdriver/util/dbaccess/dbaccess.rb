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
		
		# == description
		# Initialize the singleton
		# connection is maintained as long as the connectivity parameters remain the same
		# this is to avoid constant connect as this takes time
		#
		def initialize
			@@_connections = {}
			@@_mysql = nil
		end

		# == description
		# Class Method that returns existing connections
		#
		def DBAccess.connections()
			return @@_connections
		end
		
		# == description
		# Runs an SQL query on the on the given MobyUtil::DBConnection 
		#
		# == arguments
		# dbc
		#  MobyUtil::DBConnection
		#   description: object with the connection details of an open sql connection
		#
		# query_string
		#  String
		#   description: database-specific SQL query (note that mysql and sqlite have slightly different syntax)
		#   example: "select * from tdriver_locale;"
		#
		# == returns
		# Array
		#  description: Array of rows returned by the server. Each row is an array of String values.
		#
		# == throws
		# ArgumentError
		#  description: if the argument provided is not the right object type
		#
	    def self.query( dbc, query_string )
			# Create first instance of this class if it doesn't exist
			self.instance
			
			raise ArgumentError.new("Invalid connection object provided.") if dbc.nil? or !dbc.kind_of? MobyUtil::DBConnection
			
			db_type = dbc.db_type
			host = dbc.host
			username = dbc.username
			password = dbc.password
			database_name = dbc.database_name
			
			# Check creation parameters
		    raise DbTypeNotDefinedError.new( "Database type need to be either 'mysql' or 'sqlite'!" ) if  db_type == nil 
            raise DbTypeNotSupportedError.new( "Database type '#{db_type}' not supported! Type need to be either 'mysql' or 'sqlite'!" ) unless  db_type == DB_TYPE_MYSQL or  db_type == DB_TYPE_SQLITE
			if db_type == DB_TYPE_MYSQL
				raise ArgumentError.new("Host must be provided as a non empty string.") if host.nil? or host.class != String or host.empty?
				raise ArgumentError.new("Username must be provided as a non empty string.") if username.nil? or username.class != String or username.empty?
				raise ArgumentError.new("Password must be provided as a string.") if password.nil? or password.class != String
			end
			raise ArgumentError.new("The database name must be provided as a non empty string.") if database_name.nil? or database_name.class != String or database_name.empty?
			raise ArgumentError.new("The query qtring must be provided as a non empty string.") if query_string.nil? or query_string.class != String or query_string.empty?
			
			# Check for exsting connection for that host and create it if needed
			if !@@_connections.has_key?( host + db_type + database_name ) # make connection ID unique by using host, type and db on the key
				dbc.dbh = connect_db( db_type, host, username, password, database_name )
				@@_connections[ host + db_type + database_name ] = dbc
			end
			
			if db_type == DB_TYPE_MYSQL
				query_result = @@_connections[ host + db_type + database_name ].dbh.query( query_string )
			elsif dbc.db_type == DB_TYPE_SQLITE
				query_result = @@_connections[ host + db_type + database_name ].dbh.query( query_string )
			end
			
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
				# it is essentially a prepare method so we need to call close to free the connection
				query_result.close 
		    end
			return result
		end
		
	
		# == description
		# Retunrs the number of affected rows on the latest sql query on the given MobyUtil::DBConnection 
		#
		# == arguments
		# dbc
		#  MobyUtil::DBConnection
		#   description: object with the connection details of an open sql connection
		#
		# == returns
		# Integer
		#  description: number of rows affected
		#
		# == throws
		# ArgumentError
		#  description: if the argument provided is not the right object type
		#
		def self.affected_rows(dbc)
			raise ArgumentError.new("Invalid connection object provided.") if dbc.nil? or !dbc.kind_of? MobyUtil::DBConnection
			
			# Check for exsting connection for that host and create it if needed
			if !@@_connections.has_key?( dbc.host + dbc.db_type + dbc.database_name ) # make connection ID unique by using host, type and db on the key
				dbc.dbh = connect_db(  dbc.db_type, dbc.host, dbc.username, dbc.password, dbc.database_name )
				@@_connections[ dbc.host + dbc.db_type + dbc.database_name ] = dbc
			end
			result = 0
			if dbc.db_type == DB_TYPE_MYSQL
				result = @@_connections[ dbc.host + dbc.db_type + dbc.database_name ].dbh.affected_rows
			elsif dbc.db_type == DB_TYPE_SQLITE
				result = @@_connections[ dbc.host + dbc.db_type + dbc.database_name ].dbh.changes
			end
			return result
		end
		
		
		
		private
		
		# == description
		# Function establishes a new connection to as sql server and returns it's handle
		#
	    def self.connect_db(  db_type, host, username, password, database_name )

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
				raise SqlConnectError.new( $!.message )
			end
			
			return dbh

		end

	end # class

end # module

