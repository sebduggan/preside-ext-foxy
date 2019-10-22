<cfscript>
	product        = args.product        ?: {};
	buttonLabel    = len( args.button_label ?: "" ) ? args.button_label : "Add to basket";
	description    = args.description    ?: "";
	outOfStock     = isTrue( args.out_of_stock ?: "" );
	showImage      = isTrue( args.show_image   ?: "" );
	discountPrice  = args.discount_price ?: "";
	discountLabel  = args.discount_label ?: "";
	discountStrap  = args.discount_strap ?: "";
	displayPrice   = args.display_price  ?: "";
	couponLabel    = args.coupon_label   ?: "";
	coupon         = args.coupon         ?: "";
	formAction     = args.formAction     ?: "";
	currencyCode   = args.currencyCode   ?: "";
	currencySymbol = args.currencySymbol ?: "";
	shippingRates  = args.shippingRates  ?: queryNew("");

	if ( showImage ) {
		displayImageSmall = event.buildLink( assetId=product.imageId, derivative="foxyFormDisplay200" );
		displayImageLarge = event.buildLink( assetId=product.imageId, derivative="foxyFormDisplay400" );
	}
</cfscript>

<cfoutput>
	<div itemscope itemtype="http://schema.org/Product" class="foxy-product-form">
		<cfif len( description )>
			<div class="foxy-description">
				#renderContent( renderer="richeditor", data=description )#
			</div>
		</cfif>

		<form action="#formAction#" method="post" accept-charset="utf-8">
			<meta itemprop="brand" content="#product.brand#">
			<meta itemprop="name" content="#product.name#">
			<cfif product.category.len()><meta itemprop="category" content="#product.category#"></cfif>
			<meta itemprop="identifier" content="sku:#product.sku#">
			<meta itemprop="image" content="#product.image#">

			<cfif !outOfStock>
				<input type="hidden" name="name||#product.hmac.name#" value="#product.name#">
				<input type="hidden" name="price||#product.hmac.price#" value="#product.price#">
				<cfif len( product.discount ?: "" )>
					<input type="hidden" name="discount_price_amount||#product.hmac.discount#" value="#product.discount#">
				</cfif>
				<input type="hidden" name="code||#product.hmac.code#" value="#product.code#">
				<input type="hidden" name="image||#product.hmac.image#" value="#product.image#">
				<input type="hidden" name="url||#product.hmac.url#" value="#product.url#">
				<cfif len( coupon )>
					<input type="hidden" name="coupon" value="#coupon#">
				</cfif>
			</cfif>

			<cfif showImage>
				<img src="#displayImageSmall#" srcset="#displayImageSmall# 200w, #displayImageLarge# 400w" width="200">
			</cfif>

			<cfif len( discountStrap )>
				<p class="foxy-discount-strap"><strong>#discountStrap#</strong></p>
			</cfif>
			<cfif isNumeric( discountPrice ) or isNumeric( displayPrice )>
				<p class="foxy-rsp">
					<del>#currencySymbol##decimalFormat( product.price )#</del>
					<cfif len( discountLabel )>
						<br>
						<strong>#discountLabel#</strong>
					</cfif>
					<cfif len( couponLabel )>
						<br>
						<strong>#couponLabel#</strong>
					</cfif>
				</p>
			</cfif>
			<h3 itemprop="offers" itemscope itemtype="http://schema.org/Offer">
				#currencySymbol#<span>#decimalformat( isNumeric( displayPrice ) ? displayPrice : ( isNumeric( discountPrice ) ? discountPrice : product.price ) )#</span>
				<meta itemprop="price" content="#decimalformat( isNumeric( discountPrice ) ? discountPrice : product.price )#">
				<meta itemprop="priceCurrency" content="#currencyCode#">
			</h3>

			<cfif outOfStock>
				<h4>Out of stock</h4>
			<cfelse>
				<p class="foxy-action">
					<button type="submit" class="foxy-cart-submit">#buttonLabel#</button>
				</p>

				<cfif shippingRates.recordCount>
					<p class="foxy-shipping">
						<strong>Postage</strong><br />
						<cfloop query="shippingRates">
							#shippingRates.label#:
							<cfif shippingRates.price eq 0>
								FREE
							<cfelse>
								#currencySymbol##decimalFormat( shippingRates.price )#
							</cfif>
							<br />
						</cfloop>
					</p>
				</cfif>
			</cfif>
		</form>
	</div>
</cfoutput>