/**
 * @singleton
 * @presideservice
 *
 */
component {

	public any function init() {
		return this;
	}

// PUBLIC API METHODS
	public void function processTransaction( required string payload ) {
		var transaction = deserializeJSON( arguments.payload );
		var dao         = $getPresideObject( "foxy_transaction" );
		var itemDao     = $getPresideObject( "foxy_transaction_item" );
		var data        = {};
		var itemData    = {};

		if ( dao.dataExists( filter={ transaction_id=transaction.id } ) ) {
			return;
		}

		$announceInterception( "preFoxyProcessTransaction" , { transaction=transaction } );

		var billing  = transaction._embedded[ "fx:billing_addresses" ][ 1 ] ?: {};
		var shipping = transaction._embedded[ "fx:shipments"         ][ 1 ] ?: {};
		var payment  = transaction._embedded[ "fx:payments"          ][ 1 ] ?: {};
		var items    = transaction._embedded[ "fx:items" ]                  ?: [];

		data = {
			  payload             = arguments.payload
			, transaction_id      = transaction.id                   ?: ""
			, transaction_date    = transaction.transaction_date     ?: ""
			, product_total       = transaction.total_item_price     ?: 0
			, shipping_total      = transaction.total_shipping       ?: 0
			, order_total         = transaction.total_order          ?: 0
			, payment_gateway     = payment.gateway_type             ?: ""
			, receipt_url         = transaction.receipt_url          ?: ""
			, customer_id         = transaction.customer.id          ?: ""
			, customer_email      = transaction.customer_email       ?: ""
			, customer_first_name = transaction.customer_first_name  ?: ""
			, customer_last_name  = transaction.customer_last_name   ?: ""
			, customer_phone      = billing.customer_phone           ?: ""
			, customer_address1   = billing.address1                 ?: ""
			, customer_address2   = billing.address2                 ?: ""
			, customer_city       = billing.city                     ?: ""
			, customer_region     = billing.region                   ?: ""
			, customer_postcode   = billing.customer_postal_code     ?: ""
			, customer_country    = billing.customer_country         ?: ""
			, shipping_first_name = shipping.first_name              ?: ""
			, shipping_last_name  = shipping.last_name               ?: ""
			, shipping_address1   = shipping.address1                ?: ""
			, shipping_address2   = shipping.address2                ?: ""
			, shipping_city       = shipping.city                    ?: ""
			, shipping_region     = shipping.region                  ?: ""
			, shipping_postcode   = shipping.postal_code             ?: ""
			, shipping_country    = shipping.country                 ?: ""
		};
		$announceInterception( "preFoxyInsertTransaction", { transaction=transaction, data=data } );
		var transactionId = dao.insertData( data );

		for( var item in items ) {
			itemData = {
				  code        = item.code     ?: ""
				, quantity    = item.quantity ?: 0
				, price       = item.price    ?: 0
				, transaction = transactionId
				, product     = _getProductIdFromCode( item.code ?: "" )
			};
			$announceInterception( "preFoxyInsertTransactionItem", { transaction=transaction, data=itemData } );
			itemDao.insertData( itemData );
		}

		$announceInterception( "postFoxyProcessTransaction", { transaction=transaction } );
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

}