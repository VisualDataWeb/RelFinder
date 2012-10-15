package connection
{
	import connection.model.ConnectionModel;
	import connection.model.LookUpCache;
	import global.GlobalString;
	import global.StatusModel;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.utils.StringUtil;
	
	import utils.SimilaritySort;
	
	/**
	 * ...
	 * @author Timo Stegemann (minor modifications by steffenl)
	 */
	public class LookUpSPARQL implements ILookUp
	{
		private var sparqlConnection:SPARQLConnection = new SPARQLConnection();
		
		private var target:Object;
		
		private var currentInput:String = "";
		
		public function run(_input:String, target:Object, limit:int = 20, offset:int = 0):void {
			
			currentInput = _input;
			
			this.target = target;
			
			var inputArrayCollection:ArrayCollection = new ArrayCollection();
			inputArrayCollection.addItem(_input);
			
			var lang:String = ConnectionModel.getInstance().sparqlConfig.autocompleteLanguage;
			
			var query:String = "";
			
			if (ConnectionModel.getInstance().sparqlConfig.isVirtuoso) {
				
				query = createCompleteIndegQuery(_input, limit, offset, lang);
				
				StatusModel.getInstance().addSearchLookUp();
				sparqlConnection.executeSparqlQuery(inputArrayCollection, query, lookUp_Count_Result, "XML", true, lookUp_Fault);
				
				
			}else {
				query = createStandardREGEXQuery(_input, limit, offset, lang);
				
				StatusModel.getInstance().addSearchLookUp();
				sparqlConnection.executeSparqlQuery(inputArrayCollection, query, lookUp_Result, "XML", true, lookUp_Fault);
			}
			
		}
		
		public function createCompleteIndegQuery(input:String, limit:int = 0, offset:int = 0, lang:String = ""):String {
			input = StringUtil.trim(input);
			if (input.search(" ") < 0) {
				return createSingleWordCompleteCountIndegQuery("'" + input + "'", limit, offset, lang);
			}else {
				var newInput:String = input.split(" ").join("' and '");
				return createMultipleWordsCompleteCountIndegQuery("'" + newInput + "'", limit, offset, lang);
			}
		}
		
		private function createMultipleWordsCompleteCountIndegQuery(input:String, limit:int = 0, offset:int = 0, lang:String = ""):String {
			var query:String = "";
			query = "SELECT DISTINCT ?s ?l count(?s) as ?count WHERE { ?someobj ?p ?s . ";
			if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs != null && ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 0) {
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " ?s ?someprop ?l . ";
					query += " { ";
				}
				query += " ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(0) + "> ?l ";
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " } ";
				}
				for (var i:int = 1; i < ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length; i++) {
					query += "UNION { ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(i) + "> ?l }";
				}
				query += ". ";
			}else {
				query += "?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . "
			}
			/*query += "?l bif:contains \"" + input + "\" . " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). " +
						"FILTER (!regex(str(?s), '^http://sw.opencyc.org/')). " +
						"FILTER (lang(?l) = '' || langMatches(lang(?l), '" + lang + "')). " +
						//"FILTER (lang(?l) = 'en'). " +
						"FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) ";*/
			query += "?l bif:contains \"" + input + "\" . " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). " +
						"FILTER (!regex(str(?s), '^http://sw.opencyc.org/')). ";
			if (lang != "") {
				query += "FILTER (lang(?l) = '' || langMatches(lang(?l), '" + lang + "')). ";
			}
			query += "FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) ";			
			if (limit != 0) {
				query += "LIMIT " + limit.toString() + " ";
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString() + " ";
			}
			return query;
		}
		
		private function createSingleWordCompleteCountIndegQuery(input:String, limit:int = 0, offset:int = 0, lang:String = ""):String {
			var query:String = "";
			query = "SELECT ?s ?l count(?s) as ?count WHERE { ?someobj ?p ?s . ";
			if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs != null && ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 0) {
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " ?s ?someprop ?l . ";
					query += " { ";
				}
				query += " ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(0) + "> ?l ";
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " } ";
				}
				for (var i:int = 1; i < ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length; i++) {
					query += "UNION { ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(i) + "> ?l } ";
				}
				query += ". ";
			}else {
				query += "?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . "
			}
			/*query += "?l bif:contains \"" + input + "\" . " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). " + 
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). " +
						"FILTER (!regex(str(?s), '^http://sw.opencyc.org/')). " +
						"FILTER (lang(?l) = '' || langMatches(lang(?l), '" + lang + "')). " +
						//"FILTER (lang(?l) = 'en'). " +
						"FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) "*/
			query += "?l bif:contains \"" + input + "\" . " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). " +
						"FILTER (!regex(str(?s), '^http://sw.opencyc.org/')). ";
			if (lang != "") {
				query += "FILTER (lang(?l) = '' || langMatches(lang(?l), '" + lang + "')). ";
			}
			query += "FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) ";						
			if (limit != 0) {
				query += "LIMIT " + limit.toString() + " ";
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString() + " ";
			}
			return query;
		}
		
