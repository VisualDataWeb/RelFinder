package graphElements 
{
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	
	/**
	 * Element extands AggregatableElement not reverse, which could be implied by the name.
	 * 
	 * @author Timo Stegemann
	 */
	public class AggregatableElement extends EventDispatcher
	{
		public var aggregationRoot:AggregatableElement = null;
		
		public var aggregationLeefs:ArrayCollection = null;
		
		public function addAggregationLeef(leef:AggregatableElement):void {
			if (aggregationLeefs == null) {
				aggregationLeefs = new ArrayCollection();
			}
			
			aggregationLeefs.addItem(leef);
			
			// If "leef" is a leef of "this", then "this" must be root of "leef" (of cause our aggregation structure is not a real tree!)
			leef.aggregationRoot = this;
		}
	}

}