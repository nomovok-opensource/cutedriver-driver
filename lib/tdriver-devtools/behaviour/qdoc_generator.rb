
require 'tdriver'


def qdoc_header( sut_type )

  header = 
   "/*!
    \\page methods-auto-#{sut_type}
	\\target page start

	\\title Methods for #{sut_type} test objects
		
		Table of contents:

        \\tableofcontents section2
		
        \\part Methods for #{sut_type}

        These methods can be used with a #{sut_type} SUT.
		"

	return header

end

def qdoc_footer

  footer = 
  "\nJump back to \l{page start}{top} of this page.
  
  */"

  return footer
  
end

def clean_e( ee )

  ce = ee.chomp
  
  if ce[0, 1].to_s == "<"    
	ce = ce[si = ce.index(">")+1, ce.rindex("<") - si]
    return ce
  else  
    return ee
  end

end

types = []


data = MobyUtil::ParameterXml.instance.merge_files( 'behaviours/', 'behaviours', '/behaviours/*' )

doc = MobyUtil::XML::parse_string( data )

doc.xpath( "/#{ doc.root.name }/behaviour" ).each do | element | 

  element_sut = element.attribute( "sut_type" )
  types.push( element_sut ) unless types.include? element_sut

end

types.delete_if { | x |  x == "*" }

methods_all = {}
max_method_length = 0

types.each do | sut_type | 

  method_qdocs = {}
  File.open( "methods-auto-" + sut_type + ".qdoc", "w" ) do | qdoc_file |
  
    qdoc_file.write qdoc_header( sut_type )
    methods = []	
	
	sut_methods = doc.xpath( "/#{ doc.root.name }/behaviour[@sut_type = \"" + sut_type + "\" or @sut_type = \"*\"]/methods/method" )
	sut_methods = sut_methods.to_a
	
	sut_methods.sort!
	sut_methods.each do | element | 

	method_name = element.attribute( "name" ).to_s
	  

	  methods_all[method_name] = [] unless methods_all.has_key? method_name
	  methods_all[method_name].push sut_type

	  
	  method_description = element.xpath("description").first
	  method_description = method_description.nil? ? "" : clean_e( method_description.text.to_s )

	  method_arguments = element.xpath( "arguments/argument" )
	  method_profile = ""
	  # add arguments to the profile
	  if !method_arguments.nil? && method_arguments.size > 0
	    method_arguments.each do | arg |
		  temp_name = arg.attribute("name")
		  if !temp_name.nil?
		    method_profile += " #{temp_name},"
		  end		  		  
		end
		if !method_profile.empty?
		  method_profile.chop!
		  method_profile = " (" + method_profile + " )"
		end
	  end
	  method_profile = method_name + method_profile
	  method_qdoc = 
	  "\\chapter #{method_name}
	   #{method_profile}
	   
	   #{method_description}
	  "
	  
	  if !method_arguments.nil? && method_arguments.size > 0
	    method_qdoc << 
		"\\section1 Arguments
		 \\table 100% 
		 \\header
		 \\o Name
		 \\o Type
		 \\o Description
		 \\o Example
		 \\o Default
	    "
		
		method_arguments.each do | argument |
				  
		  method_qdoc <<
		  "
		    \\row
			\\o #{ argument.attribute( "name" ) }
			\\o #{ argument.attribute( "type" ) }
			\\o #{ argument.attribute( "description" ) }
			\\o #{ argument.attribute( "example" ) }
			\\o #{ argument.attribute( "default" ) }
		  "
		
		end
		
		method_qdoc << 
		"
		  \\endtable
		"
		
	  end # arguments
	  
	  method_retvals = element.xpath( 'return-values/return-value' )
	  if method_retvals.size > 0
	  method_qdoc << 
		"\\section1 Return value
		 \\table 100%
		 \\header
		 \\o Type
		 \\o Description
		 \\o Example
		"
	  
	  method_retvals.each do | retval |
	  
	   method_qdoc <<
		  "
		    \\row
			\\o #{ retval.attribute( "type" ) }
			\\o #{ retval.attribute( "description" ) }
			\\o #{ retval.attribute( "example" ) }			
		  "
		  
	  end # retvals
	  
	  method_qdoc << 
		"
		  \\endtable
		"
	  end
	  
	  
	  method_exceptions = element.xpath( 'exceptions/exception' )
	  if method_exceptions.size > 0
	  method_qdoc << 
		"\\section1 Exceptions
		 \\table 100%
		 \\header
		 \\o Type
		 \\o Description
		"
	  
	  method_exceptions.each do | exception |
	  
	   method_qdoc <<
		  "
		    \\row
			\\o #{ exception.attribute( "type" ) }
			\\o #{ exception.attribute( "description" ) }
		  "
		  
	  end # exceptions
	  
	  method_qdoc << 
		"
		  \\endtable
		"

      end
		
	  method_info = element.xpath( 'more-info' )
	  if method_info.size > 0
	    method_qdoc << "
		\\section1 More information
		" << method_info.first.text.to_s
	  end

	  method_howtos = element.xpath( 'howtos/howto' )
	  if method_howtos.size > 0
	  method_qdoc << 
		"
		\\section1 Examples		 
		"
	  
	  method_howtos.each do | howto |
	  
	   method_qdoc <<
		  "			
			#{ howto.attribute( "description" ) }
			\\code
			#{ howto.text.to_s }
			\\endcode
		  "
		  
	  end # exceptions
	  end # if
	  
	  method_qdocs[method_name] = method_qdoc
	  max_method_length = method_name.size > max_method_length ?  method_name.size : max_method_length
	  
    end # each method
 
	
	method_keys = method_qdocs.keys
	method_keys.sort!
	method_keys.each do | method_name |
	
	  qdoc_file.write method_qdocs[method_name]
	  
	end
	
	qdoc_file.write qdoc_footer
	
  end # File.open
end # types

# create the methods all file
File.open( "methods-all.qdoc", "w" ) do | qdoc_file |

  qdoc_file.write( "/*!
	
    \\page methods-all
	\\target page start
	
	\\title All methods
	
  
	\\raw HTML
        <style type=\"text/css\" >
                body
                {
			font-family:Courier;   
        }
        </style>
	\\endraw
	
	\\chapter SUT and Test Object methods
	
	\\list
	" )
    #\\list" )
	
  all_keys = methods_all.keys.sort
  
  all_keys.each do | method_name |
  
    method_suts = methods_all[method_name].uniq.sort
		
	sut_list = ""
	method_item = "\n\\o " + method_name 
	filler = ""
	if method_item.size < max_method_length+5

	  filler = "\\unicode{160}" * (max_method_length + 5 - method_item.size)

	end

	method_item += filler
	method_item += "- "	
	
	method_suts.each do | sut_name |
	  sut_list += ", " unless sut_list.empty?
	  sut_list += "\\l{methods-auto-#{sut_name}##{method_name}}{#{sut_name}}"
	end

	qdoc_file.write method_item + sut_list
  
  end # each method
    

  qdoc_file.write( "\n
   \\endlist
   
    Jump back to \\l{page start}{top} of this page.
  
   \\chapter Support methods
   
   \\include methods-support.qdocinc

  Jump back to \\l{page start}{top} of this page.
    
	*/
  ")
end # File.open
