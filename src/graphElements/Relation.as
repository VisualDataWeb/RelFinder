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
	import flash.events.Event;
	import mx.core.Application;
	import graphElements.events.PropertyChangedEvent;
	
	public class Relation extends EventDispatcher{
		public var id:String;
		public var subject:Element;
		public var predicate:Element;
		public var object:Element;
		
		public static var VCHANGE:String = "isVisibleChange";
		
		private var _paths:Array = new Array();
		private var _isVisible:Boolean = false;
		
		private var _relType:RelType = null;
		
		public function Relation(_id:String, _sub:Element, _pred:Element, _obj:Element, rT:RelType = null){
			this.id = _id;
			this.subject = _sub;
			this.predicate = _pred;
			this.object = _obj;
			if (rT != null) {
				relType = rT;
				relType.addRelation(this);
			}
			
			this.subject.addRelation(this);
			this.object.addRelation(this);
		}
		
		public function removeListener():void {
			//this.subject.removeEventListener(Element.CONCEPTCHANGE, conceptChangeHandler);
			//this.object.removeEventListener(Element.CONCEPTCHANGE, conceptChangeHandler);
			for each(var p:Path in _paths) {
				p.removeEventListener(Path.VCHANGE, checkVisibility);
				//p.removeEventListener(Path.RCHANGE, pathInRangeChangeHandler);
			}
			//this._relType.removeEventListener(RelType.VCHANGE, relTypeVChangeHandler);
		}
		
		public function get paths():Array {
			return _paths;
		}
		
		public function addPath(p:Path):void {
			if (paths.indexOf(p) == -1) {
				paths.push(p);
				this.subject.addPath(p);
				this.object.addPath(p);
				
				p.addEventListener(Path.VCHANGE, checkVisibility);
				
				checkVisibility(null);	//just to check
			}
		}
		
		[Bindable(event=Relation.VCHANGE)]
		public function get isVisible():Boolean {
			return _isVisible;
		}
		
		public function set isVisible(b:Boolean):void {
			if (_isVisible != b) {
				trace("set relation("+id+") visibile: " + b);
				_isVisible = b;
				
				dispatchEvent(new Event(Relation.VCHANGE));
				//dispatchEvent(new PropertyChangedEvent(Relation.VCHANGE, this, "isVisible", _currentUserAction));
				
				if (!_isVisible) {
					//trace("hide relationNode :" + id);
					app().hideNode(app().getRelationNode(id, this));
				}else {
					//wird über path gesteuert!
				}
				//trace("dispatch event");
				
			}
		}
		
		public function get relType():RelType {
			return this._relType;
		}
		
		public function set relType(rT:RelType):void {
			if (this._relType != rT) {
				if (this._relType != null) {
					//this._relType.removeEventListener(RelType.VCHANGE, relTypeVChangeHandler);
				}
				this._relType = rT;
				//this._relType.addEventListener(RelType.VCHANGE, relTypeVChangeHandler);
			}
		}
		
		private function conceptChangeHandler(event:PropertyChangedEvent):void {
			var e:Element = event.origin as Element;
			//e.concept.addEventListener(Concept.VCHANGE, conceptVChangeHandler);
		}
		
		public function bothConceptsAreVisible():Boolean {
			if (((object.concept == null) || object.concept.isVisible) && ((subject.concept == null) || this.subject.concept.isVisible)) {
				return true;
			}else {
				return false;
			}
		}
		
		public function oneConLevelIsVisible():Boolean {
			if ((object.computeConnectivityLevel == null) || ((object.connectivityLevel != null) && object.connectivityLevel.isVisible) || ((subject.connectivityLevel != null) && this.subject.connectivityLevel.isVisible)) {
				return true;
			}else {
				return false;
			}
		}
		
		/**
		 * Checks all the requirements to the relation to be visible or invisible
		 */
		private function checkVisibility(event:Event):void {
			if (this.isVisible) {	//check, if it should become invisible
				var setInVisible:Boolean = true;
				for each(var p1:Path in _paths) {
					if (p1.isVisible) {
						setInVisible = false;
						break;
					}
				}
				if (setInVisible) {
					this.isVisible = false;
				}
			}else {	//check, if it should become visible
				for each(var p2:Path in _paths) {
					if (p2.isVisible) {
						this.isVisible = true;
						break;
					}
				}
			}
		}
		
		private function app(): Main {
			return Application.application as Main;
		}
	}
	
}