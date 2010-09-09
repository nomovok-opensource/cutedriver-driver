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

  class ParameterTemplates

    include Singleton

    def initialize

      @@templates = nil

    end

    def load_templates()

      content = MobyUtil::ParameterXml.instance.merge_files( 'templates/', 'templates', '/templates/*' )

      @@templates = MobyUtil::XML::parse_string( content )

    end

    # Helper method for 'get_template_from_xml' to retrieve all requested inherited parameters.
    # === params
    # list_of_inherited_templates:: String representation of template names, separated with ";"
    # === returns
    # Hash:: Hash containing parameters
    # === raises
    # === example
    # result_hash = get_inherited_parameters( "template1;template2;template3" )
    def get_inherited_parameters( list_of_inherited_templates )

      result = ParameterHash.new
      
      if list_of_inherited_templates.kind_of?( String )

        list_of_inherited_templates.split( ";" ).each{ | inherits_from | 
          
          result.merge_with_hash!( 

            get_template_from_xml( inherits_from ) 
          
          ) 

        }

      end

      result

    end

    def get_template_from_xml( template_name )

      result = ParameterHash.new 

      # return empty template hash if no templates loaded
      return result unless @@templates

      begin

        template_nodeset = @@templates.xpath( "/templates/template[@name='%s']" % [ template_name ] )

        if template_nodeset.size > 0

          template_nodeset.each{ | template_node | 

            # merge and overwrite inherited template parameters 
            result.merge!( 

              get_inherited_parameters( 

                template_node.attribute( 'inherits' ).to_s

              ) 

            ).merge!( 

              # merge template to hash
              MobyUtil::ParameterXml.instance.parse( template_node.to_s ) 

            )
          }

        end

      rescue Exception => exception

        Kernel::raise RuntimeError.new( 
          "Error retrieving template %s from xml. Reason: %s (%s)" % [ template_name, exception.message, exception.class ] 
        ) 

      end

      result

    end

    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # ParameterTemplates

end # MobyUtil
