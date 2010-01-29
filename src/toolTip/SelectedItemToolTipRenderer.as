package toolTip
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import global.ToolTipModel;
	import graphElements.Element;
	import graphElements.model.Graphmodel;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.Label;
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
		
		private var closeTimer:Timer;
		
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
			
			if (closeTimer) {
				closeTimer.stop();
			}
			
			closeTimer = new Timer(2000, 1);
			closeTimer.addEventListener(TimerEvent.TIMER,
				function():void {
					if (!ToolTipModel.getInstance().preventToolTipHide) {
						(parent.parent as Menu).hide();
					}
				});
			closeTimer.start();
		}
		
		private var _data:Object;
		
		[Bindable("dataChange")]
		public function get data():Object {
			return _data;
		}

		public function set data(value:Object):void {
			
			_data = value;
			
			if (data.hasOwnProperty("uris") && counter != null){
				counter.text = "(" + (uriIndex + 1) + "/" + ((data.uris as Array).length) + ")";
			}
			
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		private function update(event:Event = null):void {
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			
			trace(uriIndex, data.uris[uriIndex], data.tempUri);
			
			if (data.hasOwnProperty("tempUri") && data.tempUri != null) {
				infoBox.selectedElement = Graphmodel.getInstance().getElement(data.tempUri, data.tempUri, data.label);
				showNavButtons = false;
			}else if (data.hasOwnProperty("uris")) {
				infoBox.selectedElement = Graphmodel.getInstance().getElement(data.uris[uriIndex], data.uris[uriIndex], data.label);
				
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
		
		private var text:Label;
		
		private var counter:Label;
		
		private var useThis:Button;
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			if (!backward) {
				backward = new Button();
				backward.label = "<";
				backward.width = 18;
				backward.height = 18;
				backward.setStyle("paddingTop", 0);
				backward.setStyle("paddingLeft", 0);
				backward.setStyle("paddingBottom", 0);
				backward.setStyle("paddingRight", 0);
				backward.addEventListener(MouseEvent.CLICK, backClick);
			}
			
			if (!forward) {
				forward = new Button();
				forward.label = ">";
				forward.width = 18;
				forward.height = 18;
				forward.setStyle("paddingTop", 0);
				forward.setStyle("paddingLeft", 0);
				forward.setStyle("paddingBottom", 0);
				forward.setStyle("paddingRight", 0);
				forward.addEventListener(MouseEvent.CLICK, forClick);
			}
			
			if (!text) {
				text = new Label();
				text.text = "Several resources with same label exist";
				text.setStyle("paddingTop", 0);
				text.setStyle("paddingLeft", 0);
				text.setStyle("paddingBottom", 0);
				text.setStyle("paddingRight", 0);
				text.width = 220;
				text.height = 20;
			}
			
			if (!counter) {
				counter = new Label();
				counter.setStyle("paddingTop", 0);
				counter.setStyle("paddingLeft", 0);
				counter.setStyle("paddingBottom", 0);
				counter.setStyle("paddingRight", 0);
				counter.width = 46;
				counter.height = 20;
			}
			
			if (!useThis) {
				useThis = new Button();
				useThis.label = "select";
				useThis.toolTip = "select this resource for relation finding";
				useThis.height = 20;
				useThis.width = 100;
				useThis.setStyle("paddingLeft", 2);
				useThis.setStyle("paddingRight", 2);
				useThis.addEventListener(MouseEvent.CLICK, selectTempURI);
				useThis.enabled = false;
			}
			
			addChild(text);
			addChild(counter);
			addChild(backward);
			addChild(forward);
			addChild(infoBox);
			addChild(useThis);
			
		}
		
		private function backClick(e:Event):void {
			if (data.hasOwnProperty("uris")){
				if (uriIndex > 0) {
					uriIndex--;
				}else {
					uriIndex = 0;
				}
				counter.text = "(" + (uriIndex + 1) + "/" + ((data.uris as Array).length) + ")";
			}
			
			update();
		}
		
		private function forClick(e:Event):void {
			if (data.hasOwnProperty("uris")){
				if (uriIndex < (data.uris as Array).length - 1) {
					uriIndex++;
				}else {
					uriIndex = (data.uris as Array).length - 1;
				}
				counter.text = "(" + (uriIndex + 1) + "/" + ((data.uris as Array).length) + ")";
			}
			
			update();
		}
		
		private function selectTempURI(event:Event):void {
			data.tempURI = data.uris[uriIndex];
		}
		
		private function get infoBox():ToolTipInfoBox {
			if (!_infoBox) {
				_infoBox = new ToolTipInfoBox();
				_infoBox.width = 300;
				_infoBox.height = 300;
			}
			
			return _infoBox;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (showNavButtons) {
				
				backward.visible = true;
				forward.visible = true;
				text.visible = true;
				counter.visible = true;
				
				backward.x = 4;
				backward.y = 2;
				
				forward.x = backward.x + backward.width + 4;
				forward.y = backward.y;
				
				counter.x = forward.x + forward.width + 4;
				counter.y = backward.y;
				
				text.x = counter.x + counter.width;
				text.y = backward.y;
				
				infoBox.x = 0;
				infoBox.y = 29;
				
				useThis.visible = true;
				
				useThis.x = width - 4 - useThis.width;
				useThis.y = height - 4 - useThis.height;
			}else {
				
				backward.visible = false;
				forward.visible = false;
				text.visible = false;
				counter.visible = false;
				
				infoBox.x = 0;
				infoBox.y = -1;
				
				useThis.visible = false;
			}
			
			
		}
		
		override public function get measuredHeight():Number {
			measuredHeight = infoBox.height - 2 + ((showNavButtons) ? 60 : 0);
			return super.measuredHeight;
		}
		
		override public function set measuredHeight(value:Number):void 
		{
			super.measuredHeight = value;
		}
		
		override public function get measuredWidth():Number {
			measuredWidth = infoBox.width + 2;
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