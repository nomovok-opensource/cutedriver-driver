// include the Ruby headers
#include "ruby.h"

static const CRC_16[ 16 ] = {
 
      0x0000, 0x1081, 0x2102, 0x3183,	
			0x4204, 0x5285, 0x6306, 0x7387,
			0x8408, 0x9489, 0xa50a, 0xb58b,	
			0xc60c, 0xd68d, 0xe70e, 0xf78f

};

static VALUE crc16_ibm( VALUE self, VALUE string ) {
  
  const char* data = RSTRING_PTR( string );
  
  int len = RSTRING_LEN( string );
    
  int crc = 0xffff;

  int c = 0;

  while( len-- != 0 ){

    c = *data++;

		crc = ( ( crc >> 4 ) & 0x0fff ) ^ CRC_16[ ( ( crc ^ c ) & 15 ) ];

		crc = ( ( crc >> 4 ) & 0x0fff ) ^ CRC_16[ ( ( crc ^ ( c >> 4 )) & 15 ) ];
  }


	return INT2FIX( ~crc & 0xffff );

}

void Init_native_extensions() {

	VALUE mTDriver = rb_define_module( "TDriver" );

	VALUE mNativeExtensions = rb_define_module_under( mTDriver, "NativeExtensions" );

	VALUE mCRC = rb_define_module_under( mNativeExtensions, "CRC" );

	rb_define_singleton_method( mCRC, "crc16_ibm", crc16_ibm, 1 );

}
