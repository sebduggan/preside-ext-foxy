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
		var existing  = $getPresideObject( "foxy_datafeed" ).selectData( filter={ xml_hash=xmlHash }, selectFields=[ "id" ] );

		if ( !existing.recordcount ) {
			foxyData.datafeedId = $getPresideObject( "foxy_datafeed" ).insertData( {
				  raw_xml  = xmlText
				, xml_hash = xmlHash
				, json     = serializeJSON( foxyData )
			} );
		} else {
			foxyData.datafeedId = existing.id;
		}

		return foxyData;
	}

	public void function processTransactions( required array transactions, required string datafeedId ) {
		transaction {
			for( var transaction in arguments.transactions ) {
				$announceInterception( "preFoxyProcessTransaction" , { transaction=transaction, datafeedId=arguments.datafeedId } );
				processTransaction( transaction, arguments.datafeedId );
				$announceInterception( "postFoxyProcessTransaction", { transaction=transaction, datafeedId=arguments.datafeedId } );
			}
		}
	}

	public void function processTransaction( required struct transaction, required string datafeedId ) {
		var dao      = $getPresideObject( "foxy_transaction" );
		var itemDao  = $getPresideObject( "foxy_transaction_item" );
		var data     = {};
		var itemData = {};

		if ( dao.dataExists( filter={ transaction_id=arguments.transaction.id } ) ) {
			return;
		}

		data = {
			  datafeed            = arguments.datafeedId
			, transaction_id      = arguments.transaction.id                   ?: ""
			, transaction_date    = arguments.transaction.transaction_date     ?: ""
			, product_total       = arguments.transaction.product_total        ?: 0
			, shipping_total      = arguments.transaction.shipping_total       ?: 0
			, order_total         = arguments.transaction.order_total          ?: 0
			, payment_gateway     = arguments.transaction.payment_gateway_type ?: ""
			, receipt_url         = arguments.transaction.receipt_url          ?: ""
			, customer_id         = arguments.transaction.customer_id          ?: ""
			, customer_email      = arguments.transaction.customer_email       ?: ""
			, customer_phone      = arguments.transaction.customer_phone       ?: ""
			, customer_first_name = arguments.transaction.customer_first_name  ?: ""
			, customer_last_name  = arguments.transaction.customer_last_name   ?: ""
			, customer_address1   = arguments.transaction.customer_address1    ?: ""
			, customer_address2   = arguments.transaction.customer_address2    ?: ""
			, customer_city       = arguments.transaction.customer_city        ?: ""
			, customer_postcode   = arguments.transaction.customer_postal_code ?: ""
			, customer_country    = arguments.transaction.customer_country     ?: ""
			, shipping_first_name = arguments.transaction.shipping_first_name  ?: ""
			, shipping_last_name  = arguments.transaction.shipping_last_name   ?: ""
			, shipping_address1   = arguments.transaction.shipping_address1    ?: ""
			, shipping_address2   = arguments.transaction.shipping_address2    ?: ""
			, shipping_city       = arguments.transaction.shipping_city        ?: ""
			, shipping_postcode   = arguments.transaction.shipping_postal_code ?: ""
			, shipping_country    = arguments.transaction.shipping_country     ?: ""
		};
		$announceInterception( "preFoxyInsertTransaction", { data=data } );
		var transactionId = dao.insertData( data );

		for( var item in transaction.transaction_details ) {
			itemData = {
				  code        = item.product_code     ?: ""
				, quantity    = item.product_quantity ?: 0
				, price       = item.product_price    ?: 0
				, transaction = transactionId
				, product     = _getProductIdFromCode( item.product_code ?: "" )
			};
			$announceInterception( "preFoxyInsertTransactionItem", { data=itemData } );
			itemDao.insertData( itemData );
		}
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
	private string function _getProductIdFromCode( required string code ) {
		var product = $getPresideObject( "foxy_product" ).selectData( filter={ sku=arguments.code }, selectFields=[ "id" ] );
		return product.id;
	}

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