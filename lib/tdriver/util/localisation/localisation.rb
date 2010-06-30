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
#

module MobyUtil

	class Localisation

    DB_TYPE_MYSQL = 'mysql'
    DB_TYPE_SQLITE = 'sqlite'

	include Singleton

		# Initialize the singleton
		# connection is maintained as long as the connectivity parameters remain the same
		# this is to avoid constant connect as this takes time
		def initialize
			# default values
			@@_db_type = nil
			@@_mysql = nil
            @@_sqlite = nil
            @@_connection = nil
		end

		def create_sql_query_string( query_hash ) 

			"select `#{ query_hash[ :language ] }` from #{ query_hash[ :table_name ] } where lname = \'#{ query_hash[ :logical_name ] }' and `#{ query_hash[ :language ] }` <>\'#MISSING\'"
		end

		# Function for fetching translation  
		# == params
		# language:: String containing language to be used in fetching the translation
		# logical_name:: Symbol containing the logical name that acts as a key when fetching translation
		# table_name:: String containing the name of table to be used when fetching translation
		# == returns
		# String:: value of the localisation
		# == throws
		# LogicalNameNotFoundError:: in case the localisation for logical name not found
		# LanguageNotFoundError:: in case the language not found
		# TableNotFoundError:: in case the table name not found
		# MySqlConnectError:: in case of the other problem with the connectivity 
		def self.translation( logical_name, language, table_name )

			self.instance

			Kernel::raise LogicalNameNotFoundError.new( "Logical name cannot be nil" ) if logical_name == nil
			Kernel::raise LanguageNotFoundError.new( "Language cannot be nil" ) if language == nil
			Kernel::raise TableNotFoundError.new( "Table name cannot be nil" ) if table_name == nil

			# connect to database if not connected already
			self.instance.connect_db

			query_string = self.instance.create_sql_query_string( :language => language, :table_name => table_name, :logical_name => logical_name )


			begin        
				# execute the SQL query
				result = @@_connection.query( query_string ) if @@_db_type == DB_TYPE_MYSQL
                result = @@_connection.execute( query_string ) if @@_db_type == DB_TYPE_SQLITE

			rescue        
				# if column referring to language is not found then Kernel::raise error for language not found
				Kernel::raise LanguageNotFoundError.new( "No language '#{ language }' found" ) unless $!.message.index( "Unknown column" ) == nil
				Kernel::raise MySqlConnectError.new( $!.message )
			end      

            if @@_db_type == DB_TYPE_MYSQL
			    Kernel::raise LogicalNameNotFoundError.new( "No logical name '#{ logical_name }' found for language '#{ language }'" ) if ( result.nil? || result.num_rows <= 0 )
				if ( result.num_rows() == 1 ) 
					return result.fetch_row[0]
				else
					result_array = []
					while( row = result.fetch_row )
						result_array << row[0]
					end			
					return result_array
				end
			elsif @@_db_type == DB_TYPE_SQLITE
			    Kernel::raise LogicalNameNotFoundError.new( "No logical name '#{ logical_name }' found for language '#{ language }'" ) if ( result.nil? || result.size <= 0 )
				return result[0]
			end
			
		end

		# Function establishes a connection to mysql server if needed     
		# == throws
		# MySqlConnectError:: In case the connection fails
		# == returns
		# MySql:: Class that encapsulated the connection into MySQL database
		def connect_db()

            @@_db_type = MobyUtil::Parameter[ :localisation_db_type, nil ]
            Kernel::raise DbTypeNotDefinedError.new( "Database type need to be either 'mysql' or 'sqlite'!" ) if @@_db_type == nil 
            @@_db_type = @@_db_type.to_s.downcase

            Kernel::raise DbTypeNotSupportedError.new( "Database type '#{@@_db_type}' not supported! Type need to be either 'mysql' or 'sqlite'!" ) unless @@_db_type == DB_TYPE_MYSQL or @@_db_type == DB_TYPE_SQLITE
            
			# if mysql API and connection are not initialized, then initialize the mysql API
			if ( @@_db_type == DB_TYPE_MYSQL ) && ( @@_mysql.nil? ) && ( @@_connection.nil? )
				require 'mysql'
				@@_mysql = Mysql::init
            elsif @@_db_type == DB_TYPE_SQLITE
                require 'sqlite3'
			end

			# default table name
			#@@_default_table_name = MobyUtil::Parameter[ :localisation_server_database_tablename ]

			begin

				@@_connection = @@_mysql.connect( 
					MobyUtil::Parameter[ :localisation_server_ip ], 
					MobyUtil::Parameter[ :localisation_server_username ], 
					MobyUtil::Parameter[ :localisation_server_password ], 
					MobyUtil::Parameter[ :localisation_server_database_name ]
				) if @@_connection.nil? && @@_db_type == DB_TYPE_MYSQL

				# set the utf8 encoding
				@@_connection.query 'SET NAMES utf8' if @@_db_type == DB_TYPE_MYSQL

                @@_connection = SQLite3::Database.new( MobyUtil::Parameter[ :localisation_server_database_name ] ) if @@_db_type == DB_TYPE_SQLITE

			rescue

				Kernel::raise MySqlConnectError.new( $!.message )

			end

		end

	end # class

end # module

