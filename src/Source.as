/**
 * Copyright (C) 2009 Philipp Heim, Sebastian Hellmann, Jens Lehmann, Steffen Lohmann and Timo Stegemann
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

 
import com.adobe.flex.extras.controls.springgraph.Graph;
import com.dynamicflash.util.Base64;
import com.hillelcoren.components.AutoComplete;
import com.hillelcoren.components.autoComplete.classes.SelectedItem;
import connection.config.Config;
import connection.config.IConfig;
import connection.model.LookUpCache;
import flash.display.DisplayObject;
import flash.geom.Point;
import global.GlobalString;
import global.ToolTipModel;
import graphElements.model.Graphmodel;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Canvas;
import mx.containers.HBox;
import mx.containers.TabNavigator;
import mx.controls.DataGrid;
import mx.controls.Menu;
import mx.core.ClassFactory;
import mx.core.Repeater;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.events.MenuEvent;
import mx.events.SliderEvent;
import mx.managers.ToolTipManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.http.HTTPService;
import mx.utils.ObjectUtil;
import mx.utils.StringUtil;
import utils.ConfigUtil;
import utils.Example;
import utils.ExampleUtil;

import connection.ILookUp;
import connection.ISPARQLResultParser;
import connection.LookUpKeywordSearch;
import connection.SPARQLConnection;
import connection.SPARQLResultParser;
import connection.config.DBpediaConfig;
import connection.config.LODConfig;
import connection.model.ConnectionModel;

import de.polygonal.ds.ArrayedQueue;
import de.polygonal.ds.HashMap;
import de.polygonal.ds.Iterator;

import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TextEvent;
import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;

import global.Languages;
import global.StatusModel;

import graphElements.*;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.Application;
import mx.managers.PopUpManager;
import mx.rpc.events.ResultEvent;

import popup.ErrorLog;
import popup.ExpertSettings;
import popup.Infos;
import popup.InputDisambiguation;
import popup.InputSelection;
import popup.InputSelectionEvent;

import toolTip.SelectedItemToolTipRenderer;




private var _selectedElement:Element = null;	//so ist es besser!

private var myConnection:SPARQLConnection = null;
private var sparqlEndpoint:String = "";
private var basicGraph:String = "";
private var resultParser:ISPARQLResultParser = new SPARQLResultParser();

private var lastInputs:Array = new Array();


[Bindable]
private var autoCompleteList:ArrayCollection = new ArrayCollection();

private var filterSort:Sort = new Sort();
private var sortByLabel:SortField = new SortField("label", true);

[Bindable(event = "eventLangsChanged")]
private var languageDP:Array = Languages.getInstance().asDataProvider;

public var PLRCHANGE:String = "selectedPathLengthRangeChange";

[Bindable]
private var _showOptions:Boolean = false;	//flag to set filters and infos visible or invisible

[Bindable]
[Embed(source="../assets/img/show.gif")]
public var filterSign:Class;

private var setupDone:Boolean = false;

private function setup(): void {
	
	if (!setupDone) {
		myConnection = new SPARQLConnection();
	
		StatusModel.getInstance().addEventListener("eventMessageChanged", statusChangedHandler);
		
		(sGraph as Canvas).addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelZoomHandler);
		
		callLater(setupParams);
	}
	
	setupDone = true;
	
}

private function get graphModel():Graphmodel {
	return Graphmodel.getInstance();
}

private function mouseWheelRepulsionHandler(event:MouseEvent):void {
	if (event.delta > 0) {
		sGraph.repulsionFactor = sGraph.repulsionFactor * 1.05;
	}else {
		sGraph.repulsionFactor= sGraph.repulsionFactor / 1.05;
	}
}

private var wheelScale:Number = 1.0;

private function mouseWheelZoomHandler(event:MouseEvent):void {
	if (event.delta > 0) {
		zoomSliderUp();
	}else {
		zoomSliderDown();
	}
	
}

private var sliderDamper:int = 0;

public function zoomSliderUp():void {
	
	sliderDamper++;
	
	if (sliderDamper > 1 && zoomSlider.value < Graphmodel.ZOOM_AGGREGATED_NODES) {
		sliderDamper = 0;
		zoomSlider.value++;
		graphModel.zoomFactor = zoomSlider.value;
	}
}

public function zoomSliderDown():void {
	
	sliderDamper++;
	
	if (sliderDamper > 1 && zoomSlider.value > Graphmodel.ZOOM_COMPLETE) {
		sliderDamper = 0;
		zoomSlider.value--;
		graphModel.zoomFactor = zoomSlider.value;
	}
}

private function zoomSliderChangeHandler(event:SliderEvent):void {
	graphModel.zoomFactor = event.value;
}

private function setupParams():void {
	
	var param:Dictionary = getUrlParamateres();
	
	if (param == null) {
		return;
	}
	
	var example:Example = ConfigUtil.fromURLParameter(param);
	
	if (example != null && example.endpointConfig != null) {
		
		var conf:IConfig = ConnectionModel.getInstance().getSPARQLByAbbreviation(example.endpointConfig.abbreviation);
		
		if (conf == null) {
			ConnectionModel.getInstance().sparqlConfigs.addItem(example.endpointConfig);
			ConnectionModel.getInstance().sparqlConfig = example.endpointConfig;
		}else {
			ConnectionModel.getInstance().sparqlConfig = conf;
		}
		
		callLater(loadExample2, [example]);
	}
	
}

private function preInitHandler(event:Event):void {
	// load config
	var root:String = Application.application.url;
	var configLoader:HTTPService = new HTTPService(root);
	
	configLoader.addEventListener(ResultEvent.RESULT, xmlCompleteHandler);
	configLoader.addEventListener(FaultEvent.FAULT, xmlCompleteHandler);
	configLoader.url = "config/Config.xml";
	configLoader.send();
   
}

private function xmlCompleteHandler(event:Event):void {
	if (event is ResultEvent) {
		
		ConfigUtil.setConfigurationFromXML((event as ResultEvent).result.data);
		
	}else {
		Alert.show((event as FaultEvent).fault.toString(), "Config file not found");
	}
	
	callLater(setInitialized);
	
	loadExamples();
}

private function loadExamples():void {
	var root:String = Application.application.url;
	var exampleLoader:HTTPService = new HTTPService(root);
	
	exampleLoader.addEventListener(ResultEvent.RESULT, exampleCompleteHandler);
	exampleLoader.addEventListener(FaultEvent.FAULT, exampleCompleteHandler);
	exampleLoader.url = "config/examples.xml";
	exampleLoader.send();
}

private function exampleCompleteHandler(event:Event):void {
	if (event is ResultEvent) {
		
		ExampleUtil.setExamplesFromXML((event as ResultEvent).result.data);
		
	}else {
		Alert.show((event as FaultEvent).fault.toString(), "Example file not found");
	}
	
	callLater(setInitialized);
}

private function setInitialized():void {
	super.initialized = true
}

override public function set initialized(value:Boolean):void{
	// don't do anything, so we wait until the xml loads
}

private function statusChangedHandler(event:Event):void {
	statusLabel.text = "Status: " + StatusModel.getInstance().message;
	
	if (StatusModel.getInstance().isSearching){
		la.startRotation();
	}else{
		la.stopRotation();
		graphModel.delayedDrawing = false;
		//build connectivityLevels
		var iter:Iterator = graphModel.elements.getIterator();
		while (iter.hasNext()) {
			var e:Element = iter.next();
			if ((!e.isGiven)  && (!e.isPredicate)) {
				e.computeConnectivityLevel();
			}
		}
	}
}

private function validateParamters(key:String, value:String):Boolean {
	if (key.indexOf("obj") == 0) {
		var index:int = new int(key.charAt(3));
		
		while (index > inputFieldRepeater.dataProvider.length) {
			inputFieldBox.addNewInputField();
		}
	
		if (index != 0) {
			var  obj:Object = decodeObjectParameter(value);
			(inputField[index - 1] as AutoComplete).selectedItem = obj;
			(inputField[index - 1] as AutoComplete).validateNow();
		}
		return true;
	}
	return false;
}

private function inputToURL():String {
	return ConfigUtil.toURLParameters(
		Application.application.url.substring(0, Application.application.url.lastIndexOf(".swf") + 4), 
		lastInputs,
		ConnectionModel.getInstance().sparqlConfig);
}

private function decodeObjectParameter(value:String):Object {
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

private function getUrlParamateres():Dictionary {
	var urlParams:Dictionary = new Dictionary();
	var param:Object = Application.application.parameters;
	var count:int = 0;
	
	for (var key:String in param) {
		urlParams[key] = param[key];
		count++;
	}
	
	if (count == 0) {
		return null;
	}
	
	return urlParams;
}


[Bindable]
public function get selectedElement():Element {
	return _selectedElement;
}

public function set selectedElement(e:Element):void {
	//trace("setSelectedE");
	//delayedDrawing = false;	//because user interaction!
	
	if (e == null) {
		_selectedElement = null;
		graphModel.selectedConcept = null;
	}else if ((_selectedElement == null) || (e != null && _selectedElement != null && _selectedElement.id != null && e.id != null && _selectedElement.id != e.id)) {
		_selectedElement = e;
		graphModel.selectedConcept = _selectedElement.concept;
		var iter:Iterator = graphModel.paths.getIterator();
		while (iter.hasNext()) {
			var p1:Path = iter.next();
			p1.isHighlighted = false;
		}
		if (graphModel.foundNodes.containsKey(e.id)) {	//only for found nodes
			
			for each(var r:Relation in _selectedElement.relations) {
				for each(var p:Path in r.paths) {
					if (p.isVisible) {
						p.isHighlighted = true;
					}
				}
			}
		}
	}else {
		//trace("else");
		for each(var r2:Relation in _selectedElement.relations) {
			for each(var p2:Path in r2.paths) {
				p2.isHighlighted = false;
			}
		}
	}
}

public function clear():void {
	trace("clear");
	
	clearGraph();

	inputFieldBox.dataProvider = new ArrayCollection(new Array(new String("input0"), new String("input1")));
	autoCompleteList = new ArrayCollection();
	
	_showOptions = false;
	
	trace("check clear!!");
	trace("graph: " + graphModel.graph.nodeCount);
	trace("paths: " + graphModel.paths.size);
}

public function clearGraph():void {
	trace("clear");
	
	ConnectionModel.getInstance().lastClear = new Date();
	
	//TODO: clear slider, clear input fields
	
	//TODO: Stop SPARQL queries, clear all the connection stuff! 
	//(resultParser as SPARQLResultParser).clear();
	
	/**
	 * REMOVE ALL LISTENER ----------------
	 */
	var iter:Iterator = graphModel.paths.getIterator();
	while (iter.hasNext()) {
		var p:Path = iter.next();
		p.removeListener();
	}
	
	var iter2:Iterator = graphModel.relations.getIterator();
	while (iter2.hasNext()) {
		var r:Relation = iter2.next();
		r.removeListener();
	}
	
	var iter4:Iterator = graphModel.elements.getIterator();
	while (iter4.hasNext()) {
		var e:Element = iter4.next();
		e.removeListener();
	}
	
	for each(var c:Concept in graphModel.concepts) {
		c.removeListener();
	}
	
	for each(var pL:PathLength in graphModel.pathLengths) {
		pL.removeListener();
	}
	
	for each(var rT:RelType in graphModel.relTypes) {
		rT.removeListener();
	}
	
	for each(var cL:ConnectivityLevel in graphModel.connectivityLevels) {
		cL.removeListener();
	}
	
	/**
	 * RESET VARIABLES -----------------------
	 */
	
	graphModel.clear();
	
	myConnection = new SPARQLConnection();
	
	StatusModel.getInstance().queueIsEmpty = true;
	StatusModel.getInstance().clear();
	
	Languages.getInstance().clear();
	
	selectedElement = null;	//so ist es besser!
	
	sparqlEndpoint = "";
	basicGraph = "";
	resultParser = new SPARQLResultParser();
	
	tab10.isVisible = true;
	tab11.isVisible = true;
	tab12.isVisible = true;
	tab13.isVisible = true;
}

