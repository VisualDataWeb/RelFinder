package positionedTabNavigator.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class CloseTabEvent extends Event 
	{
		public var tabLabel:String = "";
		
		public static const CLOSE_TAB_EVENT:String = "cte";
		
		public function CloseTabEvent(tabLabel:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(CLOSE_TAB_EVENT, bubbles, cancelable);
			this.tabLabel = tabLabel;
		} 
		
		public override function clone():Event 
		{ 
			return new CloseTabEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("CloseTabEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}