component {

	property name="presideObjectService" inject="presideObjectService";
	property name="foxyService"          inject="foxyService";

	public string function datafeed( event, rc, prc, args={} ) {
		var datafeed = rc.FoxyData ?: "";

		try {
			var foxyData     = foxyService.processDatafeed( datafeed );
			var transactions = foxyData.transactions ?: [];

			foxyService.processTransactions( transactions );
			event.renderData( type="text", data="foxy" );
		}
		catch( any e ) {
			var message = e.message.len() ? e.message : e.detail;
			event.renderData( type="text", data="Error: " & message );
		}
	}

	private string function _renderForm( event, rc, prc, args={} ) {
		var settings     = foxyService.getFoxySettings();
		var productQuery = presideObjectService.selectData(
			  objectName = "foxy_product"
			, id         = args.foxy_product
		);

		for( var product in productQuery ) {
			product.code    = product.sku;
			product.imageId = product.image;
			product.image   = event.buildLink( assetId=product.imageId, derivative="foxySquare" );
			product.url     = product.product_page.len() ? event.buildLink( page=product.product_page ) : event.getSiteUrl() & event.getCurrentUrl( false );
			product.hmac    = {
				  name  = foxyService.hmacEncode( product.sku, "name" , product.name  )
				, code  = foxyService.hmacEncode( product.sku, "code" , product.code  )
				, price = foxyService.hmacEncode( product.sku, "price", product.price )
				, image = foxyService.hmacEncode( product.sku, "image", product.image )
				, url   = foxyService.hmacEncode( product.sku, "url"  , product.url   )
			};

			var discountPrice = args.discount_price ?: "";
			var discountCode  = args.discount_code  ?: "Discount";
			if ( isNumeric( discountPrice ) ) {
				product.discount      = "#discountCode#{all-units|0-#product.price - discountPrice#}";
				product.hmac.discount = foxyService.hmacEncode( product.sku, "discount_price_amount", product.discount );
			}
			break;
		}

		args.product        = product;
		args.formAction     = foxyService.getFormAction();
		args.currencyCode   = settings.currency_code;
		args.currencySymbol = settings.currency_symbol;
		args.shippingRates  = foxyService.getShippingRates( args.foxy_shipping ?: "" );

		foxyService.includeLoaderJs( event );

		return renderView( view='/foxy/_renderForm', args=args );
	}

}
