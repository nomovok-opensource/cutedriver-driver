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
    def self.connections()
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
      
      dbc.check_type( MobyUtil::DBConnection, "Wrong argument type $1 for database connection object (expected $2)" )      
      
      query_string.check_type( String, "Wrong variable type $1 for database query string (expected $2)")
      query_string.not_empty( "Database query string must not be empty string" )

      db_type = dbc.db_type
      host = dbc.host
      username = dbc.username
      password = dbc.password
      database_name = dbc.database_name
      
      # Check creation parameters

      db_type.check_type( String, "Wrong argument type $1 for database type (expected $2)" )

      db_type.validate( [ DB_TYPE_MYSQL, DB_TYPE_SQLITE ], "Unsupported database type $1 (expected $2)" )

      if ( db_type == DB_TYPE_MYSQL )

        host.check_type( String, "Wrong variable type $1 for host (expected $2)" )
        host.not_empty( "Host must not be empty string" )

        username.check_type( String, "Wrong variable type $1 for username (expected $2)" )
        username.not_empty( "Username must not be empty string" )

        password.check_type( String, "Wrong variable type $1 for password (expected $2)")

      end

      database_name.check_type( String, "Wrong variable type $1 for database name (expected $2)" )
      database_name.not_empty( "Database name must not be empty string" )
            
      # Check for exsting connection for that host and create it if needed
      if !@@_connections.has_key?( host + db_type + database_name ) # make connection ID unique by using host, type and db on the key
        dbc.dbh = connect_db( db_type, host, username, password, database_name )
        @@_connections[ host + db_type + database_name ] = dbc
      end
      
      if db_type == DB_TYPE_MYSQL

        begin
          query_result = @@_connections[ host + db_type + database_name ].dbh.query( query_string ) # identical?
        rescue 
          if @@_mysql        
              @@_mysql.close
              @@_mysql=nil      
          end
          #Possible timeout in query attempt to recreate the connection and redo the query
          dbc.dbh = connect_db( db_type, host, username, password, database_name )
          @@_connections[ host + db_type + database_name ] = dbc
          query_result = @@_connections[ host + db_type + database_name ].dbh.query( query_string ) # identical?
        end

      elsif dbc.db_type == DB_TYPE_SQLITE

        query_result = @@_connections[ host + db_type + database_name ].dbh.query( query_string ) # identical?

      end
      
      # Return a uniform set of results as an array of rows, rows beeing an array of values ( Array<Array<String>> )
      result = []

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

      result

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

      dbc.check_type( MobyUtil::DBConnection, "Wrong argument type $1 for database connection object (expected $2)" )
      
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
    
    # == description
    # Function closes MySQL connection
    #
    def close_db()
            
      if @@_mysql        
        @@_mysql.close
        @@_mysql=nil      
      end      
      
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
        raise SqlConnectError, $!.message
      end
      
      return dbh
      
    end    

    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # DBAccess

end # MobyUtil

at_exit{MobyUtil::DBAccess.instance.close_db}
