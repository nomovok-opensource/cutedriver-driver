require 'nokogiri'

doc   = Nokogiri::XML(open("example.xml",'r').read)
xslt  = Nokogiri::XSLT(open("template.xsl",'r').read)

puts xslt.transform(doc)