//--Expert-Settings + Info-------------------------------------

private var _settingsButton:Object;

[Embed(source="../assets/img/16-tool.png")]
private var _settingsButtonIcon:Class;

private var _infosButton:Object;

[Embed(source="../assets/img/16-info.png")]
private var _infosButtonIcon:Class;

private var _clearButton:Object;

[Embed(source="../assets/img/Clear.png")]
private var _clearButtonIcon:Class;

private var _urlButton:Object;

[Embed(source="../assets/img/16-url.png")]
private var _urlButtonIcon:Class;

private function getButtons():ArrayCollection {
	
	var btns:ArrayCollection = new ArrayCollection();
	
	if (_settingsButton == null) {
		_settingsButton = new Object();
		_settingsButton.toolTip = "Settings";
		_settingsButton.name = "settings";
		_settingsButton.icon = _settingsButtonIcon;
		_settingsButton.clickHandler = settingsClickHandler;
	}
	btns.addItem(_settingsButton);
	if (_infosButton == null) {
		_infosButton = new Object();
		_infosButton.toolTip = "Infos";
		_infosButton.name = "infos";
		_infosButton.icon = _infosButtonIcon;
		_infosButton.clickHandler = infosClickHandler;
	}
	btns.addItem(_infosButton);
	
	if (_clearButton == null) {
		_clearButton = new Object();
		_clearButton.toolTip = "Clear";
		_clearButton.name = "clear";
		_clearButton.icon = _clearButtonIcon;
		_clearButton.clickHandler = clearClickHandler;
	}
	btns.addItem(_clearButton);
	
	if (_urlButton == null) {
		_urlButton = new Object();
		_urlButton.toolTip = "Get URL for current search";
		_urlButton.name = "url";
		_urlButton.icon = _urlButtonIcon;
		_urlButton.clickHandler = urlClickHandler;
	}
	btns.addItem(_urlButton);

	return btns;
}

