/**
 * Copyright (C) 2009 Philipp Heim, Sebastian Hellmann, Jens Lehmann, Steffen Lohmann and Timo Stegemann
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
 */ 

package  
{
	import flash.events.MouseEvent;
	import mx.collections.ArrayCollection;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.tabBarClasses.Tab;
	import mx.core.Application;
	
	public class FilterTab extends VBox{
		[Bindable]
		[Embed(source="../assets/img/hide.gif")]
		private var Hide:Class;
		
		[Bindable]
		[Embed(source="../assets/img/hide_inactive.gif")]
		private var HideInactive:Class;
		
		[Bindable]
		[Embed(source="../assets/img/show.gif")]
		private var Show:Class;
		
		[Bindable]
		[Embed(source="../assets/img/show_inactive.gif")]
		private var ShowInactive:Class;
		
		private var _img:Image = new Image();
		private var _isVisible:Boolean = true;
		private var _list:ArrayCollection;
		
		public function FilterTab() {
			super();
			_img.buttonMode = true;
			_img.useHandCursor = true;
			_img.source = Hide;
			_img.addEventListener(MouseEvent.CLICK, handleImageClick);
		}
		
		override protected function createChildren():void {
			super.createChildren();
			//icon = _img;
			addChild(_img);
		}
		
		public function set list(l:ArrayCollection):void {
			_list = l;
		}
		
		public function set isVisible(b:Boolean):void {
			_isVisible = b;
			if (_isVisible) {
				_img.source = Hide;
			}else {
				_img.source = Show;
			}
		}
		
		public function get isVisible():Boolean {
			return _isVisible;
		}
		
		private function handleImageClick(event:Event):void {
			var value:Boolean = (!_isVisible);
			for each(var o:Object in _list) {
				o.isVisible = value;
			}
		}
		
		private function app(): Main {
			return Application.application as Main;
		}
	}

}