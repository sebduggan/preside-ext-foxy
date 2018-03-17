<cfscript>
	product        = args.product        ?: {};
	buttonLabel    = args.button_label   ?: "Add to basket";
	description    = args.description    ?: "";
	showImage      = isTrue( args.show_image ?: "" );
	discountPrice  = args.discount_price ?: "";
	discountLabel  = args.discount_label ?: "";
	discountStrap  = args.discount_strap ?: "";
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

			<input type="hidden" name="name||#product.hmac.name#" value="#product.name#">
			<input type="hidden" name="price||#product.hmac.price#" value="#product.price#">
			<cfif len( product.discount ?: "" )>
				<input type="hidden" name="discount_price_amount||#product.hmac.discount#" value="#product.discount#">
			</cfif>
			<input type="hidden" name="code||#product.hmac.code#" value="#product.code#">
			<input type="hidden" name="image||#product.hmac.image#" value="#product.image#">
			<input type="hidden" name="url||#product.hmac.url#" value="#product.url#">

			<cfif showImage>
				<img src="#displayImageSmall#" srcset="#displayImageSmall# 200w, #displayImageLarge# 400w" width="200">
			</cfif>

			<cfif len( discountStrap )>
				<p class="foxy-discount-strap"><strong>#discountStrap#</strong></p>
			</cfif>
			<cfif isNumeric( discountPrice )>
				<p class="foxy-rsp">
					<del>#currencySymbol##decimalFormat( product.price )#</del>
					<cfif len( discountLabel )>
						<br>
						<strong>#discountLabel#</strong>
					</cfif>
				</p>
			</cfif>
			<h3 itemprop="offers" itemscope itemtype="http://schema.org/Offer">
				#currencySymbol#<span itemprop="price">#decimalformat( isNumeric( discountPrice ) ? discountPrice : product.price )#</span>
				<meta itemprop="priceCurrency" content="#currencyCode#">
			</h3>

			<p class="foxy-action">
				<input type="submit" value="#buttonLabel#" class="foxy-cart-submit">
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
		</form>
	</div>
</cfoutput>