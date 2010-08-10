package preloader
{
	import flash.display.Loader;
	import flash.utils.ByteArray;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class WelcomeScreen extends Loader
	{
		
		[ Embed(source="../../assets/img/RelFinder-Logo-gr.png", mimeType="application/octet-stream") ]
		public var WelcomeScreenGraphic:Class;
		public var timer:Timer;
		private var fadeInRate:Number  = .012;
		private var fadeOutRate:Number = .012;
		private var timeAutoClose:int = 250;
		public var ready:Boolean = false; 
		
		public function WelcomeScreen()
		{
			this.visible = false;
			this.alpha = 0;
			timer = new Timer( 1 );
            timer.addEventListener( TimerEvent.TIMER, updateView );
			timer.start();

			this.loadBytes( new WelcomeScreenGraphic() as ByteArray );
			this.addEventListener( MouseEvent.MOUSE_DOWN, mouseDown );			 
		}
		
		public function updateView( event:TimerEvent ):void
		{
			if( this.alpha < 1)	this.alpha = this.alpha + this.fadeInRate;
			this.stage.addChild(this);
			this.x = this.stage.stageWidth / 2 - this.width / 2;
			this.y = this.stage.stageHeight / 2 - this.height / 2;
			this.visible=true;
			if ( this.ready && timer.currentCount > this.timeAutoClose ) closeScreen();
		}
		
		public function closeScreen():void
		{
            timer.removeEventListener( TimerEvent.TIMER, updateView );
			timer.removeEventListener( MouseEvent.MOUSE_DOWN, mouseDown);
			timer.addEventListener( TimerEvent.TIMER, closeScreenFade );					
		}
		
		public function closeScreenFade( event:TimerEvent ):void
		{
			if( this.alpha > 0){
				this.alpha = this.alpha - fadeOutRate;
			} else {
				timer.stop();
				this.parent.removeChild(this);
			}		
		}		
		
		public function mouseDown( event:MouseEvent ):void
		{
			closeScreen();		
		}
				
	}
}