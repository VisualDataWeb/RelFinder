package graphElements.model 
{
	import com.adobe.flex.extras.controls.springgraph.Graph;
	import de.polygonal.ds.ArrayedQueue;
	import de.polygonal.ds.HashMap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import graphElements.Element;
	import graphElements.FoundNode;
	import graphElements.GivenNode;
	import graphElements.MyNode;
	import graphElements.Relation;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class Graphmodel extends EventDispatcher
	{
		
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
		
		private var _paths:HashMap = new HashMap();
		
		public function Graphmodel() 
		{
			
		}
		
		[Bindable(event="changed")]
		public function get graph():Graph {
			return _completeGraph;
		}
		
		public function set graph(value:Graph):void {
			_completeGraph = value;
			dispatchEvent(new Event("changed"));
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
							trace("graph is full!!!");
							_graphIsFull = true;
						}else {
							
						}
				}
				
				
			}
			return _paths.find(pathId);
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
				var centerX:Number = this.sGraph.width / 2;
				var centerY:Number = this.sGraph.height / 2
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
			return givenNodes.find(_uri);
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
				toDrawPaths.enqueue(p);
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
		
		
		
	}

}