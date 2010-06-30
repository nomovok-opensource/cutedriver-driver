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

    
    
module ReportDataTable
        
  def add_data_from_hash(data_hash_to_add,table_data,table_columns)
    raise TypeError.new( 'Input parameter not of Type: Hash.\nIt is: ' + data_hash_to_add.class.to_s ) unless data_hash_to_add.kind_of?( Hash )

    data_hash_to_add.each_key {|key| table_columns<<key if !table_columns.include?(key)}
    table_data<<data_hash_to_add
  end
    
  def add_data_from_array(data_array_to_add,table_data,table_columns)
    raise TypeError.new( 'Input parameter not of Type: Array.\nIt is: ' + data_array_to_add.class.to_s ) unless data_array_to_add.kind_of?( Array )
  
    column=nil
    data=nil
    column_found=false
    value_found=false
    data_hash=Hash.new
      
    data_array_to_add.each do |value|
      if (column_found)  
        data=value
        data_found=true
      end
      
      if (!column_found)  
        column=value
        column_found=true
      end
        
      if (column_found && data_found)
        if column!=nil && data!=nil
          data_hash[column]=data
          table_columns<<column unless table_columns.include?(column) 
          column_found=false
          data_found=false
        end
      end
    end
    
    table_data<<data_hash
  end
end #ReportDataTable 
    