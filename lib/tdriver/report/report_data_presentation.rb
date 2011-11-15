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



module TDriverReportDataPresentation
	include TDriverReportWriter
	
	## This method will create a .png image with a graph
	## Arguments
	# data:: Hash: Data to be ploted in the form of {"signal_name" => [ value 1, value 2, .., value n] , ...}
	# filename:: String: filname for the image that will be generated. Should have .png extension
	# title:: String: Title for the graph
	## Returns
	# String: String with the <img> tag to be inserted into an html file
	## Exceptions
	# ArgumentError: Thown when data or filname provided are either nil or the wrong types
	def create_graph_image( data, filename, title = nil)
		begin
			require 'gruff'
		rescue Exception => e
			puts "Can't load the Gruff gem. If its missing from your system please run 'gem install gruff' to install it."
			puts e.inspect
		end
		begin
     
			raise TypeError, "ERROR create_graph_image: Data argument is either nil or not a Hash" if ( data.nil? or !data.kind_of? Hash )

			raise ArgumentError, "ERROR create_graph_image: Values of the data Hash need to be arrays of minimum length 2" if ( !data.values[0].kind_of? Array or data.values[0].length < 2 )

			raise TypeError, "ERROR create_graph_image: Filename argument is either missing or not a String" if ( filename.nil? or !filename.kind_of? String )

			g = Gruff::Line.new
			g.title = title unless title.nil?
			data.each_key do |signal|
				g.data( signal, data[signal])
			end
			# boring labels for now
			#data[data.keys[0]].length.times do |i|
			#	g.labels[i] = (i + 1).to_s
			#end
			g.write(filename)
		rescue ArgumentError => e
			puts e.message
		end
	end
	
	## This method returns an html img tag to an image with a graph of the data provided
	## Arguments
	# data:: Hash: Data to be ploted in the form of {"signal_name" => [ value 1, value 2, .., value n] , ...}
	# filename:: String: filname for the image that will be generated. Should have .png extension
	# title:: String: Title for the graph
	# width:: String/Integer: desired width in number of pixels for the image. Defaults to "auto"
	## Returns
	# String: String with the <img> tag to be inserted into an html file
	## Exceptions
	# ArgumentError: Thown when data is either nil or the wrong types
	def insert_html_graph( data, filename = nil , title = nil, width = nil )
		filename = "graph.png" if filename.nil?
		title = "Application Start Performance" if title.nil?
		create_graph_image(data, filename, title)
		html = "\n<img class='graph' src='#{File.basename(filename)}' style='width:#{ width.nil? ? 'auto' : width.to_s + 'px' }'/>\n"
	end	
	
	## This method will create an html table tag with the data provided
	## Arguments
	# data:: Hash: Data to be ploted in the form of {"signal_name" => [ value 1, value 2, .., value n] , ...}
	# width:: String/Integer: desired width in number of pixels for the table. Defaults to "auto"
	## Returns
	# String: String with the <table> tag to be inserted into an html file
	## Exceptions
	#
	def insert_html_table( data, width = nil )
		raise ArgumentError, "Data argument is either nul or not a Hash" if ( data.nil? or data.class.to_s != "Hash" )
		html = "\n<table class='graph' style='width:#{ width.nil? ? 'auto' : width.to_s + 'px' }'>"
		# table headers
		( data[data.keys[0]].length + 1).times do |i|
			html << ( i.zero? ? "\n<td class='tbl_header'>Signal/Event</td>" : "\n<td class='tbl_header'>#{i.to_s}</td>")
		end
		# table data
		data.each_key do |signal|
			html << "\n<tr>\n<td>#{signal}</td>"
				data[signal].each do |value|
					html << "\n<td class='tbl_body'>#{value.to_s}</td>"
				end
			html << "\n</tr>"
		end
		html << "\n</table>\n"
	end

	## This method inserts the graph specific styles
	## Returns
	# String: String with the <stile> tag to be added to an html page including either the graph or the table provided by this module
	def insert_graph_css()
		css = '
			<style>	
			table.graph
			{ text-align: center;
			font-family: Verdana;
			font-weight: normal;
			font-size: 11px;
			color: #404040;
			width: auto;
			background-color: #fafafa;
			border: 1px #6699CC solid;
			border-collapse: collapse;
			border-spacing: 0px; } 

			td.tbl_header
			{ border-bottom: 2px solid #6699CC;
			border-left: 1px solid #6699CC;
			background-color: #BEC8D1;
			text-align: left;
			text-indent: 5px;
			font-family: Verdana;
			font-weight: bold;
			font-size: 11px;
			color: #404040; }

			td.tbl_body
			{ border-bottom: 1px solid #9CF;
			border-top: 0px;
			border-left: 1px solid #9CF;
			border-right: 0px;
			text-align: left;
			text-indent: 10px;
			font-family: Verdana, sans-serif, Arial;
			font-weight: normal;
			font-size: 11px;
			color: #404040;
			background-color: #fafafa; }

			img.graph
			{border: 1px solid #9CF;
			width:auto;
			height:auto}
			</style>
			'
	end
end