private function urlClickHandler(event:MouseEvent):void{
	var url:String = inputToURL();
	Clipboard.generalClipboard.clear();
	Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, url);
	Alert.show(url, "This URL has been saved to your clipboard");
}

private function clearClickHandler(event:MouseEvent):void {
	clear();
}

private function settingsClickHandler(event:MouseEvent):void {
	var pop:ExpertSettings = PopUpManager.createPopUp(this, ExpertSettings) as ExpertSettings;
}

private function infosClickHandler(event:MouseEvent):void {
	var pop:Infos = PopUpManager.createPopUp(this, Infos) as Infos;
}

[Bindable]
private var _examples:ArrayCollection = new ArrayCollection();

private function loadExample(o1:Object, o2:Object, ep:Object):void {
	
	var searchPossible:Boolean = true;
	
	if (ConnectionModel.getInstance().sparqlConfig.endpointURI.toString() != ep.uri.toString()) {
		var conf:IConfig = ConnectionModel.getInstance().getSPARQLByEndpointURI(ep.uri.toString());
		if (conf != null) {
			Alert.show("Your selected Endpoint was set to \"" + conf.name + "\".\nYou can change back the endpoint to \"" + ConnectionModel.getInstance().sparqlConfig.name + "\" in the settings menu.", "Endpoint changed", Alert.OK + Alert.NONMODAL);
			ConnectionModel.getInstance().sparqlConfig = conf;
		}else {
			searchPossible = false;
			Alert.show("The desired endpoint \"" + ep.uri + "\" was not specified in the configuration file.", "Endpoint not specified", Alert.OK);
		}
	}
	
	if (searchPossible) {
		//clear();
		tn.selectedChild = tab1;	//set current tab
		(inputField[0] as AutoComplete).selectedItem = o1;
		(inputField[1] as AutoComplete).selectedItem = o2;
		
		(inputField[0] as AutoComplete).validateNow();
		(inputField[1] as AutoComplete).validateNow();
		
		findRelations();
	}

}

