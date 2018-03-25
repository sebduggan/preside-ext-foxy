/**
 * @labelField                   transaction_id
 * @dataManagerGroup             Foxy
 * @dataManagerDefaultSortOrder  transaction_id desc
 * @dataManagerGridFields        transaction_id,customer_first_name,customer_last_name,customer_country,transaction_date,order_total
 */

component {
	property name="transaction_id"      type="string"  dbtype="varchar" maxlength=15  required=true;
	property name="transaction_date"    type="date"    dbtype="datetime"              required=true;

	property name="datafeed"            relationship="many-to-one" relatedTo="foxy_datafeed";
	property name="items"               relationship="one-to-many" relatedTo="foxy_transaction_item" relationshipKey="transaction";

	property name="product_total"       type="numeric" dbtype="float"                 required=true;
	property name="shipping_total"      type="numeric" dbtype="float"                 required=true;
	property name="order_total"         type="numeric" dbtype="float"                 required=true;

	property name="payment_gateway"     type="string"  dbtype="varchar" maxlength=30  required=true;
	property name="receipt_url"         type="string"  dbtype="varchar" maxlength=250 required=true;

	property name="customer_id"         type="string"  dbtype="varchar" maxlength=15;
	property name="customer_email"      type="string"  dbtype="varchar" maxlength=250;
	property name="customer_phone"      type="string"  dbtype="varchar" maxlength=50;

	property name="customer_first_name" type="string"  dbtype="varchar" maxlength=100;
	property name="customer_last_name"  type="string"  dbtype="varchar" maxlength=100;
	property name="customer_address1"   type="string"  dbtype="varchar" maxlength=100;
	property name="customer_address2"   type="string"  dbtype="varchar" maxlength=100;
	property name="customer_city"       type="string"  dbtype="varchar" maxlength=100;
	property name="customer_postcode"   type="string"  dbtype="varchar" maxlength=20;
	property name="customer_country"    type="string"  dbtype="char"    maxlength=2;

	property name="shipping_first_name" type="string"  dbtype="varchar" maxlength=100;
	property name="shipping_last_name"  type="string"  dbtype="varchar" maxlength=100;
	property name="shipping_address1"   type="string"  dbtype="varchar" maxlength=100;
	property name="shipping_address2"   type="string"  dbtype="varchar" maxlength=100;
	property name="shipping_city"       type="string"  dbtype="varchar" maxlength=100;
	property name="shipping_postcode"   type="string"  dbtype="varchar" maxlength=20;
	property name="shipping_country"    type="string"  dbtype="char"    maxlength=2;

}