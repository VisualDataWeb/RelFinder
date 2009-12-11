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
	import connection.model.ConnectionModel;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import mx.managers.ToolTipManager;
	
	import mx.core.UIComponent;
	
	public class ImageView extends UIComponent {
		
		private var _image_path:String = "";
		private var loader:Loader;
		private var request:URLRequest;
		
		public var maxImageHeight:Number = 120;
		private var imgWidth:Number;
		private var imgHeigth:Number;
		
		public function ImageView() {
			mouseChildren = false;
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT,  mouseOutHandler);
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		
		private function mouseOverHandler(event:MouseEvent):void {
			useHandCursor = true;
			buttonMode = true;
		}
		
		private function mouseOutHandler(event:MouseEvent):void {
			useHandCursor = false;
			buttonMode = false;
		}
		
		private function mouseClickHandler(event:MouseEvent):void {
			scaleMaxHeight = !scaleMaxHeight;
		}
		
		private function onComplete(event:Event):void {
			imgWidth = loader.width;
			imgHeigth = loader.height;
			scaleImageToFit();
			centerImage();
			addChild(loader);
		}
		
		public function calcIdealImageSize(infoboxHeight:Number):void{
			
			var newMaxSize:Number = infoboxHeight - 200;
			
			if (newMaxSize > 120){
				maxImageHeight = 120;
			}else if (newMaxSize < 0){
				maxImageHeight = 0;	
			}else{
				maxImageHeight = newMaxSize;
			}
			
			scaleImageToFit();
			centerImage();
			
		}
		
		public function set image_path(value:String):void {
			
			if (loader && contains(loader)){
				removeChild(loader);
			}
			
			if (isValidURL(value)) {
				_image_path = value;
				
				var tempURL:String = value;
				
				if (ConnectionModel.getInstance().sparqlConfig.useProxy) {
					tempURL = ConnectionModel.getInstance().proxy + "?" + tempURL;
				}
				
				loader = new Loader();
				request = new URLRequest(tempURL);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, faultHandler);
				loader.load(request);
				
				dispatchEvent(new Event("image_pathChange"));
			}else {
				faultHandler(null);
			}
		}
		
		[Bindable("widthChanged")]
		[Inspectable(category="General")]
		[PercentProxy("percentWidth")]
		override public function get width():Number {
			return super.width;
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			scaleImageToFit();
			centerImage();
		}
		
		override public function get height():Number {
			return super.height;
		}
		
		override public function set height(value:Number):void {
			super.height = value;
		}
		
		private var _scaleMaxHeight:Boolean = true;
		
		[Bindable(event="scaleMaxHeightChange")]
		public function get scaleMaxHeight():Boolean {
			return _scaleMaxHeight;
		}
		
		public function set scaleMaxHeight(value:Boolean):void {
			if (_scaleMaxHeight != value) {
				_scaleMaxHeight = value;
			}
			
			dispatchEvent(new Event("scaleMaxHeightChange"));
			scaleImageToFit();
			centerImage();
		}
		
		public function scaleImageToFit():void {
			if (loader) {
				var scalingFactor:Number = width / imgWidth;
				
				if (scaleMaxHeight) {
					
					if (imgHeigth * scalingFactor > maxImageHeight) {
						scalingFactor = maxImageHeight / imgHeigth;
					}
					
					if (scalingFactor > 1) {
						scalingFactor = 1;
					}
					
				}
				
				height = (imgHeigth * scalingFactor);
				
				if (loader.content is Bitmap) {
					(loader.content as Bitmap).smoothing = true;
				}
				loader.scaleX = scalingFactor;
				loader.scaleY = scalingFactor;
			}
		}
		
		public function centerImage():void {
			if (loader) {
				loader.x = (width - loader.width) / 2;
			}
		}
		
		private function faultHandler(e:Event):void {
			
			loader = new Loader();
			
			onComplete(null);
			
		}
		
		private function faultHandler2(e:Event):void {
			trace(e);
		}
		
		[Bindable(event="image_pathChange")]
		public function get image_path():String {
			return _image_path;
		}
		
		//TODO: do real validation (Timo)
		private function isValidURL(url:String):Boolean {
			
			//svg bug workaround
			if (url.lastIndexOf(".svg") == url.length - 4) {
				
				trace("ImageView:isValidURL() blocked an svg file to load. This is just a workaround.");
				
				return false;
			}
			
			return url != null && url != "";// && url.search("http://") == 0;
		}
	}
}