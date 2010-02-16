package graphElements 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	/**
	 * Element extands AggregatableElement not reverse, which could be implied by the name.
	 * 
	 * @author Timo Stegemann
	 */
	public class AggregatableElement extends EventDispatcher
	{
		public var leefsAggregatedInThis:Boolean = false;
		
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
		
		private var _isAggregatedInRoot:Boolean = false;
		
		[Bindable(event="isAggregatedInRootChange")]
		public function get isAggregatedInRoot():Boolean {
			return _isAggregatedInRoot;
		}
		
		public function set isAggregatedInRoot(value:Boolean):void {
			_isAggregatedInRoot = value;
			dispatchEvent(new Event("isAggregatedInRootChange"));
			aggregationRoot.dispatchEvent(new Event("isAggregatedInRootChange"));
		}
		
	}

}