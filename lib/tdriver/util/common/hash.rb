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

# extend Ruby Hash class functionality
class Hash

  def not_empty( message = "Hash must not be empty", exception = ArgumentError )

    raise exception, message if empty? 

  end

  # Verify that received object contains one of given keys. Raises exception is key not found.
  def require_key( keys, message = "None of key(s) $1 found from hash" )

    # create array of types
    keys_array = Array( keys )

    found = false

    verbose_keys_list = keys_array.each_with_index.collect{ | key, index | 

      if has_key?( key )
        found = true
        break 
      end

      # result string, separate types if multiple types given
      "#{ ( ( index > 0 ) ? ( index + 1 < keys_array.count ? ", " : " or " ) : "" ) }#{ key.inspect }"
          
    }

    # raise exception if type did not match
    unless found

      # convert macros
      [ verbose_keys_list.join ].each_with_index{ | param, index | message.gsub!( "$#{ index + 1 }", param.to_s ) }

      # raise the exception
      raise ArgumentError, message

    end

    self

  end

  # Verify that received object contains all of given keys. Raises exception is key not found.
  def require_keys( keys, message = "Required key(s) $1 not found from hash" )

    # create array of types
    keys_array = Array( keys )

    found = true

    verbose_keys_list = keys_array.each_with_index.collect{ | key, index | 

      found = false unless has_key?( key )

      # result string, separate types if multiple types given
      "#{ ( ( index > 0 ) ? ( index + 1 < keys_array.count ? ", " : " and " ) : "" ) }#{ key.inspect }"
          
    }

    # raise exception if type did not match
    unless found

      # convert macros
      [ verbose_keys_list.join ].each_with_index{ | param, index | message.gsub!( "$#{ index + 1 }", param.to_s ) }

      # raise the exception
      raise ArgumentError, message

    end

    self

  end

  # collect given keypairs from hash 
  def collect_keys( *keys )
  
    #Hash[ self.select{ | key, value | true if keys.include?( key ) } ]
  
    # optimized version, approx 47.9% faster
    keys.inject( {} ){ | hash, key | hash[ key ] = self[ key ] if has_key?( key ); hash }
    
  end

  # remove keys from hash, return hash of deleted keys as result
  def delete_keys!( *keys )

    #Hash[ keys.flatten.collect{ | key | [ key, delete( key ) ] if has_key?( key ) }.compact ]

    # optimized version, approx 23.4% faster
    keys.inject( {} ){ | hash, key | hash[ key ] = delete( key ) if has_key?( key ); hash }
    
  end
  
  # delete multiple keys from hash, does not modify original hash
  def delete_keys( *keys )
  
    # create a duplicate of current hash
    result = dup; keys.flatten.each{ | key | result.delete( key ) }; result

    # optimized version, approx 5% faster
    #keys.inject( dup ){ | hash, key | hash.delete( key ); hash }

  end

  # store keys and values to hash if not already defined
  def default_values( hash )

    hash.each_pair{ | key, value | self[ key ] = value unless has_key?( key ) }

    self

  end

  # store key and avalue to hash if not already defined
  def default_value( key, value )

    self[ key ] = value unless has_key?( key )

    self

  end

  def strip_dynamic_attributes!

=begin
    # remove dynamic attributes from hash and return as result     
    Hash[ 

      # iterate through each hash key
      select{ | key, value | 

        # dynamic attribute name has "__" prefix
        if key.to_s =~ /^__/ 

          # remove dynamic attribute key from hash
          delete( key )

          # add to hash
          true

        else

          # do not add to hash
          false

        end

      } 

    ]
=end

    # optimized version, approx 3.2% faster     
    prefix = '__'

    keys.inject( {} ){ | hash, key | 

      hash[ key ] = delete( key ) if key.to_s[0..1] == prefix
    
      hash
    
    }

  end # strip_dynamic_attributes!

  # TODO: document me
  def recursive_merge( other )
  
    self.merge( other ){ | key, old_value, new_value |

      new_value

      if old_value.kind_of?( Hash ) && new_value.kind_of?( Hash )
      
        # merge hashes, call self recursively
        old_value.recursive_merge( new_value )

      elsif old_value.kind_of?( Array ) && new_value.kind_of?( Array )

        # concatenate arrays
        old_value.clone.concat( new_value ).uniq
      
      else

        # return new value as is
        new_value
      
      end

    }
  
  end # recursive_merge

  # TODO: document me
  def recursive_merge!( other )
  
    self.replace( 
    
      recursive_merge( other )
      
    )
  
  end # recursive_merge!

end
