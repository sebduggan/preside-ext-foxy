component {

	property name="presideObjectService"  inject="presideObjectService";
	property name="foxyService"           inject="foxyService";

	private function index( event, rc, prc, args={} ) {
		var settings     = foxyService.getFoxySettings();
		var productQuery = presideObjectService.selectData(
			  objectName = "foxy_product"
			, id         = args.foxy_product
		);

		for( var product in productQuery ) {
			product.code    = product.sku;
			product.imageId = product.image;
			product.image   = event.buildLink( assetId=product.imageId, derivative="foxySquare" );
			product.url     = event.getSiteUrl() & event.getCurrentUrl( false );
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

		return renderView( view='widgets/foxy_product_form/index', args=args );
	}

	private function placeholder( event, rc, prc, args={} ) {
		args.productName = renderLabel( "foxy_product", args.foxy_product );
		return renderView( view='widgets/foxy_product_form/placeholder', args=args );
	}
}
