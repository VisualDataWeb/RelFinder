package utils 
{
	import connection.config.Config;
	import connection.config.IConfig;
	import connection.model.ConnectionModel;
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	/**
	 * ...
	 * @author ...
	 */
	public class ConfigUtil
	{
		
		public function ConfigUtil() 
		{
			
		}
		
		public static function setConfigurationFromXML(xml:Object):void {
			
			// set proxy
			ConnectionModel.getInstance().proxy = xml.proxy.url;
			ConnectionModel.getInstance().defaultProxy = xml.proxy.url;
			
			// for old versions
			if (xml.endpoints.defaultEndpoint) {
				ConnectionModel.getInstance().sparqlConfigs.addItem(getConfig(xml.endpoints.defaultEndpoint));
			}
			
			for each (var obj:Object in xml.endpoints.endpoint) {
				ConnectionModel.getInstance().sparqlConfigs.addItem(getConfig(obj));
			}
			
			ConnectionModel.getInstance().sparqlConfig = ConnectionModel.getInstance().sparqlConfigs.getItemAt(0) as IConfig;
			
		}
		
		public static function getConfig(conf:Object):Config {
			
			var config:Config = new Config();
			
			config.name = conf.name;
			config.abbreviation = conf.abbreviation;
			config.description = conf.description;
			config.endpointURI = conf.endpointURI;
			config.defaultGraphURI = conf.defaultGraphURI;
			config.isVirtuoso = (conf.isVirtuoso.toString().toLowerCase() == "true") ? true : false;
			config.useProxy = (conf.useProxy.toString().toLowerCase() == "true") ? true : false;
			
			if (conf.autocompleteURIs != null) {
				if (config.autocompleteURIs == null) {
					config.autocompleteURIs = new ArrayCollection();
				}
				
				if (conf.autocompleteURIs.autocompleteURI is String) {
					config.autocompleteURIs.addItem(conf.autocompleteURIs.autocompleteURI);
				}else {
					for each (var autocomplete:String in conf.autocompleteURIs.autocompleteURI) {
						config.autocompleteURIs.addItem(autocomplete);
					}
				}
				
			}
			
			if (conf.ignoredProperties != null) {
				if (config.ignoredProperties == null) {
					config.ignoredProperties = new ArrayCollection();
				}
				
				if (conf.ignoredProperties.autocompleteURI is String) {
					config.ignoredProperties.addItem(conf.ignoredProperties.ignoredProperty);
				}else {
					for each (var ignoredProperty:String in conf.ignoredProperties.ignoredProperty) {
						config.ignoredProperties.addItem(ignoredProperty);
					}
				}
				
			}
			
			return config;
		}
		
	}

}