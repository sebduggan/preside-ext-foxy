/**
 * @singleton
 * @presideservice
 *
 *******************************************************************
 * ColdFusion RC4 Component
 *
 * Written by Steve Hicks (steve@aquafusionmedia.com)
 * http://www.aquafusionmedia.com
 *
 * Version 1.0 - Released: April 24, 2012
 *
 * Version 1.1 - Modified by Seb Duggan (seb@sebduggan.com)
 *   Added arguments to allow input and output not to be Hex values
 *   Released: May 3, 2016
 *
 * Version 1.2 - Modified by Seb Duggan (seb@sebduggan.com)
 *   Converted to script component, integrated into Preside extension
 *   Released: Febraury 26, 2018
 *******************************************************************
 */
component {

	public any function init() {
		return this;
	}

// PUBLIC API METHODS

	// Decrypt a String (src) using the Key (key)
	public string function rc4Decrypt(
		  required string  src
		, required string  key
	) {
		var mtxt   = _strToChars( arguments.src );
		var mkey   = _strToChars( arguments.key );
		var result = _rc4Calculate( mtxt, mkey );

		return _charsToStr( result );
	}


// PRIVATE METHODS

	// Set Up the Component Ready for Encryption
	private array function _rc4Initialize( required array pwd ) {
		var sbox      = [];
		var mykey     = [];
		var a         = 0;
		var b         = 0;
		var tempSwap  = "";
		var intLength = arguments.pwd.len();

		for( a=0; a<=255; a++ ) {
			mykey[ a+1 ] = arguments.pwd[ ( a mod intLength ) + 1 ];
			sbox[  a+1 ] = a;
		}
		for( a=0; a<=255; a++ ) {
			b           = ( b + sbox[ a+1 ] + mykey[ a+1 ] ) mod 256;
			tempSwap    = sbox[ a+1 ];
			sbox[ a+1 ] = sbox[ b+1 ];
			sbox[ b+1 ] = tempSwap;
		}

		return sbox;
	}

	// Calculate the Cipher
	private array function _rc4Calculate(
		  required array plaintext
		, required array psw
	) {
		var sbox     = _rc4Initialize( arguments.psw );
		var a        = 0;
		var i        = 0;
		var j        = 0;
		var k        = "";
		var cipher   = [];
		var cipherby = 0;
		var temp     = "";

		for( a=1; a<=plaintext.len(); a++ ) {
			i           = ( i+1 ) mod 256;
			j           = ( j + sbox[ i+1 ] ) mod 256;
			temp        = sbox[ i+1 ];
			sbox[ i+1 ] = sbox[ j+1 ];
			sbox[ j+1 ] = temp;
			k           = sbox[ ( ( sbox[ i+1 ] + sbox[ j+1 ] ) mod 256 ) + 1 ];
			cipherby    = bitXor( arguments.plaintext[ a ], k );
			cipher.append( cipherby );
		}
		return cipher;
	}

	// Convert an Array of Characters into a String
	private string function _charsToStr( required array chars ) {
		var result = "";
		for( var i=1; i<=arguments.chars.len(); i++ ) {
			result &= chr( arguments.chars[ i ] );
		}
		return result;
	}

	// Convert a String into an Array of Characters
	private array function _strToChars( required string str ) {
		var codes = [];

		for( var i=1; i<=len( arguments.str ); i++ ) {
			codes[ i ] = asc( mid( arguments.str, i, 1) );
		}
		return codes;
	}


}