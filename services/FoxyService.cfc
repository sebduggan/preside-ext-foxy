/**
 * @singleton
 * @presideservice
 *
 */
component {

	/**
	 * @foxyRC4.inject        foxyRC4
	 */
	public any function init( required any foxyRC4 ) {
		_setFoxyRC4( arguments.foxyRC4 );

		return this;
	}

// PUBLIC API METHODS
	public struct function processDatafeed( required string feedData ) {
		var settings  = getFoxySettings();
		var decoded   = urlDecode( arguments.feedData, "iso-8859-1" );
		var xmlText   = _getFoxyRC4().rc4Decrypt( src=decoded, key=settings.api_key );
		var xmlHash   = hash( xmlText );
		var xmlParsed = xmlParse( xmlText );
		var foxyData  = _xmlToStruct( xmlParsed ).foxyData;
		var exists    = $getPresideObject( "foxy_datafeed" ).dataExists( filter={ xml_hash=xmlHash } );

		if ( !exists ) {
			$getPresideObject( "foxy_datafeed" ).insertData( {
				  raw_xml  = xmlText
				, xml_hash = xmlHash
				, json     = serializeJSON( foxyData )
			} );
		}

		return foxyData;
	}

	public string function hmacEncode( required string sku, required string name, required string value ) {
		var settings     = getFoxySettings();
		var stringToHash = arguments.sku & arguments.name & arguments.value;
		var hashedString = hmac( stringToHash, settings.api_key, "HMACSHA256" );

		return lcase( hashedString );
	}

	public query function getShippingRates( string id="" ) {
		var filter = {};
		if ( arguments.id.len() ) {
			filter.id = listToArray( arguments.id );
		}

		return $getPresideObject( "foxy_shipping" ).selectData(
			  filter  = filter
			, orderBy = "sortorder"
		);
	}

	public string function getFormAction() {
		var settings = getFoxySettings();
		return "https://#settings.sub_domain#.foxycart.com/cart"
	}

	public void function includeLoaderJs( required any event ) {
		var settings = getFoxySettings();
		var script   =  "//cdn.foxycart.com/#settings.sub_domain#/loader.js";

		arguments.event.includeUrl( url=script, async="async", defer="defer" );
	}

	public struct function getFoxySettings() {
		return $getPresideCategorySettings( category="foxy" );
	}


// PRIVATE METHODS
	private any function _xmlToStruct( required xml xml ) {
		var s = {};

		if ( xmlGetNodeType( xml ) == "DOCUMENT_NODE" ) {
			s[ structKeyList( xml ) ] = _xmlToStruct( xml[ structKeyList( xml ) ] );
			return s;
		}

		if ( xml.keyExists( "xmlAttributes" ) && !xml.xmlAttributes.isEmpty() ) {
			s.attributes = {};
			for( var item in xml.xmlAttributes ) {
				s.attributes[ item ] = xml.xmlAttributes[ item ];
			}
		}

		if( xml.keyExists( "xmlText" ) && len( trim( xml.xmlText ) ) ) {
			s.value = xml.xmlText;
		}

		if( xml.keyExists( "xmlChildren" ) && xml.xmlChildren.len() ) {
			for( var i=1; i<=xml.xmlChildren.len(); i++ ) {

				if ( s.keyExists( xml.xmlchildren[ i ].xmlname ) ) {
					if ( !isArray( s[ xml.xmlChildren[ i ].xmlname ] ) ) {
						var temp = s[ xml.xmlchildren[ i ].xmlname ];
						s[ xml.xmlchildren[ i ].xmlname ] = [ temp ];
					}
					s[ xml.xmlchildren[ i ].xmlname ].append( _xmlToStruct( xml.xmlChildren[ i ] ) );
				} else {
					if ( xml.xmlChildren[i].keyExists( "xmlChildren" ) && xml.xmlChildren[ i ].xmlChildren.len() ) {
						if ( xml.xmlChildren.len() == 1 ) {
							s = [ _xmlToStruct( xml.xmlChildren[ i ] ) ];
						} else {
							s[ xml.xmlChildren[ i ].xmlName ] = _xmlToStruct( xml.xmlChildren[ i ] );
						}
					} else if ( xml.xmlChildren[i].keyExists( "xmlAttributes" ) && !xml.xmlChildren[ i ].xmlAttributes.isEmpty() ) {
						s[ xml.xmlChildren[ i ].xmlName ] = _xmlToStruct( xml.xmlChildren[ i ] );
					} else {
						s[ xml.xmlChildren[ i ].xmlName ] = xml.xmlChildren[ i ].xmlText;
					}
				}
			}
		}

		return s;
	}


// GETTERS & SETTERS
	private any function _getFoxyRC4() {
		return _foxyRC4;
	}
	private void function _setFoxyRC4( required any foxyRC4 ) {
		_foxyRC4 = arguments.foxyRC4;
	}

}