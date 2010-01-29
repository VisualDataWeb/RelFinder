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
	import global.StatusModel;
	import graphElements.events.PropertyChangedEvent;
	import graphElements.model.Graphmodel;
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
		
		public var startElement:Element = null;
		public var endElement:Element = null;
		
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
				r.subject.removeEventListener(Element.CONLEVELCHANGE, conceptChangeHandler);
				if (r.subject.concept != null) {
					r.subject.concept.removeEventListener(Concept.VCHANGE, checkVisibility);
				}
				r.object.removeEventListener(Element.CONCEPTCHANGE, conceptChangeHandler);
				r.object.removeEventListener(Element.CONLEVELCHANGE, conceptChangeHandler);
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
					Graphmodel.getInstance().drawPath(this);
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
			//connectivityLevels of elements are not known yet.
			r.subject.addEventListener(Element.CONLEVELCHANGE, connectivityLevelChangeHandler);
			r.object.addEventListener(Element.CONLEVELCHANGE, connectivityLevelChangeHandler);
			
			//trace("dispatch event, relType.visible: " + r.relType.isVisible + ", " + r.relType.id);
		}
		
		private function conceptChangeHandler(event:Event):void {
			var e:Element = event.target as Element;
			e.concept.addEventListener(Concept.VCHANGE, checkVisibility);
			
		}
		
		private function connectivityLevelChangeHandler(event:Event):void {
			var e:Element = event.target as Element;
			e.connectivityLevel.addEventListener(ConnectivityLevel.VCHANGE, checkVisibility);
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
					_layout.settings = { alpha: 1, color: 0xD2001E /*0xFF0000*/, thickness: 2 };
					if(_isVisible)	Graphmodel.getInstance().drawPath(this, true);	//only if is visible
				}else {
					_layout.settings = { alpha: 1, color: 0xcccccc, thickness: 1 }; 
					if(_isVisible)	Graphmodel.getInstance().drawPath(this, true);	//only if is visible
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
			//trace("--------checkVisibility-------------");
			if (this.isVisible) {	//check, if it should become invisible
				var setVisible:Boolean = true;
				var maxConL:ConnectivityLevel = null;
				if (!this.pathLength.isVisible) {	//if pathLenght is invisible
					setVisible = false;
				}else {	//check other requirements
					for each(var r1:Relation in this._relations) {
						/*if (!r1.bothConLevelsAreVisible()) {
							setVisible = false;
							break;
						}*/
						if (!StatusModel.getInstance().isSearching) {	//is not searching anymore	//TODO: was passiert wenn path einen Knoten enthält der level 4 ist (level 4 aber invisible) ein anderer Knoten hat aber level 3 (und level 3 ist visible)? dann wird der path invisible gestellt! das ist RICHTIG!!
							if (r1.object.isGiven && r1.subject.isGiven) {	//direct connection!
								//maxConL = app().getConnectivityLevel("2", 2);
							}else {
								if (r1.object.connectivityLevel != null) {	//if not given
									var conL1:ConnectivityLevel = r1.object.connectivityLevel;
									if ((maxConL == null) || (conL1.id > maxConL.id)) {
										maxConL = conL1;
									}
								}
								if (r1.subject.connectivityLevel != null) {	//if not given
									var conL2:ConnectivityLevel = r1.subject.connectivityLevel;
									if ((maxConL == null) || (conL2.id > maxConL.id)) {
										maxConL = conL2;
									}
								}								
							}
							if (maxConL != null) {
								if (maxConL.isVisible) {
									setVisible = true;
								}else {
									setVisible = false;
								}
							}
						}
						
						if ((!r1.relType.isVisible) || (!r1.bothConceptsAreVisible())){	// || (!r1.extendedConLevelsCheck())) {	//bothConLevelsAreVisible() //if either the relType or one of the concepts are invisible
							setVisible = false;
							break;
						}
					}
				}	
				if (!setVisible) {
					this.isVisible = false;
				}
			}else {	//check, if it should become visible
				var setVisible2:Boolean = true;
				var maxConL2:ConnectivityLevel = null;
				if (!this.pathLength.isVisible) {
					setVisible2 = false;
				}else {
					for each(var r2:Relation in this._relations) {
						/*if (r2.bothConLevelsAreVisible()) {
							setVisible2 = true;
						}*/
						if (!StatusModel.getInstance().isSearching) {	//is not searching anymore
							if (r2.object.isGiven && r2.subject.isGiven) {	//direct connection!
								//maxConL2 = app().getConnectivityLevel("2", 2);
							}else {
								if (r2.object.connectivityLevel != null) {	//if not given
									var conL11:ConnectivityLevel = r2.object.connectivityLevel;
									if ((maxConL2 == null) || (conL11.id > maxConL2.id)) {
										maxConL2 = conL11;
									}
								}
								if (r2.subject.connectivityLevel != null) {	//if not given
									var conL12:ConnectivityLevel = r2.subject.connectivityLevel;
									if ((maxConL2 == null) || (conL12.id > maxConL2.id)) {
										maxConL2 = conL12;
									}
								}
							}							
							if (maxConL2 != null) {
								if (maxConL2.isVisible) {
									setVisible2 = true;
								}else {
									setVisible2 = false;
								}
							}
						}
						
						if ((!r2.relType.isVisible) || (!r2.bothConceptsAreVisible())){	// || (!r2.extendedConLevelsCheck())) {	//bothConLevelsAreVisible() //if either the relType or one of the concepts are invisible
							setVisible2 = false;
							break;
						}
						
						
					}
				}
				
				if (setVisible2) {
					this.isVisible = true;
				}
			}
		}
		
		private function app(): Main {
			return Application.application as Main;
		}
	}
	
}