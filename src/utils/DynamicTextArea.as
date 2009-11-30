package utils 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import mx.controls.TextArea;
	import mx.events.FlexEvent;


	public class DynamicTextArea extends TextArea{

		public function DynamicTextArea(){
			super();
			super.horizontalScrollPolicy = "off";
			super.verticalScrollPolicy = "off";
			this.addEventListener( FlexEvent.CREATION_COMPLETE, creationComplete );
			this.addEventListener( FlexEvent.UPDATE_COMPLETE, updateComplete );
			this.addEventListener( Event.CHANGE, adjustHeightHandler );
		}

		private function creationComplete( event : FlexEvent ) : void {
			textField.autoSize = TextFieldAutoSize.LEFT;
			textField.wordWrap = true;
		}

		private function updateComplete( event : FlexEvent ) : void {
			if ( super.height != Math.floor( textField.height ) )  
				super.height = textField.height;
		}

		private function adjustHeightHandler(event:Event):void{
			super.dispatchEvent( new FlexEvent( FlexEvent.UPDATE_COMPLETE ) ); 
		}
	}
}