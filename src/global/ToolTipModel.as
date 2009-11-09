/**
 * Copyright (C) 2009 Philipp Heim, Sebastian Hellmann, Jens Lehmann, Steffen Lohmann and Timo Stegemann
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package global 
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class ToolTipModel implements IEventDispatcher
	{
		//*** Singleton **********************************************************
		private static var instance:ToolTipModel;
		
		private var eventDispatcher:EventDispatcher;
		
		public function ToolTipModel(singleton:SingletonEnforcer) 
		{
			eventDispatcher = new EventDispatcher();
		}
		
		public static function getInstance():ToolTipModel{
			if (ToolTipModel.instance == null){
				ToolTipModel.instance = new ToolTipModel(new SingletonEnforcer());
				
			}
			return ToolTipModel.instance;
		}
		//************************************************************************
		
		public var preventToolTipHide:Boolean = true;
		
		
		//*** IEventDispatcher ***************************************************
		public function addEventListener(type:String, listener:Function,
			useCapture:Boolean = false, priority:int = 0, weakRef:Boolean = false):void{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, weakRef);
		}
		
		public function dispatchEvent(event:Event):Boolean{
			return eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean{
			return eventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function,
			useCapture:Boolean = false):void{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}
		//************************************************************************
	}
}
class SingletonEnforcer{}