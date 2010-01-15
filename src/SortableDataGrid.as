package {
	
	import flash.events.Event;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.*;
	import mx.collections.*;
	import mx.events.FlexEvent;
	
	public class SortableDataGrid extends DataGrid {
		
		public function SortableDataGrid() {
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		}
		
		private function creationCompleteHandler(event:FlexEvent):void {
			_creationComplete = true;
			sortByColumn(_sortIndexPreInitTemp);
			dispatchEvent(new Event("SortIndexChange"));
		}
		
		private var _creationComplete:Boolean = false;
		private var _sortIndexPreInitTemp:int = -1;
		
		private var _sortIndex:int = -1;
		
		[Bindable(event="SortIndexChange")]
		public function get sortIndex():int {
			return _sortIndex;
		}
		
		public function set sortIndex(value:int):void {
			if (!_creationComplete) {
				_sortIndexPreInitTemp = value;
			}else {
				_sortIndex = value;
				sortByColumn(value);
				dispatchEvent(new Event("SortIndexChange"));
			}
		}
		
		public var sortColumn:DataGridColumn;
		
		public var sortDirection:String;
		
		public var lastSortIndex:int = -1;
		
		[Inspectable(category="General", enumeration="ASC,DESC,DONTCHANGE", defaultValue="DONTCHANGE")]
		public function sortByColumn(index:int = -1, direction:String = "DONTCHANGE"):void {
			
			if (!_creationComplete) {
				_sortIndexPreInitTemp = index;
				return;
			}
			
			
			var c:DataGridColumn = columns[index];
			if (c != null) {
				var desc:Boolean = c.sortDescending;
			}else {
				return;
			}
			var dir:String = "";
			
			if (direction.toUpperCase() == "DESC" || direction.toUpperCase() == "ASC") {
				dir = direction.toUpperCase();
			}else {
				dir = (desc) ? "DESC" : "ASC";
			}
			
			if (c.sortable) {
				
				var s:Sort = collection.sort;
				var f:SortField;
				
				if (s) {
					
					s.compareFunction = null;
					var sf:Array = s.fields;
					
					if (sf) {
						
						for (var i:int = 0; i < sf.length; i++) {
							if (sf[i].name == c.dataField) {
								f = sf[i]
								if (direction.toUpperCase() != "DONTCHANGE") {
									desc = !f.descending;
								}
								break;
							}
						}
					}
					
				}else {
					s = new Sort();
				}
				
				if (!f) {
					f = new SortField(c.dataField);
				}
				
				c.sortDescending = desc;
				
				sortDirection = dir;
				
				lastSortIndex = _sortIndex;
				_sortIndex = index;
				dispatchEvent(new Event("SortIndexChange"));
				
				sortColumn = c;
				
				placeSortArrow();
				
				f.name = c.dataField;
				if (c.sortCompareFunction != null) {
					f.compareFunction = c.sortCompareFunction;
				}else {
					f.compareFunction = null;
				}
				f.descending = desc;
				s.fields = [f];
			}
			
			collection.sort = s;
			collection.refresh();
		}
	}
}