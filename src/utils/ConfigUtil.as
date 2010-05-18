package utils 
{
	import com.dynamicflash.util.Base64;
	import connection.config.Config;
	import connection.config.IConfig;
	import connection.model.ConnectionModel;
	import flash.utils.Dictionary;
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import mx.utils.ObjectUtil;
	/**
	 * ...
	 * @author Timo Stegemann
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
			
			if (config.abbreviation != null && config.abbreviation != "") {
				data += "&abbreviation=" + Base64.encode(config.abbreviation);
			}
			
			if (config.description != null && config.description != "") {
				data += "&description=" + Base64.encode(config.description);
			}
			
			if (config.endpointURI != null && config.endpointURI != "") {
				data += "&endpointURI=" + Base64.encode(config.endpointURI);
			}
			
			data += "&dontAppendSPARQL=" + Base64.encode(config.dontAppendSPARQL.toString());
			
			if (config.defaultGraphURI != null && config.defaultGraphURI != "") {
				data += "&defaultGraphURI=" + Base64.encode(config.defaultGraphURI);
			}
			data += "&isVirtuoso=" + Base64.encode(config.isVirtuoso.toString()) +
				"&useProxy=" + Base64.encode(config.useProxy.toString()) +
				"&method=" + Base64.encode(config.method) +
				"&autocompleteLanguage=" + Base64.encode(config.autocompleteLanguage);

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
			
			if (config.abstractURIs != null && config.abstractURIs.length > 0) {
				
				var absuri:String = "";
				
				for (var k:int = 0; k < config.abstractURIs.length; k++) {
					absuri += config.abstractURIs.getItemAt(k);
					if (k < config.abstractURIs.length - 1) {
						absuri += ",";
					}
				}
				data += "&abstractURIs=" + Base64.encode(absuri);
			}
			
			if (config.imageURIs != null && config.imageURIs.length > 0) {
				
				var imuri:String = "";
				
				for (var l:int = 0; l < config.imageURIs.length; l++) {
					imuri += config.imageURIs.getItemAt(l);
					if (l < config.imageURIs.length - 1) {
						imuri += ",";
					}
				}
				data += "&imageURIs=" + Base64.encode(imuri);
			}
			
			if (config.linkURIs != null && config.linkURIs.length > 0) {
				
				var linkuri:String = "";
				
				for (var m:int = 0; m < config.linkURIs.length; m++) {
					linkuri += config.linkURIs.getItemAt(m);
					if (m < config.linkURIs.length - 1) {
						linkuri += ",";
					}
				}
				data += "&linkURIs=" + Base64.encode(linkuri);
			}
			
			data += "&maxRelationLegth=" + Base64.encode(config.maxRelationLength.toString());
			
			return data;
		}
		
		public static function fromURLParameter(param:Dictionary):Example {
			
			var example:Example = new Example();
			
			// if url parameters contain "id", try to find this id in the loaded configs. If this "id" is invalid, return null.
			if (param.hasOwnProperty("id")) {
				var id:String = param["id"];
				
				for (var k:int = 0; k < ConnectionModel.getInstance().sparqlConfigs.length; k++) {
					if ((ConnectionModel.getInstance().sparqlConfigs.getItemAt(k) as IConfig).abbreviation == id) {
						example.endpointConfig = ConnectionModel.getInstance().sparqlConfigs.getItemAt(k) as IConfig;
						continue;
					}
				}
				
				if (example.endpointConfig == null) {
					// Config is not in config file
					Alert.show("Config " + id + " is not known");
					return null;
				}
				
			}
			
			// init conifg, if no "id" was set with the parameters.
			if (example.endpointConfig == null) {
				example.endpointConfig = new Config();
			}
			
			// read all parameters
			for (var key:String in param) {
				
				if (key.substring(0, 3) == "obj") {
					var  obj:Object = decodeObjectParameter(param[key]);
					example.objects.addItem(obj);
				}
				
				if (key == "name") {
					example.endpointConfig.name = Base64.decode(param[key]);
				}
				
				if (key == "abbreviation") {
					example.endpointConfig.abbreviation = Base64.decode(param[key]);
				}
				
				if (key == "description") {
					example.endpointConfig.description = Base64.decode(param[key]);
				}
				
				if (key == "endpointURI") {
					example.endpointConfig.endpointURI = Base64.decode(param[key]);
				}
				
				if (key == "dontAppendSPARQL") {
					example.endpointConfig.dontAppendSPARQL = (Base64.decode(param[key]) == "true") ? true : false;
				}
				
				if (key == "defaultGraphURI") {
					example.endpointConfig.defaultGraphURI = Base64.decode(param[key]);
				}
				
				if (key == "isVirtuoso") {
					example.endpointConfig.isVirtuoso = (Base64.decode(param[key]) == "true") ? true : false;
				}
				
				if (key == "useProxy") {
					example.endpointConfig.useProxy = (Base64.decode(param[key]) == "true") ? true : false;
				}
				
				if (key == "method") {
					example.endpointConfig.method = Base64.decode(param[key]);
				}
				
				if (key == "autocompleteURIs") {
					example.endpointConfig.autocompleteURIs = new ArrayCollection(Base64.decode(param[key]).split(","));
				}
				
				if (key == "autocompleteLanguage") {
					example.endpointConfig.autocompleteLanguage = Base64.decode(param[key]);
				}
				
				if (key == "ignoredProperties") {
					example.endpointConfig.ignoredProperties = new ArrayCollection(Base64.decode(param[key]).split(","));
				}
				
				if (key == "abstractURIs") {
					example.endpointConfig.abstractURIs = new ArrayCollection(Base64.decode(param[key]).split(","));
				}
				
				if (key == "imageURIs") {
					example.endpointConfig.imageURIs = new ArrayCollection(Base64.decode(param[key]).split(","));
				}
				
				if (key == "linkURIs") {
					example.endpointConfig.linkURIs = new ArrayCollection(Base64.decode(param[key]).split(","));
				}
				
				if (key == "maxRelationLength") {
					example.endpointConfig.maxRelationLength = new int(Base64.decode(param[key]));
				}
			}
			
			// compare config from parameters with configs from config file.
			// if one config from config file equals the parameter config, set this config.
			// otherwise use parameter config and mark it as from parameters.
			for each (var conf:IConfig in ConnectionModel.getInstance().sparqlConfigs) {
				if (example.endpointConfig.equals(conf)) {
					example.endpointConfig = conf;
					return example;
				}
			}
			
			example.endpointConfig.name += " (from URL parameters)";
			example.endpointConfig.abbreviation += (new Date()).time.toString();
			
			return example;
		}
		
		// if conf1 and conf2 are equal, compare will return 0, otherwise some positive number
		public static function compare(conf1:IConfig, conf2:IConfig):Number {
			var compare:Number = 0;
			
			if (conf1.name != conf2.name) {
				compare++;
			}
			
			if (conf1.abbreviation != conf2.abbreviation) {
				compare++;
			}
			
			//if (conf1.description != conf2.description) {
				//compare++;
			//}
			
			if (conf1.endpointURI != conf2.endpointURI) {
				compare++;
			}
			
			if (conf1.dontAppendSPARQL != conf2.dontAppendSPARQL) {
				compare++;
			}
			
			if (conf1.defaultGraphURI != conf2.defaultGraphURI) {
				compare++;
			}
			
			if (conf1.isVirtuoso != conf2.isVirtuoso) {
				compare++;
			}
			
			if (conf1.useProxy != conf2.useProxy) {
				compare++;
			}
			
			if (ArrayCollectionUtil.compare(conf1.autocompleteURIs, conf2.autocompleteURIs) != 0) {
				compare++;
			}
			
			if (ArrayCollectionUtil.compare(conf1.ignoredProperties, conf2.ignoredProperties) != 0) {
				compare++;
			}
			
			if (ArrayCollectionUtil.compare(conf1.abstractURIs, conf2.abstractURIs) != 0) {
				compare++;
			}
			
			if (ArrayCollectionUtil.compare(conf1.imageURIs, conf2.imageURIs) != 0) {
				compare++;
			}
			
			if (ArrayCollectionUtil.compare(conf1.linkURIs, conf2.linkURIs) != 0) {
				compare++;
			}
			
			if (conf1.maxRelationLength != conf2.maxRelationLength) {
				compare++;
			}
			
			return compare;
			
		}
		
		
		
		private static function decodeObjectParameter(value:String):Object {
			var obj:Object = new Object();
			var str:String = Base64.decode(value);
			var arr:Array = str.split("|");
			obj.label = arr[0].toString();
			obj.uris = new Array();
			for (var i:int = 1; i <= arr.length - 1; i++){
				if (arr[i] && arr[i].toString() != ""){
					(obj.uris as Array).push(arr[i].toString());
				}
			}
			
			return obj;
		}
		
		public static function encodeObjectParameter(label:String, url:String):String {
			return Base64.encode(label + "|" + url);
		}
		
		public static function setConfigurationFromXML(xml:Object):void {
			
			// set proxy
			if (xml.proxy != null && xml.proxy.url != null) {
				ConnectionModel.getInstance().proxy = xml.proxy.url;
				ConnectionModel.getInstance().defaultProxy = xml.proxy.url;
			}
			
			// for old versions
			if (xml && xml.hasOwnProperty("endpoints") && xml.endpoints.hasOwnProperty("defaultEndpoint")) {
				ConnectionModel.getInstance().sparqlConfigs.addItem(getConfig(xml.endpoints.defaultEndpoint));
			}
			
			if (xml.endpoints.endpoint is ArrayCollection) {
				for each (var obj:Object in xml.endpoints.endpoint) {
					ConnectionModel.getInstance().sparqlConfigs.addItem(getConfig(obj));
				}
			}else {
				ConnectionModel.getInstance().sparqlConfigs.addItem(getConfig(xml.endpoints.endpoint));
			}
			
			ConnectionModel.getInstance().sparqlConfig = ConnectionModel.getInstance().sparqlConfigs.getItemAt(0) as IConfig;
			
		}
		
		public static function getConfig(conf:Object):Config {
			
			var config:Config = new Config();
			
			var time:String = (new Date()).time.toString();
			
			config.name = (conf.name != null) ? conf.name : "no name " + time;
			config.abbreviation = (conf.abbreviation != null) ? conf.abbreviation : "no id " + time;
			config.description = (conf.description != null) ? conf.description : "";
			config.endpointURI = (conf.endpointURI != null) ? conf.endpointURI : "";
			config.dontAppendSPARQL = (conf.dontAppendSPARQL != null && conf.dontAppendSPARQL.toString().toLowerCase() == "true") ? true : false;
			config.defaultGraphURI = (conf.defaultGraphURI != null) ? conf.defaultGraphURI : "";
			config.isVirtuoso = (conf.isVirtuoso.toString().toLowerCase() == "true") ? true : false;
			config.useProxy = (conf.useProxy.toString().toLowerCase() == "true") ? true : false;
			config.method = (conf.method != null) ? conf.method : "POST";
			config.autocompleteLanguage = (conf.autocompleteLanguage != null && conf.autocompleteLanguage != "") ? conf.autocompleteLanguage : "en";
			
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
											data += "<dontAppendSPARQL>" + ep.dontAppendSPARQL + "</dontAppendSPARQL>";
											if (ep.defaultGraphURI != null && ep.defaultGraphURI != "") {
												data += "<defaultGraphURI>" + ep.defaultGraphURI + "</defaultGraphURI>";
											}
											data += "<isVirtuoso>" + ep.isVirtuoso + "</isVirtuoso>" +
											"<useProxy>" + ep.useProxy + "</useProxy>" +
											"<method>" + ep.method + "</method>";
											
											if (ep.autocompleteURIs != null && ep.autocompleteURIs.length > 0) {
												
												data += "<autocompleteURIs>";
												for each(var ac:String in ep.autocompleteURIs) {
													data += "<autocompleteURI>" + ac + "</autocompleteURI>";
												}
												data += "</autocompleteURIs>";
											}
											
											data += "<autocompleteLanguage>" + ep.autocompleteLanguage + "</autocompleteLanguage>";
											
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