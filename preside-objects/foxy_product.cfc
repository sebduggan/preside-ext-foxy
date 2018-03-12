/**
 * @dataManagerGridFields  sku,brand,name,price
 */

component dataManagerGroup="Foxy" {
	property name="label"    type="text" formula="concat( ${prefix}brand, ' ', ${prefix}name, ' (', format( ${prefix}price, 2 ), ')' )" required=false;
	property name="brand"    type="text"    dbtype="varchar" maxlength=50  required=true;
	property name="name"     type="text"    dbtype="varchar" maxlength=50  required=true;
	property name="category" type="text"    dbtype="varchar" maxlength=100 required=false;
	property name="sku"      type="text"    dbtype="varchar" maxlength=20  required=true;
	property name="price"    type="numeric" dbtype="float"                 required=true;
	property name="image"    relationship="many-to-one" relatedTo="asset" allowedTypes="image" required=true;

}