public function loadExample2(example:Example):void {
	
	if (example == null || example.endpointConfig == null) {
		return;
	}
	
	var searchPossible:Boolean = true;
	
	// set endpoint config
	if (ConnectionModel.getInstance().sparqlConfig != example.endpointConfig) {
		if (example.endpointConfig != null) {
			Alert.show("Your selected Endpoint was set to \"" + example.endpointConfig.name + "\".\nYou can change back the endpoint to \"" + ConnectionModel.getInstance().sparqlConfig.name + "\" in the settings menu.", "Endpoint changed", Alert.OK + Alert.NONMODAL);
			ConnectionModel.getInstance().sparqlConfig = example.endpointConfig;
		}else {
			searchPossible = false;
			Alert.show("The desired endpoint \"" + example.endpointConfig.endpointURI + "\" was not specified in the configuration file.", "Endpoint not specified", Alert.OK);
		}
	}
	
	if (searchPossible) {
		
		tn.selectedChild = tab1;	//set current tab
		
		// set number of input fields
		if (inputFieldBox.dataProvider.length != example.objects.length) {
			
			if (inputFieldBox.dataProvider.length < example.objects.length) {
				// add fields
				
				while (inputFieldBox.dataProvider.length < example.objects.length) {
					inputFieldBox.addNewInputField();
				}
			}else {
				// remove fields
				while (inputFieldBox.dataProvider.length > example.objects.length && inputFieldBox.dataProvider.length > 2) {
					inputFieldBox.removeInputField(inputFieldBox.dataProvider.length - 1);
				}
			}
			
		}
		
		for (var i:int = 0; i < example.objects.length; i++) {
			(inputField[i] as AutoComplete).selectedItem = (example.objects as ArrayCollection).getItemAt(i);
			(inputField[i] as AutoComplete).validateNow();
		}
		
		if (example.objects.length >= 2) {
			findRelations();
		}
	}
}

