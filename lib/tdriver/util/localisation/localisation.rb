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

# TODO: refactor to use MobyUtil::XML
require 'nokogiri'

# Utility for handling localisation database
module MobyUtil

	class Localisation
    
    # == Language maping cross-referenced from Nokia Shared Lancuage Codes and Symbian 
    #
    # Please follow Nokia Language Guidelines.
    #
    # Its also enumerated by TLanguage in e32lang.h in the Symbian code.
    # The ones only on e32lang.h are commented out
    @language_code_map = {
      "English" => ["en", "01"],
      "French" => ["fr", "02"],
      "German" => ["de", "03"],
      "Spanish" => ["es", "04"],
      "Italian" => ["it", "05"],
      "Swedish" => ["sv", "06"],
      "Danish" => ["da", "07"],
      "Norwegian" => ["no", "08"], 
      "Finnish" => ["fi", "09"],
      "English US" => ["en_US", "10"],
      # "Swiss French" => ["SF", "11"],
      # "Swiss German" => ["SG", "12"],
      "Portuguese" => ["pt", "13"],
      "Turkish" => ["tr", "14"],
      "Icelandic" => ["is", "15"],
      "Russian" => ["ru", "16"],  
      "Hungarian" => ["hu", "17"],  
      "Dutch" => ["nl", "18"],  
      # "Belgian Flemish" => ["BL", "19"],  
      # "Australian" => ["AU", "20"],  
      # "Belgian French" => ["BF", "21"],  
      # "Austrian" => ["AS", "22"],  
      # "New Zealand" => ["NZ", "23"],  
      # "International French" => ["IR", "24"],  
      "Czech" => ["cs", "25"],  
      "Slovak" => ["sk", "26"],  
      "Polish" => ["pl", "27"],  
      "Slovenian" => ["sl", "28"],  
      "Chinese TW" => ["zh_TW", "29"],  
      "Chinese HK" => ["zh_HK", "30"],  
      "Chinese" => ["zh", "31"],  
      "Japanese" => ["ja", "32"],  
      "Thai" => ["th", "33"],  
      "Afrikaans" => ["af", "34"],  
      "Albanian" => ["sq", "35"],  
      "Amharic" => ["am", "36"],  
      "Arabic" => ["ar", "37"],  
      "Armenian" => ["hy", "38"],  
      "Filipino" => ["tl", "39"],
      "Belarusian" => ["be", "40"],
      "Bengali" => ["bn", "41"],
      "Bulgarian" => ["bg", "42"],  
      # "Burmese" => ["MY", "43"],  
      "Catalan" => ["ca", "44"],  
      "Croatian" => ["hr", "45"],  
      # "Canadian English" => ["CE", "46"],  
      # "International English" => ["IE", "47"],  
      # "South African English" => ["SA", "48"],  
      "Estonian" => ["et", "49"],  
      "Persian" => ["fa", "50"],  
      "French CA" => ["fr_CA", "51"],
      # "Scots Gaelic" => ["GD", "52"],  
      "Georgian" => ["ka", "53"],  
      "Greek" => ["el", "54"],  
      # "Cyprus Greek" => ["CG", "55"],  
      "Gujarati" => ["gu", "56"],  
      "Hebrew" => ["he", "57"],  
      "Hindi" => ["hi", "58"],  
      "Indonesian" => ["id", "59"],  
      # "Irish" => ["GA", "60"],  
      # "Swiss Italian" => ["SZ", "61"],  
      "Kannada" => ["kn", "62"],  
      "Kazakh" => ["kk", "63"],  
      "Khmer" => ["km", "64"],  
      "Korean" => ["ko", "65"],  
      # "Lao" => ["lo", "66"],  
      "Latvian" => ["lv", "67"],  
      "Lithuanian" => ["lt", "68"],  
      "Macedonian" => ["mk", "69"],  
      "Malay" => ["ms", "70"],  
      "Malayalam" => ["ml", "71"],  
      "Marathi" => ["mr", "72"],  
      # "Moldavian" => ["MO", "73"],  
      "Mongolian" => ["mn", "74"],  
      # "Norwegian Nynorsk" => ["nn", "75"],  
      "Portuguese BR" => ["pt_BR", "76"],  
      "Punjabi" => ["pa", "77"],  
      "Romanian" => ["ro", "78"],  
      "Servian" => ["sr", "79"], 
      "Sinhala" => ["si", "80"],  
      # "Somali" => ["SO", "81"],  
      # "International Spanish" => ["OS", "82"],  
      "Spanish AM" => ["es_419", "83"],  
      "Swahili" => ["sw", "84"],  
      # "Finland Swedish" => ["FS", "85"],  
      "Tamil" => ["ta", "87"],   
      "Telugu" => ["te", "88"],  
      # "Tibetan" => ["BO", "89"],  
      # "Tigrinya" => ["TI", "90"], 
      # "Cyprus Turkish" => ["CT", "91"],  
      "Turkem" => ["tk", "92"],  
      "Ukranian" => ["uk", "93"],  
      "Urdu" => ["ur", "94"],  
      "Vietnamese" => ["vi", "96"],  
      # "Welsh" => ["CY", "97"],
      "Zulu" => ["zu", "98"],  
      # "Manufacturer English" => ["ME", "100"],
      "Sesotho" => ["st", "101"],
      "Basque" => ["eu", "102"],
      "Galician" => ["gl", "103"],
      # "Javanese" => ["", "104"],
      # "Maithili" => ["", "105"],
      # "Azerbaijani Latin" => ["", "106"],
      "Azerbaijani Cyrillic" => ["az", "107"],
      "Oriya" => ["or", "108"],
      # "Bhojpuri" => ["", "109"],
      # "Sundanese" => ["", "110"],
      # "Kurdish Latin" => ["", "111"],
      # "Kurdish Arabic" => ["", "112"],
      "Pashto" => ["ps", "113"],
      "Hausa" => ["ha", "114"],
      #"Oromo" => ["", "115"],
      # "Uzbek Latin" => [", "116"],
      "Uzbek Cyrillic" => ["uz", "117"],
      # "Sindhi Arabic" => ["", "118"],
      # "Sindhi Devanagari" => ["", "119"],
      "Yoruba" => ["yo", "120"],
      # "Cebuano" => ["", "121"],
      "Igbo" => ["ig", "122"],
      "Malagasy" => ["mg", "123"],
      # "Nepali" => ["", "124"],
      "Assamese" => ["as", "125"],
      # "Shona" => ["", "126"],
      # "Zhuang" => ["", "127"],
      # "Madurese" => ["", "127"],
      "English Apac" => ["EA", "129"],          # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      "English Taiwan" => ["YW", "157"],        # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      "English Hong Kong" => ["YH", "158"],     # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      "English PRC" => ["YP", "159"],           # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      "English Japan" => ["YJ", "160"],         # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      "English Thailand" => ["YT", "161"],      # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      # "Fulfulde" => ["", "162"], 
      # "Tamazight" => ["", "163"], 
      # "BolivianQuechua" => ["", "164"], 
      # "PeruQuechua" => ["", "165"], 
      # "EcuadorQuechua" => ["", "166"], 
      "Tajik_Cyrillic" => ["tg", "167"], 
      # "Tajik_PersoArabic" => ["", "168"], 
      # "Nyanja" => ["", "169"], 
      # "HaitianCreole" => ["", "170"], 
      # "Lombard" => ["", "171"], 
      # "Koongo" => ["", "172"],  
      # "Akan" => ["", "173"], 
      # "Hmong" => ["", "174"], 
      # "Yi" => ["", "175"], 
      # "Tshiluba" => ["", "176"], 
      # "Ilocano" => ["", "177"], 
      # "Uyghur" => ["", "178"], 
      # "Neapolitan" => ["", "179"], 
      # "Rwanda" => ["", "180"], 
      "Xhosa" => ["xh", "181"], 
      # "Balochi" => ["", "182"], 
      # "Hiligaynon" => {"", "183"],
      # "Minangkabau" => ["", "184"], 
      # "Makhuwa" => ["", "185"], 
      # "Santali" => ["", "186"], 
      # "Gikuyu" => ["", "187"], 
      # "Moore" => ["", "188"], 
      # "Guarani" => ["", "189"],  
      # "Rundi" => ["", "190"], 
      # "Romani_Latin" => ["", "191"], 
      # "Romani_Cyrillic" => ["", "192"], 
      # "Tswana" => ["", "193"], 
      # "Kanuri" => ["", "194"], 
      # "Kashmiri Devanagari" => ["", "195"], 
      "Kashmiri Perso Arabic" => ["ks", "196"], 
      # "Umbundu" => ["", "197"], 
      # "Konkani" => ["", "198"], 
      # "Balinese" => ["", "199"], 
      # "Northern Sotho" => ["", "200"], 
      # "Wolof" => ["", "201"], 
      # "Bemba" => ["", "202"], 
      # "Tsonga" => ["", "203"], 
      # "Yiddish" => ["", "204"], 
      "Kirghiz" => ["ky", "205"], 
      # "Ganda" => ["", "206"], 
      # "Soga" => ["", "207"], 
      # "Mbundu" => ["", "208"], 
      # "Bambara" => ["", "209"], 
      # "Central Aymara" => ["", "210"], 
      # "Zarma" => ["", "211"], 
      "Lingala" => ["ln", "212"], 
      # "Bashkir" => ["", "213"], 
      # "Chuvash" => ["", "214"], 
      # "Swati" => ["", "215"], 
      # "Tatar" => ["", "216"], 
      # "Southern Ndebele" => ["", "217"], 
      # "Sardinian" => ["", "218"], 
      # "Scots" => ["", "219"], 
      # "Meitei" => ["", "220"], 
      # "Walloon" => ["", "221"], 
      # "Kabardian" => ["", "222"], 
      # "Mazanderani" => ["", "223"], 
      # "Gilaki" => ["", "224"], 
      # "Shan" => ["", "225"], 
      # "Luyia" => ["", "226"], 
      # "Luo" => ["", "227"], 
      # "Sukuma" => ["", "228"], 
      # "Aceh" => ["", "229"], 
      #"English_India" => ["", "230"],           # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      "Malay Apac" => ["MA", "326"],            # In e32long.h, Pearl script, but not in Nokia Language Codes Standard
      # "Indonesian Apac" =>["", "327"],
      # "Bengali IN" => ["bn_IN", ""],
      # "Bosnian" => ["bs", ""],
    }
    
    
    
    
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
		#   description: Name of the language column to be used. This is normally the language postfix found on the .ts, .qm translation files. On .loc file postfix numbers are mapped to similar language codes according to standards in Symbian literature and others, check the localization.db implementation file for the full mapping.
		#   example: "en" or "es_416" or "en_us"
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
		
			raise LogicalNameNotFoundError.new( "Logical name cannot be nil" ) if logical_name == nil
			raise LanguageNotFoundError.new( "Language cannot be nil" ) if language == nil
			raise TableNotFoundError.new( "Table name cannot be nil" ) if table_name == nil
			
			# Avoid system column names for language columns and user only downcase
			language = language.to_s.downcase
			if language.eql? "id" or language.eql? "fname" or language.eql? "lname" or language.eql? "plurality" or language.eql? "lengthvar" 
				language += "_"
			end
			
			db_type =  $parameters[ :localisation_db_type, nil ]
			host =  $parameters[ :localisation_server_ip ]
			username = $parameters[ :localisation_server_username ]
			password = $parameters[ :localisation_server_password ]
			database_name = $parameters[ :localisation_server_database_name ]
			
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
				# if column referring to language is not found then raise error for language not found
				raise LanguageNotFoundError.new( "No language '#{ language }' found" ) unless $!.message.index( "Unknown column" ) == nil
				raise SqlError.new( $!.message )
			end

			# Return only the first column of the row or and array of the values of the first column if multiple rows have been found
			raise LogicalNameNotFoundError.new( "No translation found for logical name '#{ logical_name }' in language '#{ language }' with given plurality and lengthvariant." ) if ( result.empty?)
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
		#   description: Use this parameter to change the default language names. The default language postfix translation files (.ts, .qm or .loc) as keys and the desired column names as values
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
			raise ArgumentError.new("") if file.nil? or file.empty?
			raise ArgumentError.new("") if table_name.nil? or table_name.empty?

			# Get a connection to the DB
			if db_connection.nil? or !db_connection.kind_of? MobyUtil::DBConnection
				db_type =  $parameters[ :localisation_db_type ]
				host =  $parameters[ :localisation_server_ip ]
				database_name = $parameters[ :localisation_server_database_name ]
				username = $parameters[ :localisation_server_username ]
				password = $parameters[ :localisation_server_password ]
				
				db_connection = DBConnection.new(  db_type, host, database_name, username, password )
			end
      if file.match(/.*\.ts/) or file.match(/.*\.qm/)
        # Check File and convert to TS File if needed
        tsFile = MobyUtil::Localisation.convert_to_ts( file )
        raise Exception.new("Failed to convert #{file} to .ts") if tsFile == nil	
        # Collect data for INSERT query from TS File
        language, data = MobyUtil::Localisation.parse_ts_file( tsFile, column_names_map )
        raise Exception.new("Error while parsing #{file}.") if language == nil or data == ""
			elsif file.match(/.*\.loc/)
        language, data = MobyUtil::Localisation.parse_loc_file( file, column_names_map )
        raise Exception.new("Error while parsing #{file}. The file might have no translations.") if language.nil? or language.empty? or data.nil? or data.empty?
      end
      # Upload language data to DB for current language file
			MobyUtil::Localisation.upload_data( language, data, table_name, db_connection, record_sql )
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
			# language = doc.xpath('.//TS').attribute("language")
			# IF filename-to-columnname mapping is provided update language
			fname, language = parseFName(file)
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
            plurality = 1
						node.xpath('.//translation/numerusform').each do |numerus|
							nodePlurality = numerus.xpath('@plurality').inner_text()
              nodePlurality = plurality.to_s if nodePlurality.empty?
							if ! numerus.xpath('.//lengthvariant').empty?
								# puts "  >>> Lengthvar"
                priority = 1
								numerus.xpath('.//lengthvariant').each do |lenghtvar|
									nodeLengthVar = lenghtvar.xpath('@priority').inner_text()
                  nodeLengthVar = priority.to_s if nodeLengthVar.empty?
									nodeTranslation = lenghtvar.inner_text()
									data << [ fname, nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
                  priority += 1
								end
							else
								nodeTranslation = numerus.inner_text()
								data << [ fname, nodeId, nodeTranslation, nodePlurality, nodeLengthVar ]
                plurality += 1
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
            # When no lengthvar is provided we now assign priority '1' by default
						# puts ">>> Translation"
						nodeTranslation = node.xpath('.//translation').inner_text()
						data << [ fname, nodeId, nodeTranslation, nodePlurality, nodeLengthVar = '1' ]
					end
				rescue Exception # ignores bad elements or elements with empty translations for now
				end
			end
			open_file.close
			return language, data
		end
		
    #
    # Note: for .loc files the colum mapping is done with the Language code number on the filenames
    #
    def self.parse_loc_file(file, column_names_map = {})
    begin
    
      data = []
      file.split('/').last.match(/(.*)_(\w{2,3}).loc/)
      fname = $1
      language_number = $2
      # select returns an array of [language, codes] that suite the conditional
      # codes is the array ["NokiaCode(2-leter)", "SymbianCode(number)"]
      language = @language_code_map.select{|lang,codes| codes[1] == language_number}.to_a[0][1][0] # Array conversion for ruby 1.9 compatibility
			language = column_names_map[ language_number ] if !column_names_map.empty? and column_names_map.key?( language_number )
      
      io = open(file)
      while line = io.gets
        if line.match(/#define ([a-zA-Z1-9\_]*) \"(.*)\"/)
          lname = $1
          translation = $2
          # When no lengthvar is provided we now assign priority '1' by default          
          data <<  [ fname, lname, translation, plurality = "", lengthvariant = "1" ]
        end
      end
      io.close
      #puts language
      #p data
      return language, data
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    end
		
		# == description
		# Uploads language data to Localisation DB and optionally records the sql queries on a file
		#
		def self.upload_data( language, data, table_name, db_connection, record_sql = false )
			
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
      # When no lengthvar is provided we now assign priority '1' by default
			case db_connection.db_type
				when "mysql"
					query_string = "CREATE TABLE IF NOT EXISTS " + table_name + " ( 
									`ID` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
									`FNAME` VARCHAR(150) NOT NULL COLLATE latin1_general_ci,
									`LNAME` VARCHAR(150) NOT NULL COLLATE latin1_general_ci,
									`PLURALITY` VARCHAR(50) NULL DEFAULT NULL COLLATE latin1_general_ci,
									`LENGTHVAR` INT(10) NULL DEFAULT '1',
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
									`PLURALITY` VARCHAR(50) DEFAULT NULL,
									`LENGTHVAR` INT(10) DEFAULT '1');"
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
						query_string = "ALTER TABLE `" + table_name + "` ADD  `" + language + "` TEXT NULL DEFAULT NULL COLLATE utf8_general_ci;"
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
		# Used only on .ts files
		def self.parseFName(file)
			#(wordlist matching)
			words = ["ar", "bg", "ca", "cs", "da", "de", "el", "en", "english-gb", "(apac)", "(apaccn)", "(apachk)", "(apactw)", "japanese", "thai", "us", "es", "419", "et", "eu", "fa", "fi", "fr", "gl", "he", "hi", "hr", "hu", "id", "is", "it", "ja", "ko", "lt", "lv", "mr", "ms", "nb", "nl", "pl", "pt", "br", "ro", "ru", "sk", "sl", "sr", "sv", "th", "tl", "tr", "uk", "ur", "us", "vi", "zh", "hk", "tw", "no", "gb", "cn"]
      
      fname = file.split('/').last
      fname.gsub!(".ts"){|s| ""} 
      fname_fragments = fname.split('_')
      fname_fragments.each_index do |i|
        fname_fragments[i] = "" if words.include?( fname_fragments[i].downcase )
      end
      fname_fragments.delete("")
      fname = fname_fragments.join("_")
      language = file.split('/').last.gsub( fname + "_" ){|s| ""}.gsub(".ts"){|s| ""}
      return fname, "" if fname == language
      return fname, language
    end
		
	end # class

end # module

