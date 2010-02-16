package graphElements.controller 
{
	import com.adobe.flex.extras.controls.springgraph.Item;
	import graphElements.AggregatableElement;
	import graphElements.Element;
	import graphElements.model.Graphmodel;
	import graphElements.MyNode;
	import graphElements.Path;
	import graphElements.Relation;
	import graphElements.RelationNode;
	import mx.utils.ObjectUtil;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class GraphController
	{
		
		private static var graphmodel:Graphmodel = Graphmodel.getInstance();
		
		public function GraphController() 
		{
			
		}
		
		
		public static function collapseAllParallelRelationNodes():void {
			
			var relations:Array = graphmodel.relations.toArray();
			var relation:Relation = null;
			var keySet:Array = graphmodel.relations.getKeySet();
			
			for (var k:int = 0; k < keySet.length; k++) {
				if (graphmodel.relations.find(keySet[k]) is Relation) {
					relation = graphmodel.relations.find(keySet[k]) as Relation;
					
					if (relation.predicate != null && relation.predicate.aggregationRoot != null && relation.predicate.aggregationLeefs == null) {
						
						relation.predicate.isAggregatedInRoot = true;
						
						for each (var path:Path in relation.paths) {
							path.isVisible = false;
						}
						
					}
					
				}
			}
		}
		
		public static function expandAllParallelRelationNodes():void {
			var relations:Array = graphmodel.relations.toArray();
			var relation:Relation = null;
			var keySet:Array = graphmodel.relations.getKeySet();
			
			for (var k:int = 0; k < keySet.length; k++) {
				if (graphmodel.relations.find(keySet[k]) is Relation) {
					relation = graphmodel.relations.find(keySet[k]) as Relation;
					
					if (relation.predicate != null && relation.predicate.aggregationRoot != null && relation.predicate.aggregationLeefs == null) {
						
						relation.predicate.isAggregatedInRoot = false;
						
						for each (var path:Path in relation.paths) {
							path.isVisible = true;
						}
						
					}
					
				}
			}
		}
		
		public static function expandRelationNode(relationNode:Element):void {
			
			
			//var relations:Array = graphmodel.relations.toArray();
			//var relation:Relation = null;
			//var keySet:Array = graphmodel.relations.getKeySet();
			//
			//for (var k:int = 0; k < keySet.length; k++) {
				//if (graphmodel.relations.find(keySet[k]) is Relation) {
					//relation = graphmodel.relations.find(keySet[k]) as Relation;
					//
					//for each(var leef:Element in relationNode.aggregationLeefs) {
						//if (relation.predicate != null && relation.predicate == leef) {
							//relation.predicate.isAggregatedInRoot = false;
							//
							//relation.isVisible = true;
							//
							//for each (var path:Path in relation.paths) {
								//
								//path.isVisible = true;
							//}
							//
						//}
					//}
					//
					//
					//
				//}
			//}
			
		}
		
		public static function insertInAggregationHierarchy(relation:Relation):void {
			connectParallelRelationNodes(relation);
		}
		
		public static function connectParallelRelationNodes(relation:Relation):void {
			
			var knownRelations:Array = Graphmodel.getInstance().relations.toArray();
			
			for (var i:int = 0; i < knownRelations.length; i++) {
				var knownRelation:Relation = knownRelations[i] as Relation;
				
				if ((knownRelation.subject == relation.subject && knownRelation.object == relation.object) 
						|| (knownRelation.object == relation.subject && knownRelation.subject == relation.object)) {
					
					if (knownRelation.predicate.aggregationRoot == null) {
						knownRelation.predicate.addAggregationLeef(relation.predicate);
					}
					
				}
			}
		}
		
		
		
	}

}