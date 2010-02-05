package graphElements 
{
	import graphElements.RelationNode;
	import graphElements.Relation;
	import mx.collections.ArrayCollection;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class AggregatedRelationNode extends RelationNode
	{
		
		public function AggregatedRelationNode(id:String, relation:Relation) 
		{
			super(id, relation);
			
		}
		
		public var aggregatedNodes:ArrayCollection = new ArrayCollection();
		
	}

}