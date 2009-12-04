package utils 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;
	import mx.controls.TextArea;
	import mx.core.IUITextField;
	import mx.events.FlexEvent;
	import mx.core.mx_internal;
	
	public class DynamicTextArea extends TextArea{

		public function DynamicTextArea(){
			super();
			super.horizontalScrollPolicy = "off";
			super.verticalScrollPolicy = "off";
			
		}
		
		override protected function createChildren():void {
			super.createChildren();
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete );
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, updateComplete );
			this.addEventListener(Event.CHANGE, adjustHeightHandler );
			
			this.removeEventListener(MouseEvent.MOUSE_WHEEL, mouseWheelHandler);
			
		}

		protected function creationComplete( event : FlexEvent ) : void {
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.wordWrap = true;
			textField.mouseWheelEnabled = false;
		}

		protected function updateComplete( event : FlexEvent ) : void {
			if ( super.height != Math.floor( textField.height ) )  
				super.height = textField.height;
		}

		protected function adjustHeightHandler(event:Event):void{
			super.dispatchEvent( new FlexEvent( FlexEvent.UPDATE_COMPLETE ) ); 
		}

	}
}