private function autoDisambiguate(ac:AutoComplete):Boolean {
	var input:String = ac.searchText;
	var dp:ArrayCollection = ac.dataProvider;
	
	if (input.toLowerCase().indexOf("http://") == 0 || input.toLowerCase().indexOf("https://") == 0) {
		var result:Object = new Object();
		result.label = input;
		result.uris = new Array(input);
		ac.selectedItem = result;
		ac.validateNow();
		return true;
	}
	
	trace("auto disambiguate: " + input);
	trace("searching for direct match");
	for each (var obj:Object in dp) {
		if ((StringUtil.trim(obj.label)).toLowerCase() == (StringUtil.trim(input)).toLowerCase()) {
			
			//check if count from matching object is high enaugh for a dirct match
			var o:Object = dp.getItemAt(0);
			if (o != null && o.hasOwnProperty("count") && obj != null && obj.hasOwnProperty("count")) {
				 //if count of obj is not much lower than count of o, take obj as selected item
				if (o.count / obj.count < 5) {
					ac.selectedItem = obj;
					ac.validateNow();
					trace("disambiguated by direct match. relation between found item and 1st item in list = " + o.count / obj.count + " found item will be taken as selected object");
					return true;
				}else {
					trace("no disambiguation by direct match. relation between found item and 1st item to low = " + o.count / obj.count);
					return false;
				}
			}
		}
	}
	trace("no direct match found");
	
	// results of this method weren't really satisfying, so it was disabled
	// enabled again with a higher ratio
	trace("checking count");
	if (dp.length >= 2) {
		var o1:Object = dp.getItemAt(0);
		var o2:Object = dp.getItemAt(1);
		
		if (o1 != null && o1.hasOwnProperty("count") && o2 != null && o2.hasOwnProperty("count")) {
			 //if count of o1 is much higher than count of o2, take o1 as selected item
			if (o1.count / o2.count > 20) {
				ac.selectedItem = o1;
				ac.validateNow();
				trace("disambiguated by count. relation between 1st and 2nd item = " + o1.count / o2.count + " 1st item will be taken as selected object");
				return true;
			}else {
				trace("no disambiguation by count. relation between 1st and 2nd item to low = " + o1.count / o2.count);
				return false;
			}
		}
	}
	trace("no auto disambiguation possible");
	
	return false;
}



public function findRelations():void {
	
	//removeEmptyInputFields();
	
	if (graphModel.givenNodes.isEmpty()) {
		findRelationsImmediately();
	}else {
		Alert.show("Do you want to clear all old results before searching for new relations?", "Clear", Alert.YES + Alert.NO, this, dispatchCloseEvent);
	}
}
		
