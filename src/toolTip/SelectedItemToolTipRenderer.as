package toolTip
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import global.ToolTipModel;
	import graphElements.Element;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.Menu;
	import mx.controls.menuClasses.IMenuItemRenderer;
	import mx.core.Application;
	import mx.core.IDataRenderer;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.UIComponent;
	import mx.core.UITextField;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.events.MenuEvent;
	import mx.utils.ObjectUtil;
	
	import toolTip.ToolTipInfoBox;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class SelectedItemToolTipRenderer extends UIComponent implements IMenuItemRenderer, IDataRenderer, IListItemRenderer
	{
		
		private var _infoBox:ToolTipInfoBox;
		
		
		public function SelectedItemToolTipRenderer() 
		{
			super();
			
			this.addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
			
			this.addEventListener(FlexEvent.DATA_CHANGE, update);
			this.addEventListener("showNavButtonChange", update);
			
		}
		
		private function rollOverHandler(event:Event):void {
			ToolTipModel.getInstance().preventToolTipHide = true;
		}
		
		private function rollOutHandler(event:Event):void {
			ToolTipModel.getInstance().preventToolTipHide = false;
		}
		
		private var _data:Object;
		
		[Bindable("dataChange")]
		public function get data():Object {
			return _data;
		}

		public function set data(value:Object):void {
			
			_data = value;
			
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		private function update(event:FlexEvent):void {
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			
			uriIndex = 0;
			
			if (data.hasOwnProperty("tempUri")) {
				infoBox.selectedElement = (Application.application as Main).getElement(data.tempUri, data.tempUri, data.label);
				showNavButtons = false;
			}else if (data.hasOwnProperty("uris")) {
				infoBox.selectedElement = (Application.application as Main).getElement(data.uris[0], data.uris[0], data.label);
				
				if ((data.uris as Array).length > 1) {
					showNavButtons = true;
				}else {
					showNavButtons = false;
				}
				
			}
		}
		
		private var _showNavButtons:Boolean = false;
		
		[Bindable(event="showNavButtonChange")]
		private function get showNavButtons():Boolean {
			return _showNavButtons;
		}
		
		private function set showNavButtons(value:Boolean):void {
			if (_showNavButtons != value) {
				_showNavButtons = value;
				dispatchEvent(new Event("showNavButtonChange"));
			}
		}
		
		private var uriIndex:int = 0;
		
		private var backward:Button;
		
		private var forward:Button;
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			if (!backward) {
				backward = new Button();
				backward.label = "<";
				backward.width = 20;
				backward.height = 20;
				backward.addEventListener(MouseEvent.CLICK, backClick);
			}
			
			if (!forward) {
				forward = new Button();
				forward.label = ">";
				forward.width = 20;
				forward.height = 20;
				forward.addEventListener(MouseEvent.CLICK, forClick);
			}
			
			addChild(backward);
			addChild(forward);
			addChild(infoBox);
			
		}
		
		private function backClick(e:Event):void {
			
		}
		
		private function forClick(e:Event):void {
			
		}
		
		private function get infoBox():ToolTipInfoBox {
			if (!_infoBox) {
				_infoBox = new ToolTipInfoBox();
				_infoBox.width = 300;
				_infoBox.height = 400;
			}
			
			return _infoBox;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (showNavButtons) {
				
				backward.visible = true;
				forward.visible = true;
				
				backward.x = 10;
				backward.y = 2;
				
				forward.x = backward.x + backward.width + 4;
				forward.y = backward.y;
				
				infoBox.x = 0;
				infoBox.y = 30;
			}else {
				
				backward.visible = false;
				forward.visible = false;
				
				infoBox.x = 0;
				infoBox.y = 0;
			}
			
			
		}
		
		override public function get measuredHeight():Number {
			measuredHeight = infoBox.height - 1 + ((showNavButtons) ? 30 : 0);
			return super.measuredHeight;
		}
		
		override public function set measuredHeight(value:Number):void 
		{
			super.measuredHeight = value;
		}
		
		override public function get measuredWidth():Number {
			measuredWidth = infoBox.width + 1;
			return super.measuredWidth;
		}
		
		override public function set measuredWidth(value:Number):void 
		{
			super.measuredWidth = value;
		}
		
		private var _menu:Menu;
		
		public function get menu():Menu
		{
			return _menu;
		}
		
		public function set menu(value:Menu):void
		{
			_menu = value;
		}
		
		public function get measuredIconWidth():Number
		{
			return 0;
		}
		
		public function get measuredTypeIconWidth():Number
		{
			return 0;
		}
		
		public function get measuredBranchIconWidth():Number
		{
			return 0;
		}
		
	}

}