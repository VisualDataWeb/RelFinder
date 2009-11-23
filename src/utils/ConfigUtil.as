package utils 
{
	import com.dynamicflash.util.Base64;
	import connection.config.Config;
	import connection.config.IConfig;
	import connection.model.ConnectionModel;
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	/**
	 * ...
	 * @author ...
	 */
	public class ConfigUtil
	{
		public static function toURLParameters(url:String, lastInputs:Array, config:IConfig):String {
			
			var data:String = "";
			
			data += url + "?";
			
			for (var a:int = 0; a < lastInputs.length; a++) {
				data += "obj" + (a + 1) + "=" + encodeObjectParameter(lastInputs[a].label, lastInputs[a].uri);
				if (a + 1 < lastInputs.length) {
					data += "&";
				}
			}
			
			if (config.name != null && config.name != "") {
				data += "&name=" + Base64.encode(config.name);
			}
			if (config.description != null && config.description != "") {
				data += "&description=" + Base64.encode(config.description);
			}
			if (config.endpointURI != null && config.endpointURI != "") {
				data += "&endpointURI=" + Base64.encode(config.endpointURI);
			}
			if (config.defaultGraphURI != null && config.defaultGraphURI != "") {
				data += "&defaultGraphURI=" + Base64.encode(config.defaultGraphURI);
			}
			data += "&isVirtuoso=" + Base64.encode(config.isVirtuoso.toString()) +
				"&useProxy=" + Base64.encode(config.useProxy.toString());

			if (config.autocompleteURIs != null && config.autocompleteURIs.length > 0) {
				
				var acuri:String = "";
				
				for (var i:int = 0; i < config.autocompleteURIs.length; i++) {
					acuri += config.autocompleteURIs.getItemAt(i);
					if (i < config.autocompleteURIs.length - 1) {
						acuri += ",";
					}
				}
				data += "&autocompleteURIs=" + Base64.encode(acuri);
			}
			
			if (config.ignoredProperties != null && config.ignoredProperties.length > 0) {
				
				var ipuri:String = "";
				
				for (var j:int = 0; j < config.ignoredProperties.length; j++) {
					ipuri += config.ignoredProperties.getItemAt(j);
					if (j < config.ignoredProperties.length - 1) {
						ipuri += ",";
					}
				}
				data += "&ignoredProperties=" + Base64.encode(ipuri);
			}
			
			return data;
		}
		
		public static function encodeObjectParameter(label:String, url:String):String {
			return Base64.encode(label + "|" + url);
		}
		
		public static function setConfigurationFromXML(xml:Object):void {
			
			// set proxy
			ConnectionModel.getInstance().proxy = xml.proxy.url;
			ConnectionModel.getInstance().defaultProxy = xml.proxy.url;
			
			// for old versions
			if (xml.endpoints.defaultEndpoint.toString() != "") {
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
			
			if (conf.autocompleteURIs != undefined) {
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
			
			if (conf.ignoredProperties != undefined) {
				if (config.ignoredProperties == null) {
					config.ignoredProperties = new ArrayCollection();
				}
				
				if (conf.ignoredProperties.ignoredProperty is String) {
					config.ignoredProperties.addItem(conf.ignoredProperties.ignoredProperty);
				}else {
					for each (var ignoredProperty:String in conf.ignoredProperties.ignoredProperty) {
						config.ignoredProperties.addItem(ignoredProperty);
					}
				}
			}
			
			if (conf.abstractURIs != undefined) {
				if (config.abstractURIs == null) {
					config.abstractURIs = new ArrayCollection();
				}
				
				if (conf.abstractURIs.abstractURI is String) {
					config.abstractURIs.addItem(conf.abstractURIs.abstractURI);
				}else {
					for each (var abstractURI:String in conf.abstractURIs.abstractURI) {
						config.abstractURIs.addItem(abstractURI);
					}
				}
			}
			
			if (conf.imageURIs != undefined) {
				if (config.imageURIs == null) {
					config.imageURIs = new ArrayCollection();
				}
				
				if (conf.imageURIs.imageURI is String) {
					config.imageURIs.addItem(conf.imageURIs.imageURI);
				}else {
					for each (var imageURI:String in conf.imageURIs.imageURI) {
						config.imageURIs.addItem(imageURI);
					}
				}
			}
			
			if (conf.linkURIs != undefined) {
				if (config.linkURIs == null) {
					config.linkURIs = new ArrayCollection();
				}
				
				if (conf.linkURIs.linkURI is String) {
					config.linkURIs.addItem(conf.linkURIs.linkURI);
				}else {
					for each (var linkURI:String in conf.linkURIs.linkURI) {
						config.linkURIs.addItem(linkURI);
					}
				}
			}
			
			//if (conf.minRelationLength != undefined) {
				//config.minRelationLength = conf.minRelationLength;
			//}
			
			if (conf.maxRelationLength != undefined) {
				config.maxRelationLength = conf.maxRelationLength;
			}
			
			return config;
		}
		
		public static function getXMLfromConfiguration(proxy:String = null):XML {
			var sc:ArrayCollection = ConnectionModel.getInstance().sparqlConfigs;
			var ep:IConfig = sc.getItemAt(0) as IConfig;
			
			var data:String = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" +
								"<data>" +
									"<proxy>" +
										"<url>" + ((proxy) ? proxy : ConnectionModel.getInstance().proxy) + "</url>" +
									"</proxy>" +
									"<endpoints>"; 
										for (var i:int = 0; i < sc.length; i++) {
											
											ep = sc.getItemAt(i) as IConfig;
											
											data += "<endpoint>";
											if (ep.name != null && ep.name != "") {
												data += "<name>" + ep.name + "</name>";
											}
											if (ep.abbreviation != null && ep.abbreviation != "") {
												data += "<abbreviation>" + ep.abbreviation + "</abbreviation>";
											}
											if (ep.description != null && ep.description != "") {
												data += "<description>" + ep.description + "</description>";
											}
											if (ep.endpointURI != null && ep.endpointURI != "") {
												data += "<endpointURI>" + ep.endpointURI + "</endpointURI>";
											}
											if (ep.defaultGraphURI != null && ep.defaultGraphURI != "") {
												data += "<defaultGraphURI>" + ep.defaultGraphURI + "</defaultGraphURI>";
											}
											data += "<isVirtuoso>" + ep.isVirtuoso + "</isVirtuoso>" +
											"<useProxy>" + ep.useProxy + "</useProxy>";
											
											if (ep.autocompleteURIs != null && ep.autocompleteURIs.length > 0) {
												
												data += "<autocompleteURIs>";
												for each(var ac:String in ep.autocompleteURIs) {
													data += "<autocompleteURI>" + ac + "</autocompleteURI>";
												}
												data += "</autocompleteURIs>";
											}
											
											if (ep.ignoredProperties != null && ep.ignoredProperties.length > 0) {
												
												data += "<ignoredProperties>";
												for each(var ip:String in ep.ignoredProperties) {
													data += "<ignoredProperty>" + ip + "</ignoredProperty>";
												}
												data += "</ignoredProperties>";
											}
											
											if (ep.abstractURIs != null && ep.abstractURIs.length > 0) {
												
												data += "<abstractURIs>";
												for each(var au:String in ep.abstractURIs) {
													data += "<abstractURI>" + au + "</abstractURI>";
												}
												data += "</abstractURIs>";
											}
											
											if (ep.imageURIs != null && ep.imageURIs.length > 0) {
												
												data += "<imageURIs>";
												for each(var iu:String in ep.imageURIs) {
													data += "<imageURI>" + iu + "</imageURI>";
												}
												data += "</imageURIs>";
											}
											
											if (ep.linkURIs != null && ep.linkURIs.length > 0) {
												
												data += "<linkURIs>";
												for each(var liu:String in ep.linkURIs) {
													data += "<linkURI>" + liu + "</linkURI>";
												}
												data += "</linkURIs>";
											}
											
											//data += "<minRelationLength>" + ep.minRelationLength + "</minRelationLength>";
											data += "<maxRelationLength>" + ep.maxRelationLength + "</maxRelationLength>";
											
											data += "</endpoint>";
										}
										
									data += "</endpoints>" +
								"</data>";
			return new XML(data);
		}
		
	}

}