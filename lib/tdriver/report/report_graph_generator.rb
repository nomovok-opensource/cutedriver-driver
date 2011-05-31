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

class ReportGraphGenerator
  def initialize(columns,data)
    @columns=columns
    @data=data
  end

  def generate_graph(file_name)

    begin
      require 'gruff'
    rescue LoadError
      $stderr.puts "Can't load the Gruff gem. If its missing from your system please run 'gem install gruff' to install it."
    end

    begin
      g = Gruff::Line.new()
                  
      data_rows = Hash.new #Create hash for data
      @columns.each do |title|        
        data_rows[title] = Array.new #Create array for data
      end
                        
      @data.each do |value|        
        value.each_key do |key|
          data_rows[key].push(value[key].to_f) #Put values in the row data
        end
      end
      
      data_rows.each_key do |key|
        g.data(key, data_rows[key])
      end
      
      g.write(file_name)

    rescue Exception => e
      puts "Graph creation failed #{e.message} from data: "
      p data_rows
    end
  end
end
