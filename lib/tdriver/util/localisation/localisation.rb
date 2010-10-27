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

require 'nokogiri'

# Utility for handling localisation database

module MobyUtil

	class Localisation

		# == description
		# Function to fetch a translation for a given logical name from the localisation DB
		#
		# == arguments
		# logical_name
		#  String
		#   description: Logical name (LNAME) of the item to be translated. If prefix for User Information or Operator Data are used then the appropiate retrieve methods will be called
		#   example: "txt_button_ok"
		#  Symbol
		#   description: Symbol form of the logical name (LNAME) of the item to be translated.
		#   example: :txt_button_ok
		#
		# language
		#  String
		#   description: Name of the language column to be used. This is normally the language code found on the .ts or .qm translation files
		#   example: "en"
		#
		# table_name
		#  String
		#   description: Name of the translation table to use from the localisation DB
		#   example: "B10_1_week201042_loc"
		# 
		# file_name
		#  String
		#   description: Optional FNAME search argument for the translation. The FNAME column stores the application name that the translation belongs to
		#   example: "calendar"
		#
		# plurality
		#  String
		#   description: Optional PLURALITY search argument for the translation
		#   example: "a" or "singular"
		#
		# lengthvariant
		#  String
		#   description: Optional LENGTHVAR search argument for the translation (1-9)
		#   example: "1"
		#
		# == returns
		# String
		#  description: Translation matching the logical_name
		#  example: "Ok"
		# Array
		#  description: If multiple translations have been found for the search conditions an Array with all Strings be returned
		#  example: ["Ok", "OK"]
		# 
		# == exceptions
		# LanguageNotFoundError
		#  description: In case language is not found
		#
		# LogicalNameNotFoundError
		#  description: In case no logical name is not found for current language
		#
		# TableNotFoundError
		#  description: If the table name argument is not valid
		#
		# SqlError
		#  description: In case there are problems with the database connectivity
		#
		def self.translation( logical_name, language, table_name, file_name = nil , plurality = nil, lengthvariant = nil )
		
			Kernel::raise LogicalNameNotFoundError.new( "Logical name cannot be nil" ) if logical_name == nil
			Kernel::raise LanguageNotFoundError.new( "Language cannot be nil" ) if language == nil
			Kernel::raise TableNotFoundError.new( "Table name cannot be nil" ) if table_name == nil
			
			# Avoid system column names for language columns and user only downcase
			language = language.to_s.downcase
			if language.eql? "id" or language.eql? "fname" or language.eql? "lname" or language.eql? "plurality" or language.eql? "lengthvar" 
				language += "_"
			end
			
			db_type =  MobyUtil::Parameter[ :localisation_db_type, nil ]
			host =  MobyUtil::Parameter[ :localisation_server_ip ]
			username = MobyUtil::Parameter[ :localisation_server_username ]
			password = MobyUtil::Parameter[ :localisation_server_password ]
			database_name = MobyUtil::Parameter[ :localisation_server_database_name ]
			
			db_connection = DBConnection.new(  db_type, host, database_name, username, password )
			
			query_string = "select `#{ language }` from #{ table_name } where lname = '#{ logical_name }'"
			query_string += " and `FNAME` = '#{ file_name }'" unless file_name.nil?
			query_string += " and `PLURALITY` = '#{ plurality }'" unless plurality.nil?
			query_string += " and `LENGTHVAR` = '#{ lengthvariant }'" unless lengthvariant.nil?
			query_string += " and `#{ language }` <> \'#MISSING\'"
			
			begin
				# Returns a uniform set of results as an array of rows, rows beeing an array of values ( Array<Array<String>> )
				result = MobyUtil::DBAccess.query( db_connection, query_string )
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

		# == description
		# Function upload translations in a given Qt Linguist translation file to the localisation DB
		#
		# == arguments
		# file
		#  String
		#   description: Path to Qt Linguist translation file to upload. Both .ts and .qm files are allowed.
		#   example: "accessories_ar.ts"
		#
		# table_name
		#  String
		#   description: Name of the translation table to use form the localisation DB
		#   example: "B10_1_week201042_loc"
		# 
		# db_connection
		#  MobyUtil::DBConnection
		#   description: A DBConnection object contains all the connection details required to connect to a SQL DB (mysql or sqlite)
		#	example: "MobyUtil::DBConnection.new('mysql', '192.168.0.1', 'tdriver_locale', 'username', 'password')"
		#
		# column_names_map
		#  Hash
		#   description: Hash with the language codes from the translation files as keys and the desired column names as values
		#   example: {"en" => "en_GB"}
		#
		# record_sql
		#  Bool
		#   description: When this flag is set to true then 
		#   example: true
		#
		# == returns
		#
		# == throws
		# ArgumentError
		#  description: When arguments provided are not valid
		#
		# Exception
		#  description: When its not possible to parse the file provided
		#
		def self.upload_translation_file( file, table_name, db_connection = nil, column_names_map = {}, record_sql = false)	
			Kernel::raise ArgumentError.new("") if file.nil? or file.empty?
			Kernel::raise ArgumentError.new("") if table_name.nil? or table_name.empty?

			# Get a connection to the DB
			if db_connection.nil? or !db_connection.kind_of? MobyUtil::DBConnection
				db_type =  MobyUtil::Parameter[ :localisation_db_type ]
				host =  MobyUtil::Parameter[ :localisation_server_ip ]
				database_name = MobyUtil::Parameter[ :localisation_server_database_name ]
				username = MobyUtil::Parameter[ :localisation_server_username ]
				password = MobyUtil::Parameter[ :localisation_server_password ]
				
				db_connection = DBConnection.new(  db_type, host, database_name, username, password )
			end
			# Check File and convert to TS File if needed
			tsFile = MobyUtil::Localisation.convert_to_ts( file )
			Kernel::raise Exception.new("Failed to convert #{file} to .ts") if tsFile == nil	
			# Collect data for INSERT query from TS File
			language, data = MobyUtil::Localisation.parse_ts_file( tsFile, column_names_map )
			Kernel::raise Exception.new("Error while parsing #{file}.") if language == nil or data == ""
			# Upload language data to DB for current language file
			MobyUtil::Localisation.upload_ts_data( language, data, table_name, db_connection, record_sql )
		end
		
		
		
		private
		
		
		# == description
		# Checks Qt Linguist translation file for validity and converts to TS if needed
		#
		# == arguments
		# file
		#  String
		#   description: Name (and path) of the Qt Linguist translation file (.ts or .qm)
		#   example: "calendar.qm"
		#
		# == returns
		# String
		#  description: Name (and path) of the checked and maybe converted .ts Qt Linguist translation file
		#
		# == throws
		# 
		def self.convert_to_ts(file)
			if !File.exists?(file)
				puts "[WARNING] File '" + file + "' not found. Skiping."
				file = nil
			elsif  (nil == file.match(/.*\.ts/) and nil == file.match(/.*\.qm/) )
				puts "[WARNING] Unknown file extension. Skiping. \n\n" + file
				file = nil
			elsif ( match = file.match(/(.*)\.qm/) )
				if(! system "lconvert -o " + match[1] + ".ts " + file )
					puts "[ERROR] lconvert can't convert .qm file to .ts. Skiping. \n\n" + match[0]
					return nil
				end
				file = match[1] + ".ts"
			end
			file
		end
		
		
		# == description
		# Extracts translation data from TS file
		#
		# == arguments
		# file
		#  String
		#   description: Name (and path) of the Qt Linguist translation file (.ts or .qm)
		#   example: "calendar.qm"
		#
		# column_names_map
		#  Hash
		#   description: Hash with the language codes from the translation files as keys and the desired column names as values
		#   example: {"en" => "en_GB"}
		#
		# == returns
		# String
		#  description: Name (and path) of the checked and maybe converted .ts Qt Linguist translation file
		#
		# Array
		#  description: Two dimentional Array with columns [ FNAME, Source, Translation, Plurality, Lengthvariant Priority ]
		# 
		# == throws
		# 
		def self.parse_ts_file(file, column_names_map = {} )
			# Read TS file
			open_file = File.new( file )
			doc = Nokogiri.XML( open_file )
			language = doc.xpath('.//TS').attribute("language")
			# IF filename-to-columnname mapping is provided update language
			fname = parseFName(file)
			if (!column_names_map.empty?)
				language_code = file.split('/').last.gsub(fname + "_" ){|s| ""}.gsub(".ts"){|s| ""}
				language = column_names_map[ language_code ] if column_names_map.key?( language_code )
			end
			if (language == nil)
				puts "[WARNING] The input file is missing the language attribute on it's <TS> element. Skiping. \n\n"
				return nil, nil
			end
			# Collect data for INSERT query
			data = []
			doc.xpath('.//message').each do |node|
				begin
					nodeId = ""
					nodeTranslation = ""
					nodePlurality = ""
					nodeLengthVar = ""
					# set nodeId
					#raise Exception if node.xpath('@id').inner_text() == ""
					if node.xpath('@id').inner_text() != ""
						nodeId = node.xpath('@id').inner_text()
					else
						nodeId = node.xpath('.//source').inner_text()
					end
					# Parse Numerus(LengthVar), or Numerus or LengthVar or translation direclty
					if ! node.xpath('.//translation/numerusform').empty?
						# puts ">>> Numerusform"
						node.xpath('.//translation/numerusform').each do |numerus|
							nodePlurality = numerus.xpath('@plurality').inner_text()
							if ! numerus.xpath('.//lengthvariant').empty?
								# puts "  >>> Lengthvar"
								numerus.xpath('.//lengthvariant').each do |lenghtvar|
									nodeLengthVar = lenghtvar.xpath('@priority').inner_text()
									nodeTranslation = lenghtvar.inner_text()
									data << [ fname, nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
								end
							else
								nodeTranslation = numerus.inner_text()
								data << [ fname, nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
							end
						end			
					elsif ! node.xpath('.//translation/lengthvariant').empty?
						# puts ">>> Lengthvar"
						priority = 1
						node.xpath('.//translation/lengthvariant').each do |lenghtvar|
							nodeLengthVar = lenghtvar.xpath('@priority').inner_text()
							nodeLengthVar = priority.to_s if nodeLengthVar.empty?
							nodeTranslation = lenghtvar.inner_text()
							data << [ fname, nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
							priority += 1					
						end
					else
						# puts ">>> Translation"
						nodeTranslation = node.xpath('.//translation').inner_text()
						data << [ fname, nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
					end
				rescue Exception # ignores bad elements or elements with empty translations for now
				end
			end
			open_file.close
			return language, data
		end
		
		
		# == description
		# Uploads language data to Localisation DB and optionally records the sql queries on a file
		#
		def self.upload_ts_data( language, data, table_name, db_connection, record_sql = false )
			
			raise Exception.new("Language not provided.") if language.nil? or language.to_s.empty?
			raise Exception.new("No data povided. Please make sure the source of your data is valid.") if data.nil? or data.empty?
			raise Exception.new("No table name provided.") if table_name.nil? or table_name.empty?
			raise Exception.new("Invalid connection object provided.") if db_connection.nil? or !db_connection.kind_of? MobyUtil::DBConnection
			
			# Avoid system column names for language columns and user only downcase
			language = language.to_s.downcase
			if language.eql? "id" or language.eql? "fname" or language.eql? "lname" or language.eql? "plurality" or language.eql? "lengthvar" 
				language += "_"
			end
			
			sql_file = File.open(table_name + ".#{db_connection.db_type}.sql", 'a') if record_sql

			# CREATE TABLE if doesn't exist (language columns to be created as needed)
			case db_connection.db_type
				when "mysql"
					query_string = "CREATE TABLE IF NOT EXISTS " + table_name + " ( 
									`ID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
									`FNAME` VARCHAR(150) NOT NULL COLLATE latin1_general_ci,
									`LNAME` VARCHAR(150) NOT NULL COLLATE latin1_general_ci,
									`PLURALITY` VARCHAR(50) COLLATE latin1_general_ci,
									`LENGTHVAR` INT(10),
									PRIMARY KEY (`ID`),
									UNIQUE INDEX `FileLogicNameIndex` (`FNAME`,`LNAME`, `PLURALITY`, `LENGTHVAR`),
									INDEX `LNameIndex` (`LNAME`)
									) COLLATE=utf8_general_ci;"
					MobyUtil::DBAccess.query( db_connection, query_string )
					sql_file.write( query_string + "\n" ) if record_sql
				when "sqlite"
					query_string = "CREATE TABLE IF NOT EXISTS " + table_name + " (
									`ID` INTEGER PRIMARY KEY AUTOINCREMENT,
									`FNAME` VARCHAR(150) NOT NULL,
									`LNAME` VARCHAR(150) NOT NULL,
									`PLURALITY` VARCHAR(50),
									`LENGTHVAR` INT(10));"
					MobyUtil::DBAccess.query( db_connection, query_string )
					sql_file.write( query_string + "\n" ) if record_sql
					
					query_string = "CREATE UNIQUE INDEX IF NOT EXISTS 'FileLogicNameIndex' ON " + table_name + " (`FNAME`,`LNAME`, `PLURALITY`, `LENGTHVAR`);"
					MobyUtil::DBAccess.query( db_connection, query_string )
					sql_file.write( query_string + "\n" ) if record_sql
					
					query_string = "CREATE INDEX IF NOT EXISTS 'FileLogicIndex' ON " + table_name + " (`LNAME`);" 
					MobyUtil::DBAccess.query( db_connection, query_string )
					sql_file.write( query_string + "\n" ) if record_sql
			end
			
			# ADD NEW COLUMNS for new language if needed
			case db_connection.db_type
				when "mysql"
					begin
						query_string = "ALTER TABLE `" + table_name + "` ADD  `" + language + "` VARCHAR(350) NULL DEFAULT NULL COLLATE utf8_general_ci;"
						MobyUtil::DBAccess.query( db_connection, query_string )
						sql_file.write( query_string + "\n" ) if record_sql
					rescue Mysql::Error # catch if language column already exists
					end
				when "sqlite"
					begin
						query_string = "ALTER TABLE `" + table_name + "` ADD  `" + language + "` TEXT;"
						MobyUtil::DBAccess.query( db_connection, query_string )
						sql_file.write( query_string + "\n" ) if record_sql
					rescue SQLite3::SQLException # catch if language column already exists
					end
			end
			# INSERT new data
			case db_connection.db_type
				when "mysql"
					begin
						# Formatting (seems like there is no length limit for the insert string)
						insert_values = ""
						data.each do |fname, source, translation, plurality, lengthvar|
							# Escape ` and ' and "  and other restricted characters in SQL (prevent SQL injections
							source = source.gsub(/([\'\"\`\;\&])/){|s|  "\\" + s}
							translation = (translation != nil) ? translation.gsub(/([\'\"\`\;\&])/){|s|  "\\" + s} : ""
							insert_values += "('" + fname + "', '" + source + "', '" + translation + "', '" + plurality + "', '" + lengthvar + "'), "
						end
						insert_values[-2] = ' ' unless insert_values == "" # replace last ',' with ';'
						# INSERT Query
						query_string = "INSERT INTO `" + table_name + "` (FNAME, LNAME, `" + language + "`, `PLURALITY`, `LENGTHVAR`) VALUES " + insert_values +
							"ON DUPLICATE KEY UPDATE fname = VALUES(fname), lname = VALUES(lname), `" + language + "` = VALUES(`" + language + "`) ;"
						MobyUtil::DBAccess.query( db_connection, query_string )
						sql_file.write( query_string + "\n" ) if record_sql
					rescue Exception => e
						puts e.inspect
						puts e.backtrace.join("\n")
					end
				when "sqlite"
					begin
						# Formatting (limit on the length of the Insert String! So multiple Insets
						counter = 0
						cumulated = 0
						union_all = ""
						MobyUtil::DBAccess.query( db_connection, "BEGIN TRANSACTION")
						sql_file.write( "BEGIN TRANSACTION\n" ) if record_sql
						data.each do |fname, source, translation, plurality, lengthvar|
							counter += 1
							cumulated += 1
							# we MAYBE  fucked if the texts have ";" or "`" or """ but for now only "'" seems to be problematic
							source = source.strip.gsub(/([\'])/){|s|  s + s}
							translation = (translation != nil ) ? translation.strip.gsub(/([\'])/){|s|  s + s} : ""
							### UPDATE OR INSERT IF NO ROWS AFFECTED
							query_string = "UPDATE `" + table_name + "` SET `#{language}`='#{translation}' WHERE FNAME='#{fname}' AND " +
								"LNAME='#{source}' AND `PLURALITY`='#{plurality}' AND `LENGTHVAR`='#{lengthvar}';"
							MobyUtil::DBAccess.query( db_connection, query_string )
							sql_file.write( query_string + "\n" ) if record_sql
							if MobyUtil::DBAccess.affected_rows( db_connection ) == 0
								query_string = "INSERT INTO `" + table_name + "` (FNAME, LNAME, `" + language + "`, `PLURALITY`, `LENGTHVAR`) " + 
									"VALUES ('#{fname}' ,'#{source}','#{translation}', '#{plurality}', '#{lengthvar}');"
								MobyUtil::DBAccess.query( db_connection, query_string )
								sql_file.write( query_string + "\n" ) if record_sql
							end
						end
						MobyUtil::DBAccess.query( db_connection, "COMMIT TRANSACTION")
						sql_file.write( "COMMIT TRANSACTION\n" ) if record_sql
					rescue Exception => e
						puts e.inspect
						puts e.backtrace.join("\n")
						MobyUtil::DBAccess.query( db_connection, "ROLLBACK TRANSACTION")
						sql_file.write( "ROLLBACK TRANSACTION\n" ) if record_sql
					end
			end
		end
		
		
		# == description
		# Extracs application name used for FNAME from a given filename (removes language tags and file extension)
		#
		def self.parseFName(file)
			fname = file.split('/').last
			#(wordlist matching)
			words = ["ar", "bg", "ca", "cs", "da", "de", "el", "en", "english-gb", "(apac)", "(apaccn)", "(apachk)", "(apactw)", "japanese", "thai", "us", "es", "419", "et", "eu", "fa", "fi", "fr", "gl", "he", "hi", "hr", "hu", "id", "is", "it", "ja", "ko", "lt", "lv", "mr", "ms", "nb", "nl", "pl", "pt", "br", "ro", "ru", "sk", "sl", "sr", "sv", "th", "tl", "tr", "uk", "ur", "us", "vi", "zh", "hk", "tw", "no"]
			match = fname.scan(/_([a-zA-Z1-9\-\(\)]*)/)
			if match
				match.each do |m|
					fname.gsub!("_#{m[0]}"){|s| ""} if words.include?( m[0].downcase )
				end
			end
			fname.gsub!(".ts"){|s| ""} 
			return fname #gsub! will return nil if now subs are performed
		end
		
	end # class

end # module

