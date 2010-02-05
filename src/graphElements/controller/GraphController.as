package graphElements.controller 
{
	import com.adobe.flex.extras.controls.springgraph.Item;
	import graphElements.AggregatableElement;
	import graphElements.model.Graphmodel;
	import graphElements.Relation;
	import graphElements.RelationNode;
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
		
		
		public static function aggregateAllParallelRelationNodes():void {
			
			trace(graphmodel.relations.toArray());
			
			
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