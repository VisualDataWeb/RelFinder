package preloader
{
	import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import mx.events.*;
    import mx.preloaders.Preloader;
	import mx.preloaders.DownloadProgressBar;
	import preloader.WelcomeScreen;

	public class CustomPreloader extends DownloadProgressBar {

        public var wcs:WelcomeScreen;
    
        public function CustomPreloader() 
        {
            super(); 
            wcs = new WelcomeScreen();
            this.addChild(wcs);
        }
    
        override public function set preloader( myPreloader:Sprite ):void 
        {
            myPreloader.addEventListener( ProgressEvent.PROGRESS , SWFDownloadProgress );    
            myPreloader.addEventListener( Event.COMPLETE , SWFDownloadComplete );
            myPreloader.addEventListener( FlexEvent.INIT_PROGRESS , FlexInitProgress );
            myPreloader.addEventListener( FlexEvent.INIT_COMPLETE , FlexInitComplete );
        }
    
        private function SWFDownloadProgress( event:ProgressEvent ):void {}
    
        private function SWFDownloadComplete( event:Event ):void {}
    
        private function FlexInitProgress( event:Event ):void {}
    
        private function FlexInitComplete( event:Event ):void 
        {      
        	wcs.ready = true;  	
            dispatchEvent( new Event( Event.COMPLETE ) );
        }
        
 	}

}