//		PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
//		PREFIX foaf: <http://xmlns.com/foaf/0.1/>
//		PREFIX dcterms:  <http://purl.org/dc/terms/>
//		SELECT ?s  ?l  count(?s)  WHERE {
//		{?s ?p ?o.
//		{?s rdfs:label ?l }
//		UNION {?s foaf:name ?l}
//		UNION {?s dcterms:title ?l}
//		Filter regex(?l, 'Bruce', 'i') }
//		 }
//		GROUP BY ?s ?l 
		public function createStandardREGEXQuery(input:String, limit:int = 20, offset:int = 0, lang:String = ""):String {
			input = StringUtil.trim(input);
			var query:String = "";
			query = "SELECT ?s ?l WHERE { ";
			if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs != null && ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 0) {
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " ?s ?someprop ?l . ";
					query += " { ";
				}
				query += " ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(0) + "> ?l ";
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " } ";
				}
				for (var i:int = 1; i < ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length; i++) {
					query += "UNION { ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(i) + "> ?l } ";
				}
				query += ". ";
			}else {
				query += "?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . "
			}
			/*query += "FILTER regex(?l, '" + input + "', 'i'). " +
						"FILTER (lang(?l) = '' || langMatches(lang(?l), '" + lang + "')). " +
						"} ";*/
			query += "FILTER regex(?l, '" + input + "', 'i'). ";
			if (lang != "") {
				query += "FILTER (lang(?l) = '' || langMatches(lang(?l), '" + lang + "')). ";
			}
			query += "} ";		
			if (limit != 0) {
				query += "LIMIT " + limit.toString() + " ";
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString() + " ";
			}
			return query;
		}
		
		public function createStandardBIFContainsQuery(input:String, limit:int = 0, offset:int = 0):String {
			input = StringUtil.trim(input);
			var query:String = "";
			query = "SELECT ?s ?l WHERE { ";
			if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs != null && ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 0) {
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " ?s ?someprop ?l . ";
					query += " { ";
				}
				query += " ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(0) + "> ?l ";
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " } ";
				}
				for (var i:int = 1; i < ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length; i++) {
					query += "UNION { ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(i) + "> ?l } ";
				}
				query += ". ";
			}else {
				query += "?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . "
			}
			query += " ?l bif:contains \"'" + input + "'\" . } "; 
			if (limit != 0) {
				query += "LIMIT " + limit.toString();
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString();
			}
			return query;
		}
		
		public function createCompleteOutdegQuery(input:String, limit:int = 0, offset:int = 0):String {
			input = StringUtil.trim(input);
			if (input.search(" ") < 0) {
				return createSingleWordCompleteCountOutdegQuery("'" + input + "'", limit, offset);
			}else {
				var newInput:String = input.split(" ").join("' and '");
				return createMultipleWordsCompleteCountOutdegQuery("'" + newInput + "'", limit, offset);
			}
		}
		
		private function createMultipleWordsCompleteCountOutdegQuery(input:String, limit:int = 0, offset:int = 0):String {
			var query:String = "";
			query = "SELECT DISTINCT ?s ?l count(?s) as ?count WHERE { ?s ?p ?someobj . ";
			if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs != null && ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 0) {
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " ?s ?someprop ?l . ";
					query += " { ";
				}
				query += " ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(0) + "> ?l ";
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " } ";
				}
				for (var i:int = 1; i < ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length; i++) {
					query += "UNION { ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(i) + "> ?l } ";
				}
				query += ". ";
			}else {
				query += "?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . "
			}
			query += "?l bif:contains \"" + input + "\" . " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). " +
						"FILTER (lang(?l) = '' || langMatches(lang(?l), 'en')). " +
						//"FILTER (lang(?l) = 'en'). " +
						"FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) ";
			query += "FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) ";						
			if (limit != 0) {
				query += "LIMIT " + limit.toString() + " ";
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString() + " ";
			}
			return query;
		}
		
		private function createSingleWordCompleteCountOutdegQuery(input:String, limit:int = 0, offset:int = 0):String {
			var query:String = "";
			query = "SELECT ?s ?l count(?s) as ?count WHERE { ?s ?p ?someobj . ";
			if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs != null && ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 0) {
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " ?s ?someprop ?l . ";
					query += " { ";
				}
				query += " ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(0) + "> ?l ";
				if (ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length > 1) {
					query += " } ";
				}
				for (var i:int = 1; i < ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.length; i++) {
					query += "UNION { ?s <" + ConnectionModel.getInstance().sparqlConfig.autocompleteURIs.getItemAt(i) + "> ?l } ";
				}
				query += ". ";
			}else {
				query += "?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . "
			}
			query += "?l bif:contains \"" + input + "\" . " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). " +
						"FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). " +
						"FILTER (lang(?l) = '' || langMatches(lang(?l), 'en')). " +
						//"FILTER (lang(?l) = 'en'). " +
						"FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) ";
			query += "FILTER (!isLiteral(?someobj)). " +
						"} " +
						"ORDER BY DESC(?count) ";						
			if (limit != 0) {
				query += "LIMIT " + limit.toString() + " ";
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString() + " ";
			}
			return query;
		}
		
		public function createCompleteREGEXIndegQuery(input:String, limit:int = 0, offset:int = 0):String {
			input = StringUtil.trim(input);
			if (input.search(" ") < 0) {
				return createSingleWordREGEXCompleteCountIndegQuery("\"" + input + "\"", limit);
			}else {
				var newInput:String = input.split(" ").join("\" and \"");
				return createMultipleWordsREGEXCompleteCountIndegQuery("\"" + newInput + "\"", limit);
			}
		}
		
		private function createMultipleWordsREGEXCompleteCountIndegQuery(input:String, limit:int = 0, offset:int = 0):String {
			var query:String = "";
			query = "SELECT DISTINCT ?s ?l count(?s) as ?count WHERE { ?someobj ?p ?s . ?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . filter regex(?l, '" + input + "', 'i')  . FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). FILTER (!regex(str(?s), '^http://sw.opencyc.org/')). FILTER (lang(?l) = 'en'). FILTER (!isLiteral(?someobj)). } ORDER BY DESC(?count) "; 
			if (limit != 0) {
				query += "LIMIT " + limit.toString();
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString();
			}
			return query;
		}
		
		private function createSingleWordREGEXCompleteCountIndegQuery(input:String, limit:int = 0, offset:int = 0):String {
			var query:String = "";
			query = "SELECT ?s ?l COUNT(?s) WHERE { ?someobj ?p ?s . ?s <http://www.w3.org/2000/01/rdf-schema#label> ?l . FILTER regex(?l, '" + input + "', 'i')  . FILTER (!regex(str(?s), '^http://dbpedia.org/resource/Category:')). FILTER (!regex(str(?s), '^http://dbpedia.org/resource/List')). FILTER (!regex(str(?s), '^http://sw.opencyc.org/')). FILTER (lang(?l) = 'en'). FILTER (!isLiteral(?someobj)). } ORDER BY DESC(COUNT(?s)) "
			if (limit != 0) {
				query += "LIMIT " + limit.toString();
			}
			if (offset != 0) {
				query += "OFFSET " + offset.toString();
			}
			return query;
		}
		
		private function createInputStringWithWildcards(input:String):String {
			var output:String = "";
			
			var stringArray:Array = input.split(" ");
			for (var i:int; i < stringArray.length; i++) {
				if (stringArray[i].toString().length >= 3 && i == stringArray.length - 1) {
					stringArray[i] = stringArray[i].toString() + "*";
				}
				output += stringArray[i];
				if (!(i == stringArray.length - 1)) {
					output += " ";
				}
			}
			
			trace(output);
			
			return output;
		}
		
		public function traceResults(e:SPARQLResultEvent):void {
			trace(e.result);
		}
		
		public function lookUp_Count_Result(e:SPARQLResultEvent):void {
			StatusModel.getInstance().addFoundLookUp();
			var lastSend:Date = LookUpCache.getInstance().getLastSend(target);
			var resultSend:Date = e.executenTime;
			
			if (lastSend == null) {
				lastSend = resultSend;
			}
			
			LookUpCache.getInstance().setLastSend(target, resultSend);
			
			var lastInput:String = e.sources.getItemAt(0).toString();
			
			trace(lastInput, currentInput);
			
			if (resultSend.time >= lastSend.time && lastInput && currentInput && lastInput == currentInput) {
				
				var results:ArrayCollection = new ArrayCollection();
				var result:XML;
				try {
					result = new XML(e.result);
					var resultNS:Namespace = new Namespace("http://www.w3.org/2005/sparql-results#");
					var rdfNS:Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
					
					var contains:Boolean = false;
					var containsLabel:Boolean = false;
					
					if (result..resultNS::results != "") {
						for each (var res:XML in result..resultNS::results.resultNS::result) {
							
							var newLabel:String = "";
							var newUri:String = "";
							var newCount:int = 0;
							
							// Crap but working. Other solutions cause Flex Player + Browser crashing
							for each (var binding:XML in res.resultNS::binding) {
								if ((binding as XML).toXMLString().indexOf("<binding") == 0) {
									newLabel = res.resultNS::binding.(@name == 'l').resultNS::literal;
									newUri = res.resultNS::binding.(@name == 's').resultNS::uri
									newCount = new int(res.resultNS::binding.(@name == 'count').resultNS::literal);
								}else {
									newLabel = res.resultNS::binding.(@resultNS::name == "l").resultNS::value;
									newUri = res.resultNS::binding.(@resultNS::name == "s").resultNS::value.@rdfNS::resource;
									newCount = new int(res.resultNS::binding.(@resultNS::name == "count").resultNS::value);
								}
							}
							
							
							if (newUri == null || newUri == "") {
								newUri = res.resultNS::binding.(@name == 's').resultNS::literal;
							}
							
							contains = false;
							containsLabel = false;
							
							var oldObject:Object;
							
							for each (var entry:Object in results) {
								if (entry.label.toString() == newLabel.toString()) {
									containsLabel = true;
									for each (var uri:String in (entry.uris as Array)) {
										if (uri == newUri) {
											contains = true;
										}
									}
									if (!contains){
										(entry.uris as Array).push(newUri);
									}
									continue;
								}
							}
							
							if (!contains) {
								
								if (!containsLabel){
									var ob:Object;
									ob = new Object();
									ob.label = newLabel;
									ob.count = newCount;
									ob.uris = new Array(newUri);
									results.addItem(ob);
								}
							}
						}
					}
					
					if (results.length == 0) {
						
						if (result.html && result.html.length != undefined ) {
							var er:Object = new Object();
							er.label = GlobalString.ERROR;
							er.toolTip = e.result;
							results.addItem(er);
						}else {
							var empty:Object = new Object();
							empty.label = GlobalString.NORESULTS;
							results.addItem(empty);
						}
						
					}else {
						var separator:Object = new Object();
						separator.label = GlobalString.SEPARATOR;
						results.addItem(separator);
						var more:Object = new Object();
						more.label = GlobalString.SEARCHMORE;
						results.addItem(more);
					}
					
				}catch (error:Error) {
					var err:Object = new Object();
					err.label = GlobalString.ERROR;
					err.toolTip = e.result;
					results.addItem(err);
				}
				
				target.dataProvider = results;
				
			}
		}
		
		public function lookUp_Result(e:SPARQLResultEvent):void {
			StatusModel.getInstance().addFoundLookUp();
			var lastSend:Date = LookUpCache.getInstance().getLastSend(target);
			var resultSend:Date = e.executenTime;
			
			if (lastSend == null) {
				lastSend = resultSend;
			}
			
			LookUpCache.getInstance().setLastSend(target, resultSend);
			
			var lastInput:String = e.sources.getItemAt(0).toString();
			
			trace("lastinput", lastInput, "currentinput", currentInput);
			
			if (resultSend.time >= lastSend.time && lastInput && currentInput && lastInput == currentInput) {
				
				var results:ArrayCollection = new ArrayCollection();
				var result:XML;
				try {
					result = new XML(e.result);
				} catch (error:TypeError){
					result = new XML();
					trace(error);
					trace(e.result);
				}
				
				var resultNS:Namespace = new Namespace("http://www.w3.org/2005/sparql-results#");
				var rdfNS:Namespace = new Namespace("http://www.w3.org/1999/02/22-rdf-syntax-ns#");
				
				var contains:Boolean = false;
				var containsLabel:Boolean = false;
				
				if (result..resultNS::results != "") {
					for each (var res:XML in result..resultNS::results.resultNS::result) {
						
						var newLabel:String = "";
						var newUri:String = "";
						
						// Crap but working. Other solutions cause Flex Player + Browser crashing
						for each (var binding:XML in res.resultNS::binding) {
							if ((binding as XML).toXMLString().indexOf("<binding") == 0) {
								newLabel = res.resultNS::binding.(@name == 'l').resultNS::literal;
								newUri = res.resultNS::binding.(@name == 's').resultNS::uri
							}else {
								newLabel = res.resultNS::binding.(@resultNS::name == "l").resultNS::value;
								newUri = res.resultNS::binding.(@resultNS::name == "s").resultNS::value.@rdfNS::resource;
							}
						}
						
						
						contains = false;
						containsLabel = false;
						
						var oldObject:Object;
						
						for each (var entry:Object in results) {
							if (entry.label.toString() == newLabel.toString()) {
								containsLabel = true;
								for each (var uri:String in (entry.uris as Array)) {
									if (uri == newUri) {
										contains = true;
									}
								}
								if (!contains){
									(entry.uris as Array).push(newUri);
								}
								continue;
							}
						}
						
						if (!contains) {
							
							if (!containsLabel){
								var ob:Object;
								ob = new Object();
								ob.label = newLabel;
								ob.uris = new Array(newUri);
								results.addItem(ob);
							}
						}
					}
				}
				
				SimilaritySort.sort(results, lastInput);
				
				if (results.length == 0) {
					var empty:Object = new Object();
					empty.label = GlobalString.NORESULTS;
					results.addItem(empty);
				}else {
					var separator:Object = new Object();
					separator.label = GlobalString.SEPARATOR;
					results.addItem(separator);
					var more:Object = new Object();
					more.label = GlobalString.SEARCHMORE;
					results.addItem(more);
				}
				
				target.dataProvider = results;
			}
			
		}
		
		public function lookUp_Fault(e:FaultEvent):void {
			var results:ArrayCollection = new ArrayCollection();
			var er:Object = new Object();
			er.label = GlobalString.ERROR;
			er.toolTip = e.message.toString();
			results.addItem(er);
			target.dataProvider = results;
			StatusModel.getInstance().addFoundLookUp();
			StatusModel.getInstance().addErrorLookUp(e.clone());
		}
		
	}
	
}