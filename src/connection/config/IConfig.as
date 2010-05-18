package connection.config 
{
	import connection.ILookUp;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public interface IConfig 
	{
		[Bindable(event="endpointURIChange")]
		function get endpointURI():String;
		
		function set endpointURI(value:String):void;
		
		[Bindable(event="abbreviationURIChange")]
		function get abbreviation():String;
		
		function set abbreviation(value:String):void;
		
		[Bindable(event="defaultGraphURIChange")]
		function get defaultGraphURI():String;
		
		function set defaultGraphURI(value:String):void;
		
		[Bindable(event="isVirtuosoChange")]
		function get isVirtuoso():Boolean;
		
		function set isVirtuoso(value:Boolean):void;
		
		[Bindable(event="nameChange")]
		function get name():String;
		
		function set name(value:String):void;
		
		[Bindable(event="descriptionChange")]
		function get description():String;
		
		function set description(value:String):void;
		
		[Bindable(event="autocompleteURIsChange")]
		function get autocompleteURIs():ArrayCollection;
		
		function set autocompleteURIs(value:ArrayCollection):void;
		
		[Bindable(event="ignoredPropertiesChange")]
		function get ignoredProperties():ArrayCollection;
		
		function set ignoredProperties(value:ArrayCollection):void;
		
		[Bindable(event="lookUpChange")]
		function get lookUp():ILookUp;
		
		function set lookUp(value:ILookUp):void;
		
		[Bindable(event="useProxyChange")]
		function get useProxy():Boolean;
		
		function set useProxy(value:Boolean):void;
		
		[Bindable(event="abstractURIsChange")]
		function get abstractURIs():ArrayCollection;
		
		function set abstractURIs(value:ArrayCollection):void;
		
		[Bindable(event="imageURIsChange")]
		function get imageURIs():ArrayCollection;
		
		function set imageURIs(value:ArrayCollection):void;
		
		[Bindable(event="linkURIsChange")]
		function get linkURIs():ArrayCollection;
		
		function set linkURIs(value:ArrayCollection):void;
		
		//[Bindable(event="minRelationLengthChange")]
		//function get minRelationLength():int;
		//
		//function set minRelationLength(value:int):void
		
		[Bindable(event="maxRelationLengthChange")]
		function get maxRelationLength():int;
		
		function set maxRelationLength(value:int):void
		
		[Bindable(event="dontAppendSPARQLChange")]
		function get dontAppendSPARQL():Boolean;
		
		function set dontAppendSPARQL(value:Boolean):void;
		
		[Bindable(event="methodChange")]
		function get method():String;
		
		function set method(value:String):void;
		
		[Bindable(event="autocompleteLanguageChange")]
		function get autocompleteLanguage():String;
		
		function set autocompleteLanguage(value:String):void;
		
		function equals(value:IConfig):Boolean
	}
	
}