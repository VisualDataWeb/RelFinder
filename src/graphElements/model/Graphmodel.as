package graphElements.model 
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	import de.polygonal.ds.ArrayedQueue;
	import de.polygonal.ds.HashMap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import global.StatusModel;
	import graphElements.Concept;
	import graphElements.ConnectivityLevel;
	import graphElements.Element;
	import graphElements.FoundNode;
	import graphElements.GivenNode;
	import graphElements.MyNode;
	import graphElements.Path;
	import graphElements.PathLength;
	import graphElements.Relation;
	import graphElements.RelationNode;
	import graphElements.RelType;
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.core.Application;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	[Bindable(event="GRAPH_MODEL_PROPERTY_CHANGED")]
	public class Graphmodel extends EventDispatcher
	{
		
		public static const GRAPH_MODEL_PROPERTY_CHANGED:String = "GRAPH_MODEL_PROPERTY_CHANGED";
		public static const ZOOM_COMPLETE:int = 0;
		public static const ZOOM_AGGREGATED_EDGES:int = 1;
		public static const ZOOM_AGGREGATED_NODES:int = 2;
		
		public static var graphIsFullValue:int = 10;
		
		[Bindable]
		private var _completeGraph:Graph = new Graph();
		private var _foundNodes:HashMap = new HashMap();
		private var _givenNodes:HashMap = new HashMap();
		private var _givenNodesInsertionTime:HashMap = new HashMap();
		private var _relationNodes:HashMap = new HashMap();
		private var _relations:HashMap = new HashMap();
		private var _elements:HashMap = new HashMap();
		private var _toDrawPaths:ArrayedQueue = new ArrayedQueue(1000);
		
		private var _graphIsFull:Boolean = false;
		private var _delayedDrawing:Boolean = true;
		
		private var _paths:HashMap = new HashMap();
		
		[Bindable]
		public var concepts:ArrayCollection = new ArrayCollection();
		private var _selectedConcept:Concept = null;

		[Bindable]
		public var connectivityLevels:ArrayCollection = new ArrayCollection();
		private var _selectedConnectivityLevel:ConnectivityLevel = null;

		[Bindable]
		public var relTypes:ArrayCollection = new ArrayCollection();
		private var _selectedRelType:RelType = null;
		
		[Bindable]
		public var pathLengths:ArrayCollection = new ArrayCollection();
		private var _selectedPathLength:PathLength = null;
		
		private var _zoomFactor:int = ZOOM_COMPLETE;
		
		private static var instance:Graphmodel;
		
		public function Graphmodel(singleton:SingletonEnforcer) 
		{
			
		}
		
		public static function getInstance():Graphmodel{
			if (Graphmodel.instance == null){
				Graphmodel.instance = new Graphmodel(new SingletonEnforcer());
				
			}
			return Graphmodel.instance;
		}
		
		public function clear():void {
			_completeGraph = new Graph();
			_selectedConnectivityLevel = null;
			_selectedConcept = null;
			_selectedPathLength = null;
			_selectedRelType = null;
			_selectedConnectivityLevel = null;
			_graphIsFull = false;	//whether the graph is overcluttered already!
			_delayedDrawing = true;
			
			_relationNodes = new HashMap();
			_foundNodes = new HashMap();
			_givenNodes = new HashMap();
			
			_toDrawPaths = new ArrayedQueue(1000);
			_timer.stop();
			_timer.delay = 2000;
			
			connectivityLevels = new ArrayCollection();
			pathLengths = new ArrayCollection();
			concepts = new ArrayCollection();
			relTypes = new ArrayCollection();
			
			_paths = new HashMap();
			_relations = new HashMap();
			_elements = new HashMap();
		}
		
		[Bindable(event = "zoomFactorChange")]
		public function get zoomFactor():int {
			return _zoomFactor;
		}
		
		public function set zoomFactor(value:int):void {
			trace(value);
			_zoomFactor = value;
			dispatchEvent(new Event("zoomFactorChange"));
		}

		
		[Bindable(event="changed")]
		public function get graph():Graph {
			return _completeGraph;
		}
		
		public function set graph(value:Graph):void {
			_completeGraph = value;
			dispatchEvent(new Event("changed"));
		}
		
		public function get elements():HashMap {
			return _elements;
		}
		
		public function get foundNodes():HashMap {
			return _foundNodes;
		}
		
		public function get givenNodes():HashMap {
			return _givenNodes;
		}
		
		public function get paths():HashMap {
			return _paths;
		}
		
		public function get relations():HashMap {
			return _relations;
		}
		
		
		[Bindable(event="delayedDrawingChanged")]
		public function get delayedDrawing():Boolean {
			return _delayedDrawing;
		}

		public function set delayedDrawing(b:Boolean):void {
			if (_delayedDrawing != b) {
				_delayedDrawing = b;
				
				if (_delayedDrawing) {
					_timer.delay = 2000;
				}else {
					_timer.delay = 100;	//make the drawing fast!
				}
				
				dispatchEvent(new Event("delayedDrawingChanged"));
				dispatchEvent(new Event("GRAPH_MODEL_PROPERTY_CHANGED"));
			}
		}
		
		public function getElement(id:String, resourceURI:String, label:String, isPredicate:Boolean = false,
				abstract:Dictionary = null, imageURL:String = "", linkToWikipedia:String = ""):Element {
			
			//WARNING: This is just a workaround!! It should get index by its id instead of by its label!!
			
			//what was the reason for this workaround?
			//changed it back to id!!! needed for autocomplete tooltip (Timo)
			
			//ok, its not working properly if predicates are indexed by its id. So we are using label, if its a predicate (Timo)
			if (isPredicate) {
				if (!_elements.containsKey(label)) {
					var e:Element = new Element(label, resourceURI, label, isPredicate, abstract, imageURL, linkToWikipedia);
					_elements.insert(label, e);
				}
				return _elements.find(label);
			}else {
				if (!_elements.containsKey(id)) {
					var e2:Element = new Element(id, resourceURI, label, isPredicate, abstract, imageURL, linkToWikipedia);
					_elements.insert(id, e2);
				}
				return _elements.find(id);
			}
		}
		
		public function getPath(pathId:String, pathRelations:Array):Path {
			if (!_paths.containsKey(pathId)) {
				var pL:PathLength = getPathLength(pathRelations.length.toString(), pathRelations.length - 1);
				var newPath:Path = new Path(pathId, pathRelations, pL);
				
				_paths.insert(pathId, newPath);
				
				if (!_graphIsFull) {
						if (_paths.size > graphIsFullValue) {
							//trace("graph is full!!!");
							_graphIsFull = true;
						}else {
							
						}
				}
			}
			return _paths.find(pathId);
		}
		
		public function getConcept(uri:String, label:String):Concept {
			//trace("getConcept : " + uri);
			for each(var c:Concept in concepts) {
				if (c.id == uri) {
					
					return c;
				}
			}
			//trace("build new concpet " + uri);
			var newC:Concept = new Concept(uri, label);
			concepts.addItem(newC);
			newC.addEventListener(Concept.NUMVECHANGE, conceptChangeListener);
			newC.addEventListener(Concept.VCHANGE, conceptChangeListener);
			newC.addEventListener(Concept.ELEMENTNUMBERCHANGE, conceptChangeListener);
			
			concepts.refresh();
			return newC;
		}

		private function conceptChangeListener(event:Event):void {
			var c:Concept = event.target as Concept;
			
			if (event.type == Concept.ELEMENTNUMBERCHANGE) {
				if (app.dgC != null) {
					//(dgC as SortableDataGrid).sortByColumn();
					
					concepts.itemUpdated(c);
				}
			}else {
				if (app.dgC != null) {
					(app.dgC as DataGrid).invalidateList();
				}
			}
			
			//check filter sign
			if (app.tab12.isVisible) {
				if ((!c.isVisible) && c.canBeChanged) {
					app.tab12.isVisible = false; //.icon = filterSign;
				}
			}else {
				var noFilters:Boolean = true;
				for each(var c1:Concept in concepts) {
					if ((!c1.isVisible) && c1.canBeChanged) {
						noFilters = false;	//there is at least one filter!
						break;
					}
				}
				if (noFilters) {
					app.tab12.isVisible = true; // icon = null;
				}
			}
		}

		[Bindable(event="selectedConceptChange")]
		public function get selectedConcept():Concept {
			return _selectedConcept;
		}

		public function set selectedConcept(c:Concept):void {
			if (_selectedConcept != c) {
				//trace("selectedConcept change "+c.id);
				
				//deselect all other selections
				selectedRelType = null;
				selectedPathLength = null;
				selectedConnectivityLevel = null;
				
				_selectedConcept = c;
				dispatchEvent(new Event("selectedConceptChange"));
			}
		}
		
		/** RelTypes **/
		public function getRelType(uri:String, label:String):RelType {
			//trace("getConcept : " + uri);
			for each(var r:RelType in relTypes) {
				if (r.id == uri) {
					
					return r;
				}
			}
			//trace("build new reltype " + uri);
			var newR:RelType = new RelType(uri, label);
			relTypes.addItem(newR);
			newR.addEventListener(RelType.NUMVRCHANGE, relTypeChangeListener);
			newR.addEventListener(RelType.VCHANGE, relTypeChangeListener);
			newR.addEventListener(RelType.ELEMENTNUMBERCHANGE, relTypeChangeListener);
			
			if (_graphIsFull) {
				//trace("------------------graphISFULLL -> relType setVisible=false");
				newR.isVisible = false;
			}
			relTypes.refresh();
			return newR;
		}

		private function relTypeChangeListener(event:Event):void {
			
			var rT:RelType = event.target as RelType;
			
			if (event.type == RelType.ELEMENTNUMBERCHANGE) {
				if (app.dgT != null) {
					//(dgT as SortableDataGrid).sortByColumn();
					
					relTypes.itemUpdated(rT);
				}
			}else {
				if (app.dgT != null) {
					(app.dgT as DataGrid).invalidateList();
				}
			}
			
			//trace("relTypes update : " +rT.numVisibleRelations);
			//_relTypes.itemUpdated(rT);
			//if (dgT != null) {
				//(dgT as DataGrid).invalidateList();
			//}
			
			//check filter sign
			if (app.tab13.isVisible) {
				if ((!rT.isVisible) && rT.canBeChanged) {
					app.tab13.isVisible = false; // icon = filterSign;
				}
			}else {
				var noFilters:Boolean = true;
				for each(var rT1:RelType in relTypes) {
					if ((!rT1.isVisible) && rT1.canBeChanged) {
						noFilters = false;	//there is at least one filter!
						break;
					}
				}
				if (noFilters) {
					app.tab13.isVisible = true; // icon = null;
				}
			}
		}

		[Bindable]
		public function get selectedRelType():RelType {
			return _selectedRelType;
		}

		public function set selectedRelType(r:RelType):void {
			if (_selectedRelType != r) {
				//trace("selectedConcept change "+c.id);
				
				//deselect all other selections
				selectedConcept = null;
				selectedPathLength = null;
				selectedConnectivityLevel = null;
				
				_selectedRelType = r;
				//dispatchEvent(new Event("selectedConceptChange"));
			}
		}



		/** ConnectivityLevels **/

		public function getConnectivityLevel(id:String, num:int):ConnectivityLevel {
			//trace("getConcept : " + uri);
			for each(var cL:ConnectivityLevel in connectivityLevels) {
				if (cL.id == id) {
					
					return cL;
				}
			}
			//trace("build new conLevel " + id);
			var newCL:ConnectivityLevel = new ConnectivityLevel(id, num);
			connectivityLevels.addItem(newCL);
			newCL.addEventListener(ConnectivityLevel.NUMVECHANGE, conLevelChangeListener);
			newCL.addEventListener(ConnectivityLevel.VCHANGE, conLevelChangeListener);
			newCL.addEventListener(ConnectivityLevel.ELEMENTNUMBERCHANGE, conLevelChangeListener);
			/*if (_graphIsFull) {
				trace("------------------graphISFULLL -> relType setVisible=false");
				newR.isVisible = false;
			}*/
			connectivityLevels.refresh();
			return newCL;
		}

		private function conLevelChangeListener(event:Event):void {
			var cL:ConnectivityLevel = event.target as ConnectivityLevel;
			
			if (event.type == ConnectivityLevel.ELEMENTNUMBERCHANGE) {
				if (app.dgCc != null) {
					//(dgCc as SortableDataGrid).sortByColumn();
					
					connectivityLevels.itemUpdated(cL);
				}
			}else {
				if (app.dgCc != null) {
					(app.dgCc as DataGrid).invalidateList();
				}
			}
			
			//_connectivityLevels.itemUpdated(cL);
			//if (dgCc != null) {
				//(dgCc as DataGrid).invalidateList();
			//}
			
			//check filter sign
			if (app.tab11.isVisible) {	//no filters are registered
				if ((!cL.isVisible) && cL.canBeChanged) {
					app.tab11.isVisible = false;	// icon = filterSign;
				}
			}else {
				var noFilters:Boolean = true;
				for each(var cL1:ConnectivityLevel in connectivityLevels) {
					if ((!cL1.isVisible) && cL1.canBeChanged) {
						noFilters = false;	//there is at least one filter!
						break;
					}
				}
				if (noFilters) {
					app.tab11.isVisible = true; //tab10.icon = null;
				}
			}
		}

		[Bindable(event="selectedConnectivityLevelChange")]
		public function get selectedConnectivityLevel():ConnectivityLevel {
			return _selectedConnectivityLevel;
		}

		public function set selectedConnectivityLevel(cL:ConnectivityLevel):void {
			if (_selectedConnectivityLevel != cL) {
				//trace("selectedConcept change "+c.id);
				
				//deselect all other selections
				selectedRelType = null;
				selectedConcept = null;
				selectedPathLength = null;
				
				_selectedConnectivityLevel = cL;
				
				dispatchEvent(new Event("selectedConnectivityLevelChange"));
			}
		}

		/** PathLenghts **/
		public function getPathLength(uri:String, length:int):PathLength {
			for each(var pL:PathLength in pathLengths) {
				if (pL.id == uri) {
					
					return pL;
				}
			}
			//trace("build new concpet " + uri);
			var newPL:PathLength = new PathLength(uri, length);
			pathLengths.addItem(newPL);
			newPL.addEventListener(PathLength.NUMVPCHANGE, pathLengthChangeListener);
			newPL.addEventListener(PathLength.VCHANGE, pathLengthChangeListener);
			newPL.addEventListener(PathLength.ELEMENTNUMBERCHANGE, pathLengthChangeListener);
			if (_graphIsFull) {
				//set new pathLength invisible
				newPL.isVisible = false;
			}
			pathLengths.refresh();
			return newPL;
		}

		private function pathLengthChangeListener(event:Event):void {
			var pL:PathLength = event.target as PathLength;
			
			if (event.type == PathLength.ELEMENTNUMBERCHANGE) {
				if (app.dgL != null) {
					pathLengths.itemUpdated(pL);
				}
			}else {
				if (app.dgL != null) {
					(app.dgL as DataGrid).invalidateList();
				}
			}
			
			//check filter sign
			if (app.tab10.isVisible) {	//no filters are registered
				if ((!pL.isVisible) && pL.canBeChanged) {
					app.tab10.isVisible = false;	// icon = filterSign;
				}
			}else {
				var noFilters:Boolean = true;
				for each(var pL1:PathLength in pathLengths) {
					if ((!pL1.isVisible) && pL1.canBeChanged) {
						noFilters = false;	//there is at least one filter!
						break;
					}
				}
				if (noFilters) {
					app.tab10.isVisible = true; //tab10.icon = null;
				}
			}
			
			dispatchEvent(new Event("RelationCountChanged"));
		}

		[Bindable]
		public function get selectedPathLength():PathLength {
			return _selectedPathLength;
		}

		public function set selectedPathLength(p:PathLength):void {
			if (_selectedPathLength != p) {
				//trace("selectedConcept change "+c.id);
				
				//deselect all other selections
				selectedRelType = null;
				selectedConcept = null;
				selectedConnectivityLevel = null;
				
				_selectedPathLength = p;
				//dispatchEvent(new Event("selectedConceptChange"));
			}
		}
		
		public function getRelation(subject:Element, predicate:Element, object:Element):Relation {
			var relId:String = subject.id + predicate.id + object.id;
			if (!_relations.containsKey(relId)) {
				var rT:RelType = getRelType(predicate.id, predicate.label);
				var newRel:Relation = new Relation(relId, subject, predicate, object, rT);
				_relations.insert(relId, newRel);
			}
			return _relations.find(relId);
		}
		
		public function getGivenNode(uri:String, element:Element):GivenNode {
			if (!_givenNodes.containsKey(uri)) {
				var newGivenNode:GivenNode = new GivenNode(uri, element);
				_givenNodes.insert(uri, newGivenNode);
				_givenNodesInsertionTime.insert(uri, new Date());
				
				var givenNodesArray:Array = new Array();
				
				var keys:Array = _givenNodesInsertionTime.getKeySet();
				
				for each(var uriStr:String in keys) {
					if (_givenNodes.containsKey(uriStr)) {
						givenNodesArray.push({time:(_givenNodesInsertionTime.find(uriStr) as Date).time, node:_givenNodes.find(uriStr)});
					}
				}
				
				givenNodesArray.sortOn("time", Array.NUMERIC);
				
				addNodeToGraph(newGivenNode);
				
				var angle:Number = 360 / givenNodesArray.length;
				var centerX:Number = app.sGraph.width / 2;
				var centerY:Number = app.sGraph.height / 2
				//var radius:Number = Math.min(centerX - 80, centerY - 40);
				var a:Number = centerX - 120;
				var b:Number = centerY - 60;
				
				for (var i:int = 0; i < givenNodesArray.length; i++) {
					if ((givenNodesArray[i].node as GivenNode).getX() == 0 && (givenNodesArray[i].node as GivenNode).getY() == 0) {
						// Ellipse
						(givenNodesArray[i].node as GivenNode).setPosition(a * Math.cos((i * angle - 180) * (Math.PI / 180)) + centerX, b * Math.sin((i * angle - 180) * (Math.PI / 180)) + centerY);
						// Circle
						//(givenNodesArray[i].node as GivenNode).setPosition( (radius) * Math.sin((i * angle - 90) * (Math.PI / 180)) + centerX, (-radius) * Math.cos((i * angle - 90) * (Math.PI / 180)) + centerY);
					}else {
						// Ellipse
						moveNodeToPosition((givenNodesArray[i].node as GivenNode), a * Math.cos((i * angle - 180) * (Math.PI / 180)) + centerX, b * Math.sin((i * angle - 180) * (Math.PI / 180)) + centerY);
						// Circle
						//moveNodeToPosition((givenNodesArray[i].node as GivenNode), (radius) * Math.sin((i * angle - 90) * (Math.PI / 180)) + centerX, ( -radius) * Math.cos((i * angle - 90) * (Math.PI / 180)) + centerY);
					}
				}
				
			}
			return _givenNodes.find(uri);
		}
		
		public function moveNodeToPosition(node:GivenNode, x:Number, y:Number):void {
			(node as GivenNode).moveToPosition(x, y);
		}
		
		public function getInstanceNode(id:String, element:Element):MyNode {
			if (_givenNodes.containsKey(id)) {	//if the node is a given node!
				
				return _givenNodes.find(id) as MyNode;
			}
			if (!_foundNodes.containsKey(id)) {
				var newFoundNode:FoundNode = new FoundNode(id, element);
				_foundNodes.insert(id, newFoundNode);
				addNodeToGraph(newFoundNode);
			}
			return _foundNodes.find(id) as MyNode;
		}
		
		public function getRelationNode(id:String, relation:Relation):RelationNode {
			if (!_relationNodes.containsKey(id)) {
				var newRelationNode:RelationNode = new RelationNode(id, relation);
				_relationNodes.insert(id, newRelationNode);
				addNodeToGraph(newRelationNode);
			}
			return _relationNodes.find(id);
		}
		
		
		private function addRelationToGraph(subjectNode:MyNode, predicateNode:MyNode, objectNode:MyNode, layout:Object = null):void {
			
			var object1:Object = new Object();
			object1.startId = subjectNode.id;	//defines the direction of the link!
			if (layout != null) object1.settings = layout.settings;
			_completeGraph.link(subjectNode, predicateNode, object1);
			
			var object2:Object = new Object();
			object2.startId = predicateNode.id;
			if (layout != null) object2.settings = layout.settings;
			_completeGraph.link(predicateNode, objectNode, object2);
			
		}
		
		private function addNodeToGraph(node:MyNode):void {
			_completeGraph.add(node);
			node.element.isVisible = true;
		}
		
		public function hideNode(node:MyNode):void {
			if (_completeGraph.hasNode(node.id)) {	//if part of the graph
				removeNodeFromGraph(node);
			}
		}
		
		public function showNode(node:MyNode):void {
			//TODO: Relationen wieder aufbauen!
			addNodeToGraph(node);
		}
		
		private function removeNodeFromGraph(node:MyNode):void {	//TODO: the whole connection must be removed too! And the relation!
			node.element.isVisible = false;
			_completeGraph.remove(node);
		}
		
		public function drawPath(p:Path, immediatly:Boolean = false):void {
			
			if (delayedDrawing && !immediatly) {
				_toDrawPaths.enqueue(p);
				startDrawing();
			}else {
				for each(var r:Relation in p.relations) {
					drawRelation(r, p.layout);
				}
			}
			
		}
		
		private function drawRelation(r:Relation, layout:Object = null):void {
			
			var subject:Element = r.subject;
			var object:Element = r.object;
			var predicate:Element = r.predicate;
			
			var subjectNode:MyNode = getInstanceNode(subject.id, subject);
			if (!_completeGraph.hasNode(subjectNode.id)) {
				showNode(subjectNode);
			}
			
			var predicateNode:RelationNode = getRelationNode(r.id, r); //important: _r.id and not _r.predicate.id!!
			if (!_completeGraph.hasNode(predicateNode.id)) {
				showNode(predicateNode);
			}
			
			var objectNode:MyNode = getInstanceNode(object.id, object);
			if (!_completeGraph.hasNode(objectNode.id)) {
				showNode(objectNode);
			}
			
			addRelationToGraph(subjectNode, predicateNode, objectNode, layout);
		}
		
		//--Delayed Drawing----------------------
		private var _timer:Timer = new Timer(2000);
		public function startDrawing():void {
			//timer = new Timer(2000, results.length);
			if (!_timer.running) {
				_timer.addEventListener(TimerEvent.TIMER, drawNextPath);
				//trace("start timer");
				_timer.start();
				StatusModel.getInstance().queueIsEmpty = false;
				//trace("timer start");
			}
		}
		
		private function drawNextPath(event:Event):void {
			if (_toDrawPaths.isEmpty()) {
				_timer.stop();
				StatusModel.getInstance().queueIsEmpty = true;	//TODO: direkt an toDrawPaths.isEmpty mit EventListener binden!
				//trace("timer stop");
			}else {
				
				var p:Path = _toDrawPaths.dequeue();
				if (!p.isVisible) {	//if it is not visible, try the next one
					drawNextPath(null);
				}else {
					for each(var r:Relation in p.relations) {
						drawRelation(r, p.layout);
					}
				}
				
			}
		}
		
		[Bindable(event="RelationCountChanged")]
		public function getRelationCountInfo():String {
			var all:int = 0;
			var visible:int = 0;
			for each(var pl:PathLength in pathLengths) {
				all += (pl as PathLength).numAllPaths;
				visible += (pl as PathLength).numVisiblePaths;
			}
			return "(" + visible + "/" + all + ")";
		}
		
		private function get app():Main {
			return Application.application as Main;
		}
	}
}
class SingletonEnforcer{}