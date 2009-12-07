package connection.config 
{
	import connection.ILookUp;
	import connection.LookUpSPARQL;
	import flash.events.Event;
	import utils.ConfigUtil;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class Config extends EventDispatcher implements IConfig
	{
		
		private var _endpointURI:String;
		
		private var _abbreviation:String;
		
		private var _defaultGraphURI:String;
		
		private var _isVirtuoso:Boolean = false;
		
		private var _name:String;
		
		private var _description:String;
		
		private var _autocompleteURIs:ArrayCollection;
		
		private var _ignoredProperties:ArrayCollection;
		
		private var _lookUp:ILookUp;
		
		private var _useProxy:Boolean = true;
		
		private var _abstractURIs:ArrayCollection;
		
		private var _imageURIs:ArrayCollection;
		
		private var _linkURIs:ArrayCollection;
		
		private var _maxRelationLength:int = 2;
		
		public function Config(name:String = "", abbreviation:String = "", description:String = "",
					endpointURI:String = "", defaultGraphURI:String = "", isVirtuoso:Boolean = false,
					ignoredProperties:ArrayCollection = null, useProxy:Boolean = true,
					autocompleteURIs:ArrayCollection = null, abstarctURIs:ArrayCollection = null,
					imageURIs:ArrayCollection = null, linkURIs:ArrayCollection = null,
					maxRelationLength:int = 2,
					lookUp:ILookUp = null) {
			
			this.name = (name == null || name == "") ? "New Config" : name;
			this.abbreviation = abbreviation;
			this.description = description;
			this.endpointURI = endpointURI;
			this.defaultGraphURI = defaultGraphURI;
			this.isVirtuoso = isVirtuoso;
			this.ignoredProperties = ignoredProperties;
			this.useProxy = useProxy;
			this.abstractURIs = abstarctURIs;
			this.imageURIs = imageURIs;
			this.linkURIs = linkURIs;
			this.maxRelationLength = maxRelationLength;
			
			this.lookUp = lookUp;
		}
		
		[Bindable(event="endpointURIChange")]
		public function get endpointURI():String {
			return _endpointURI;
		}
		
		public function set endpointURI(value:String):void {
			_endpointURI = value;
			dispatchEvent(new Event("endpointURIChange"));
		}
		
		[Bindable(event="abbreviationChange")]
		public function get abbreviation():String {
			return _abbreviation;
		}
		
		public function set abbreviation(value:String):void {
			_abbreviation = value;
			dispatchEvent(new Event("abbreviationChange"));
		}
		
		[Bindable(event="defaultGraphURIChange")]
		public function get defaultGraphURI():String {
			return _defaultGraphURI;
		}
		
		public function set defaultGraphURI(value:String):void {
			_defaultGraphURI = value;
			dispatchEvent(new Event("defaultGraphURIChange"));
		}
		
		[Bindable(event="isVirtuosoChange")]
		public function get isVirtuoso():Boolean {
			return _isVirtuoso;
		}
		
		public function set isVirtuoso(value:Boolean):void {
			_isVirtuoso = value;
			dispatchEvent(new Event("isVirtuosoChange"));
		}
		
		[Bindable(event="nameChange")]
		public function get name():String {
			return _name;
		}
		
		public function set name(value:String):void {
			_name = value;
			dispatchEvent(new Event("nameChange"));
		}
		
		[Bindable(event="descriptionChange")]
		public function get description():String {
			return _description;
		}
		
		public function set description(value:String):void {
			_description = value;
			dispatchEvent(new Event("descriptionChange"));
		}
		
		[Bindable(event="ignoredPropertiesChange")]
		public function get ignoredProperties():ArrayCollection {
			return _ignoredProperties;
		}
		
		public function set ignoredProperties(value:ArrayCollection):void {
			_ignoredProperties = value;
			dispatchEvent(new Event("ignoredPropertiesChange"));
		}
		
		[Bindable(event="autocompleteURIsChange")]
		public function get autocompleteURIs():ArrayCollection {
			return _autocompleteURIs;
		}
		
		public function set autocompleteURIs(value:ArrayCollection):void {
			_autocompleteURIs = value;
			dispatchEvent(new Event("autocompleteURIsChange"));
		}
		
		[Bindable(event="abstractURIsChange")]
		public function get abstractURIs():ArrayCollection {
			return _abstractURIs;
		}
		
		public function set abstractURIs(value:ArrayCollection):void {
			_abstractURIs = value;
			dispatchEvent(new Event("abstractURIsChange"));
		}
		
		[Bindable(event="imageURIsChange")]
		public function get imageURIs():ArrayCollection {
			return _imageURIs;
		}
		
		public function set imageURIs(value:ArrayCollection):void {
			_imageURIs = value;
			dispatchEvent(new Event("imageURIsChange"));
		}
		
		[Bindable(event="linkURIsChange")]
		public function get linkURIs():ArrayCollection {
			return _linkURIs;
		}
		
		public function set linkURIs(value:ArrayCollection):void {
			_linkURIs = value;
			dispatchEvent(new Event("linkURIsChange"));
		}
		
		[Bindable(event="maxRelationLengthChange")]
		public function get maxRelationLength():int {
			return _maxRelationLength;
		}
		
		public function set maxRelationLength(value:int):void {
			_maxRelationLength = value;
			dispatchEvent(new Event("maxRelationLengthChange"));
		}
		
		[Bindable(event="lookUpChange")]
		public function get lookUp():ILookUp{
			if (_lookUp == null){
				_lookUp = new LookUpSPARQL();
			}
			return _lookUp;
		}
		
		public function set lookUp(value:ILookUp):void {
			_lookUp = value;
			dispatchEvent(new Event("lookUpChange"));
		}
		
		[Bindable(event="useProxyChange")]
		public function get useProxy():Boolean {
			return _useProxy;
		}
		
		public function set useProxy(value:Boolean):void {
			_useProxy = value;
			dispatchEvent(new Event("useProxyChange"));
		}
		
		public function equals(config:IConfig):Boolean {
			return (ConfigUtil.compare(this, config) == 0);
		}
		
		override public function toString():String {
			return "Name: " + name + "\n" +
					"Description: " + description  + "\n" +
					"EndpointURI: " + endpointURI  + "\n" +
					"DefaultGraphURI: " + defaultGraphURI  + "\n" +
					"IsVirtuoso: " + isVirtuoso + "\n" +
					"UseProxy: " + useProxy + "\n" +
					"AutocompleteURIs: " + ((autocompleteURIs == null) ? "null" : autocompleteURIs.toArray() + " #" + autocompleteURIs.length) + "\n" +
					"IgnoredProperties: " + ((ignoredProperties == null) ? "null" : ignoredProperties.toArray() + " #" + ignoredProperties.length) + "\n" +
					"AbstarctURIs: " + ((abstractURIs == null) ? "null" : abstractURIs.toArray() + " #" + abstractURIs.length) + "\n" +
					"ImageURI: " + ((imageURIs == null) ? "null" : imageURIs.toArray() + " #" + imageURIs.length) + "\n" +
					"LinkURI: " + ((linkURIs == null) ? "null" : linkURIs.toArray() + " #" + linkURIs.length) + "\n" +
					"MaxRelationLenght: " + maxRelationLength;
		}
	}
	
}