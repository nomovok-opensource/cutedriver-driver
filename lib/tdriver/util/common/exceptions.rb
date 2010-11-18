# place all custom TDriver exception classes here
class MobyStandardError < StandardError

	# Construct a new error, optionally passing in a message
	def initialize ( message = nil )
	  super( message )
	end
	
end

# file not found error
class FileNotFoundError < MobyStandardError; end;
