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

module MobyUtil

  module XML

    module Nokogiri

      module Nodeset # behaviour

        include Abstraction 

        def []( node )

          node_object( @xml[ node ] )

        end

        def first

          node_object( @xml.first )

        end

        def last

          node_object( @xml.last )

        end

        def each( &block )

          @xml.each{ | element | 

            yield( node_object( element ) ) 

          }

          self

        end

        def each_with_index( &block )

          @xml.each_with_index{ | element, index | 

            yield( node_object( element ), index ) 

          }

          self

        end

        def collect( &block )

          _collect( &block )
          #nodeset_object( _collect( &block ) )

        end

        def collect!( &block )

          @xml = _collect( &block )

          self

        end

        def compact

          nodeset_object( @xml.compact )

        end

        def compact!

          @xml = @xml.compact

          self

        end

        def sort( &block )

          nodeset_object( _sort( &block ) ) 

        end

        def sort!( &block )

          @xml = _sort( &block )

          self

        end

        def empty?

          @xml.empty?

        end

        
        def length

          @xml.length

        end
    
    
        def to_a

          @xml.collect{ | element | 

            node_object( element ) 

          }
          
        end
        
        def delete( node )

          @xml.each do | element |

            if ( node.xml.content == element.content )

              @xml.delete( element )

              break

            end

          end
          
        end

        # aliases for length method
        alias size length

        alias count length

      private

        def _collect( &block )

          @xml.collect{ | element | 

            yield( node_object( element ) ) 

          } 

        end

        def _sort( &block )

          @xml.sort{ | element_a, element_b | 
        
            if block_given?

              yield( node_object( element_a ), element_object( element_b ) ) 

            else

              element_a <=> element_b

            end

          } 

        end

        # enable hooking for performance measurement & debug logging
        MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

      end # Nodeset

    end # Nokogiri

  end # XML

end # MobyUtil
