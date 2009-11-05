/**
 * Copyright (C) 2009 Philipp Heim, Sebastian Hellmann, Jens Lehmann, Steffen Lohmann and Timo Stegemann
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package graphElements {
	import graphElements.events.PropertyChangedEvent;
	import mx.collections.ArrayCollection;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.core.Application;

	public class Path extends EventDispatcher{
		private var _id:String;
		private var _relations:ArrayCollection = new ArrayCollection();
		private var _isVisible:Boolean = false;
		private var _inRange:Boolean = false;
		private var _allRelsVisible:Boolean = false;
		
		private var _layout:Object = new Object();
		private var _isHighlighted:Boolean = false;
		
		public static var VCHANGE:String = "isVisibleChange";
		public static var RCHANGE:String = "inRangeChange";
		public static var HCHANGE:String = "isHighlightedChange";
		
		public static var PREQCHANGE:String = "pathRequirementsChange";
		
		private var _pathLength:PathLength = null;
		
		public function Path(id:String, rels:Array = null, pL:PathLength = null) {
			_id = id;
			_layout.settings = { alpha: 1, color: 0xcccccc, thickness: 1 };
			
			if (pL != null) {
				pathLength = pL;
				pathLength.addPath(this);
			}
			
			for each(var r:Relation in rels) {
				addRelation(r);
			}
			
			pathLength.dispatchEvent(new Event(PathLength.VCHANGE)); //to get the current state
		}
		
		public function removeListener():void {
			this.pathLength.removeEventListener(PathLength.VCHANGE, pathLengthVChangeHandler);
			for each(var r:Relation in _relations) {
				r.relType.removeEventListener(RelType.VCHANGE, checkVisibility);
				r.subject.removeEventListener(Element.CONCEPTCHANGE, conceptChangeHandler);
				if (r.subject.concept != null) {
					r.subject.concept.removeEventListener(Concept.VCHANGE, checkVisibility);
				}
				r.object.removeEventListener(Element.CONCEPTCHANGE, conceptChangeHandler);
				if (r.object.concept != null) {
					r.object.concept.removeEventListener(Concept.VCHANGE, checkVisibility);
				}
			}
			
		}
		
		public function get id():String {
			return _id;
		}
		
		public function get layout():Object {
			return _layout;
		}
		
		public function get pathLength():PathLength {
			return _pathLength;
		}
		
		[Bindable(event=Path.VCHANGE)]
		public function get isVisible():Boolean {
			return _isVisible;
		}
		
		public function set isVisible(b:Boolean):void {
			if (_isVisible != b) {
				//trace("set path("+id+") visible: " + b);
				_isVisible = b;
				dispatchEvent(new Event(Path.VCHANGE));
				//dispatchEvent(new PropertyChangedEvent(Concept.VCHANGE, this, "isVisible", _currentUserAction));
				
				if (_isVisible) {
					app().drawPath(this);
				}
				//trace("dispatch event");
				
			}
		}
		
		public function get relations():ArrayCollection {
			return _relations;
		}
		
		public function set pathLength(p:PathLength):void {
			if (this._pathLength != p) {
				if (this._pathLength != null) {
					this._pathLength.removeEventListener(PathLength.VCHANGE, pathLengthVChangeHandler);
				}
				this._pathLength = p;
				//this._pathLength.addEventListener(PathLength.VCHANGE, pathLengthVChangeHandler);
				this._pathLength.addEventListener(PathLength.VCHANGE, pathLengthVChangeHandler);
			}
		}
		
		private function pathLengthVChangeHandler(event:Event):void {
			//trace("vchangehandler pathlength: " + _pathLength.isVisible + ", this: " + this.isVisible);
			if (!_pathLength.isVisible) {
				inRange = false;	//TODO inRange is obsolete
				this.isVisible = false;
			}else {
				inRange = true;	//TODO inRange is obsolete
				if (this._allRelsVisible) {
					this.isVisible = true;
				}
			}
		}
		
		public function addRelation(r:Relation):void {
			//trace("addRelation: " + r.id + " , to path: " + id);
			_relations.addItem(r);
			r.addPath(this);
			//r.addEventListener(Relation.VCHANGE, relationIsVisibleChangeHandler);
			//r.relType.addEventListener(RelType.VCHANGE, relTypeIsVisibleChangeHandler);
			r.relType.addEventListener(RelType.VCHANGE, checkVisibility);
			checkVisibility();
			//concepts of elements possibly not known yet.
			r.subject.addEventListener(Element.CONCEPTCHANGE, conceptChangeHandler);
			r.object.addEventListener(Element.CONCEPTCHANGE, conceptChangeHandler);
			
			trace("dispatch event, relType.visible: " + r.relType.isVisible + ", " + r.relType.id);
		}
		
		private function conceptChangeHandler(event:Event):void {
			var e:Element = event.target as Element;
			e.concept.addEventListener(Concept.VCHANGE, checkVisibility);
			
		}
		
		[Bindable(event=Path.RCHANGE)]
		public function get inRange():Boolean {	//TODO inRange is obsolete
			return _inRange;
		}
		
		public function set inRange(b:Boolean):void { //TODO inRange is obsolete
			if (_inRange != b) {
				//trace("set inRange: " + b + " of path: " + id);
				_inRange = b;
				//trace("dispatch event");
				//dispatchEvent(new Event(Path.RCHANGE));
				checkVisibility(null);
				//dispatchEvent(new PropertyChangedEvent(Path.RCHANGE, this, "inRange", _currentUserAction));	//ORIGIN1
			}
		}
		
		public function set isHighlighted(b:Boolean):void {
			//trace("set is highlighted " + b);
			if (b != _isHighlighted) {
				_isHighlighted = b;
				dispatchEvent(new Event(Path.HCHANGE));
				//dispatchEvent(new PropertyChangedEvent(Path.HCHANGE, this, "isHighlighted", _currentUserAction));
				
				if (_isHighlighted) {
					_layout.settings = { alpha: 1, color: 0xFF0000, thickness: 2 };
					if(_isVisible)	app().drawPath(this, true);	//only if is visible
				}else {
					_layout.settings = { alpha: 1, color: 0xcccccc, thickness: 1 }; 
					if(_isVisible)	app().drawPath(this, true);	//only if is visible
				}
				
			}
		}
		
		[Bindable(event=Path.HCHANGE)]
		public function get isHighlighted():Boolean {
			return _isHighlighted;
		}
		
		/**
		 * Checks all the requirements to the path to be visible or invisible
		 */
		private function checkVisibility(event:Event = null):void {
			if (this.isVisible) {	//check, if it should become invisible
				if (!this.pathLength.isVisible) {	//if pathLenght is invisible
					this.isVisible = false;
				}else {	//check other requirements
					for each(var r1:Relation in this._relations) {
						if ((!r1.relType.isVisible) || (!r1.bothConceptsAreVisible())) {	//if either the relType or one of the concepts are invisible
							this.isVisible = false;
							break;
						}
					}
				}				
			}else {	//check, if it should become visible
				var setVisible:Boolean = true;
				if (!this.pathLength.isVisible) {
					setVisible = false;
				}else {
					for each(var r2:Relation in this._relations) {
						if ((!r2.relType.isVisible) || (!r2.bothConceptsAreVisible())) {	//if either the relType or one of the concepts are invisible
							setVisible = false;
							break;
						}
					}
				}
				
				if (setVisible) {
					this.isVisible = true;
				}
			}
		}
		
		private function app(): Main {
			return Application.application as Main;
		}
	}
	
}