private function dispatchCloseEvent(event:CloseEvent):void {
	if (event.detail == Alert.YES) {
		
		clearGraph();
		
		callLater(findRelationsImmediately);
		
	}else if (event.detail == Alert.NO) {
		findRelationsImmediately();
	}
}	

private function findRelationsImmediately():void {
	
	if (!isInputValid()) {
		for (var j:int = 0; j < inputFieldRepeater.dataProvider.length; j++) {
			trace((inputField[j] as AutoComplete).selectedItem);
			if (!((inputField[j] as AutoComplete).selectedItem && (inputField[j] as AutoComplete).selectedItem.hasOwnProperty('uris'))) {
				
				var select:Object = getInputFromAC(j);
				
				if (select != null) {
					(inputField[j] as AutoComplete).selectedItem = select;
					(inputField[j] as AutoComplete).validateNow();
				}else {
					
					var success:Boolean = autoDisambiguate(inputField[j] as AutoComplete);
					
					if (!success) {
						var pop:InputSelection = PopUpManager.createPopUp(inputFieldBox, InputSelection) as InputSelection;
						pop.inputIndex = j;
						pop.dataProvider = (inputField[j] as AutoComplete).dataProvider;
						pop.inputText = (inputField[j] as AutoComplete).searchText;
						pop.msgText = "Your input is not clear.\nPlease select a resource from the list or check your input for spelling mistakes.";
						pop.addEventListener(InputSelectionEvent.INPUTSELECTION, inputSelectionWindowHandler);
						break;
					}
				}
			}
		}
	}
	
	if (isInputValid()) {
		
		_showOptions = true; 	//sets the filters visible
		
		if (isInputUnique()) {
			var betArr:Array = new Array();
			
			lastInputs = new Array();
			
			for (var i:int = 0; i < inputFieldRepeater.dataProvider.length; i++) {
				if ((inputField[i] as AutoComplete).selectedItem.hasOwnProperty("tempUri") && (inputField[i] as AutoComplete).selectedItem.tempUri != null) {
					
					var o1:Object = new Object();
					o1.label = (inputField[i] as AutoComplete).selectedItem.label;
					o1.uri = (inputField[i] as AutoComplete).selectedItem.tempUri;
					lastInputs.push(o1);
					
					betArr.push((inputField[i] as AutoComplete).selectedItem.tempUri);
					(inputField[i] as AutoComplete).selectedItem.tempUri = null;
				}else {
					
					var o2:Object = new Object();
					o2.label = (inputField[i] as AutoComplete).selectedItem.label;
					o2.uri = ((inputField[i] as AutoComplete).selectedItem.uris as Array)[0];
					lastInputs.push(o2);
					
					betArr.push(((inputField[i] as AutoComplete).selectedItem.uris as Array)[0]);
				}
			}
			
			var between:ArrayCollection = new ArrayCollection(betArr);
			
			myConnection.findRelations(between, 10, ConnectionModel.getInstance().sparqlConfig.maxRelationLength + 1, resultParser);
			
			graphModel.delayedDrawing = true;
			
		}else {
			// disambiguate
			for (var k:int = 0; k < inputFieldRepeater.dataProvider.length; k++) {
				// no tempURI
				if (!((inputField[k] as AutoComplete).selectedItem.hasOwnProperty("tempUri") && (inputField[i] as AutoComplete).selectedItem.tempUri != null)) {
					// several URIs
					if (!((inputField[k] as AutoComplete).selectedItem && (inputField[k] as AutoComplete).selectedItem.hasOwnProperty('uris') && ((inputField[k] as AutoComplete).selectedItem.uris as Array).length == 1)) {
						var disambiguation:InputDisambiguation = PopUpManager.createPopUp(inputFieldBox, InputDisambiguation) as InputDisambiguation;
						disambiguation.inputIndex = k;
						disambiguation.inputItem = (inputField[k] as AutoComplete).selectedItem;
						disambiguation.addEventListener("Disambiguation", inputDisambiguationWindowHandler);
						break;
					}
				}
			}
		}
	}
}

private function getInputFromAC(acIndex:int):Object {
	for each (var o:Object in (inputField[acIndex] as AutoComplete).dataProvider) {
		
		if (o.hasOwnProperty("label") && o.hasOwnProperty("uri") && (inputField[acIndex] as AutoComplete) != null &&
				o.label.toString().toLowerCase() == (inputField[acIndex] as AutoComplete).searchText.toString().toLowerCase()) {
			return o;
		}
	}
	return null;
}

