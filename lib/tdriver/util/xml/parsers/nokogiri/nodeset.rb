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

          cache( :at_index, node ){ node_object( @xml[ node ] ) }

        end

        def first

          cache( :first, :value ){ node_object( @xml.first ) }

        end

        def last

          cache( :last, :value ){ node_object( @xml.last ) }

        end

        def each( &block )

          #@xml.each{ | node | 
          #  yield( cache( :each, node ){ node_object( node ) } ) 
          #}

          # approx. 3,5% faster
          cache( :each, :cached_nodes ){ 

            @xml.collect{ | node | 

              cache( :each, node ){ node_object( node ) }

            }

          }.each{ | node | 

            yield( node ) 

          } 

         self

        end

        def each_with_index( &block )

          @xml.each_with_index{ | node, index | 

            yield( cache( :each, node ){ node_object( node ) }, index )

          }

          self

        end

        def collect( &block )

          _collect( &block )

        end

        def collect!( &block )

          clear_cache

          @xml = _collect( &block )

          self

        end

        def compact

          cache( :compact, :value ){ nodeset_object( @xml.compact ) }

        end

        def compact!

          @xml = cache( :compact_, :value ){ @xml.compact }

          self

        end

        def inject( result, &block )

          cache( :each, :cached_nodes ){ 

            @xml.collect{ | node | 

              cache( :each, node ){ node_object( node ) }

            }

          }.__send__( :inject, result, &block )

          #n = node_object( @xml )

          #n.__send__( :inject, result, &block )

        end

        def sort( &block )

          node_object( _sort( &block ) ) 

        end

        def sort!( &block )

          clear_cache

          @xml = _sort( &block )

          self

        end

        def empty?

          cache( :is_empty, :value ){ @xml.empty? }

        end
        
        def length

          cache( :length, :value ){ @xml.length }

        end
    
    
        def to_a

          cache( :to_a, :value ){ @xml.collect{ | node | node_object( node ) } }
          
        end
        
        def delete( node )

          clear_cache

          @xml.each do | nodeset_node |

            if ( node.xml.content == nodeset_node.content )

              @xml.delete( nodeset_node )

              break

            end

          end
          
        end

        # aliases for length method
        alias size length

        alias count length

      private

        def _collect( &block )

          #@xml.collect{ | node | yield( cache( :each, node ){ node_object( node ) } ) }

          # approx. 3.5% faster
          cache( :each, :cached_nodes ){ 

            @xml.collect{ | node | 

              cache( :each, node ){ node_object( node ) }

            }

          }.collect{ | node | 

            yield( node )

          }

        end

        def _sort( &block )

          @xml.sort{ | node_a, node_b | 
        
            if block_given?

              yield( cache( :each, node_a ){ node_object( node_a ) }, cache( :each, node_b ){ node_object( node_b ) } )

            else

              node_a <=> node_b

            end

          } 

        end

        # enable hooking for performance measurement & debug logging
        TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

      end # Nodeset

    end # Nokogiri

  end # XML

end # MobyUtil
