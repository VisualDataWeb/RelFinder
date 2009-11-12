/**
 * Copyright (C) 2009 Philipp Heim, Sebastian Hellmann, Jens Lehmann, Steffen Lohmann and Timo Stegemann
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package graphElements 
{
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.core.Application;

	public class ConnectivityLevel extends EventDispatcher
	{
		private var _id:String;
		private var _label:String;
		private var _num:int = -1;
		
		private var _isVisible:Boolean = true;
		private var _canBeChanged:Boolean = true;	//whether the visibility of the concept can be changed! Or the change of the visibility has any effect on the graph!
		
		private var _elements:ArrayCollection = new ArrayCollection();
		private var _numVisibleElements:int = 0;
		private var _stringNumOfElements:String = "";	//textual representation of the number of visible and not visible elements
		
		public static var VCHANGE:String = "isVisibleChange";
		public static var NUMVECHANGE:String = "numberOfVisibleElementsChange";
		
		public function ConnectivityLevel(_id:String, _num:int) {
			this._id = _id;
			this._label = _num.toString();
			
			this._num = _num;
			
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get label():String {
			return _label;
		}
		
		public function get canBeChanged():Boolean {
			return _canBeChanged;
		}
		
		[Bindable(event=ConnectivityLevel.VCHANGE)]
		public function get isVisible():Boolean {
			return _isVisible;
		}
		
		private function app(): Main {
			return Application.application as Main;
		}
	}

}