private function inputDisambiguationWindowHandler(event:Event):void {
	findRelationsImmediately();
}

private function inputSelectionWindowHandler(event:InputSelectionEvent):void {
	(inputField[event.autoCompleteIndex] as AutoComplete).selectedItem = event.selectedItem;
	(inputField[event.autoCompleteIndex] as AutoComplete).validateNow();
	findRelationsImmediately();
}

private function isInputUnique():Boolean {
	var unique:Boolean = true;
	
	for (var i:int = 0; i < inputFieldRepeater.dataProvider.length; i++) {
		unique = (unique && (inputField[i] as AutoComplete).selectedItem && (inputField[i] as AutoComplete).selectedItem.hasOwnProperty('uris') && ((inputField[i] as AutoComplete).selectedItem.uris as Array).length == 1)
			|| (unique && (inputField[i] as AutoComplete).selectedItem && (inputField[i] as AutoComplete).selectedItem.hasOwnProperty('tempUri') && (inputField[i] as AutoComplete).selectedItem.tempUri != null);
	}
	
	return unique;
}

private function isInputValid():Boolean {
	var valid:Boolean = true;
	
	for (var i:int = 0; i < inputFieldRepeater.dataProvider.length; i++) {
		valid = valid && (inputField[i] as AutoComplete).selectedItem && (inputField[i] as AutoComplete).selectedItem.hasOwnProperty('uris');
	}
	
	return valid;
}

private function replaceWhitspaces(str:String):String {
	return str.split(" ").join("_");
}

public function setAutoCompleteList(_list:ArrayCollection):void {
	autoCompleteList = _list;
}

private function get inputField():Array {
	return inputFieldBox.inputField;
}

private function get inputFieldRepeater():Repeater {
	return inputFieldBox.inputFieldRepeater;
}

private function showErrorLog():void {
	var log:ErrorLog = PopUpManager.createPopUp(Application.application as DisplayObject, ErrorLog, false) as ErrorLog;
}

private function numColumnCompareFunction(itemA:Object, itemB:Object):int {
	
	if (itemA is PathLength && itemB is PathLength) {
		return internalNumColumnStringCompareFunction((itemA as PathLength).stringNumOfPaths, (itemB as PathLength).stringNumOfPaths);
	}
	
	if (itemA is RelType && itemB is RelType) {
		return internalNumColumnStringCompareFunction((itemA as RelType).stringNumOfRelations, (itemB as RelType).stringNumOfRelations);
	}
	
	if (itemA is Concept && itemB is Concept) {
		return internalNumColumnStringCompareFunction((itemA as Concept).stringNumOfElements, (itemB as Concept).stringNumOfElements);
	}
	
	if (itemA is ConnectivityLevel && itemB is ConnectivityLevel) {
		return internalNumColumnStringCompareFunction((itemA as ConnectivityLevel).stringNumOfElements, (itemB as ConnectivityLevel).stringNumOfElements);
	}
	
	return 0;
}

private function internalNumColumnStringCompareFunction(str1:String, str2:String):int {
	if ((str1 == null || str1 == "" || str1.indexOf("/") < 0) && (str2 == null || str2 == "" || str2.indexOf("/") < 0)) {
		return 0;
	}else if (str1 == null || str1 == "" || str1.indexOf("/") < 0) {
		return 1;
	}else if (str2 == null || str2 == "" || str2.indexOf("/") < 0) {
		return -1;
	}
	
	var val1:Array = str1.split("/");
	var val2:Array = str2.split("/");
	
	val1[0] = new int(val1[0]);
	val1[1] = new int(val1[1]);
	val2[0] = new int(val2[0]);
	val2[1] = new int(val2[1]);
	
	if (isNaN(val1[1]) && isNaN(val2[1]))
		return 0;
	
	if (isNaN(val1[1]))
		return 1;

	if (isNaN(val2[1]))
	   return -1;

	if (val1[1] < val2[1])
		return -1;

	if (val1[1] > val2[1])
		return 1;

	return 0;
}