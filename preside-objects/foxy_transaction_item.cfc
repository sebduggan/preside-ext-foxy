/**
 * @noLabel
 * @dataManagerGroup  Foxy
 */

component {
	property name="code"        type="string"  dbtype="varchar" maxlength=50 required=true;
	property name="quantity"    type="numeric" dbtype="int"                  required=true;
	property name="price"       type="numeric" dbtype="float"                required=true;

	property name="transaction" relationship="many-to-one" relatedTo="foxy_transaction" ondelete="cascade";
	property name="product"     relationship="many-to-one" relatedTo="foxy_product";

}