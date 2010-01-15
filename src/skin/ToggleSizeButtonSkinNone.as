package skin 
{
	import mx.skins.halo.ButtonSkin;
	import flash.display.GradientType;
	import mx.core.IButton;
	import mx.core.UIComponent;
	import mx.skins.Border;
	import mx.skins.halo.HaloColors;
	import mx.styles.StyleManager;
	import mx.utils.ColorUtil;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class ToggleSizeButtonSkinNone extends Border
	{
		
		public function ToggleSizeButtonSkinNone() 
		{
			super();
		}
		
		private static var cache:Object = {}; 
		
		private static function calcDerivedStyles(themeColor:uint,
												  fillColor0:uint,
												  fillColor1:uint):Object
		{
			var key:String = HaloColors.getCacheKey(themeColor,
													fillColor0, fillColor1);
					
			if (!cache[key])
			{
				var o:Object = cache[key] = {};
				
				// Cross-component styles.
				HaloColors.addHaloColors(o, themeColor, fillColor0, fillColor1);
			}
			
			return cache[key];
		}
		
		override public function get measuredWidth():Number
		{
			return 20;
		}
		
		override public function get measuredHeight():Number
	    {
	        return 20;
	    }

		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);

			// User-defined styles.
			var borderColor:uint = getStyle("borderColor");
			var cornerRadius:Number = getStyle("cornerRadius");
			var fillAlphas:Array = getStyle("fillAlphas");
			var fillColors:Array = getStyle("fillColors");
			StyleManager.getColorNames(fillColors);
			var highlightAlphas:Array = getStyle("highlightAlphas");				
			var themeColor:uint = getStyle("themeColor");

			// Derivative styles.
			var derStyles:Object = calcDerivedStyles(themeColor, fillColors[0],
													 fillColors[1]);

			var borderColorDrk1:Number =
				ColorUtil.adjustBrightness2(borderColor, -50);
			
			var themeColorDrk1:Number =
				ColorUtil.adjustBrightness2(themeColor, -25);
			
			var emph:Boolean = false;
			
			var lineColor:uint = getStyle("iconColor");
			var lineAlpha:Number = 0.3;
			
			if (parent is IButton)
				emph = IButton(parent).emphasized;
				
			
			var tmp:Number;
			
			graphics.clear();
			
			var xMid:Number = w / 2;
			var yMid:Number = h / 2;
			
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			
			graphics.lineStyle(1, borderColor, 0.9);
			graphics.moveTo(0, yMid);
			graphics.lineTo(w, yMid);
			
		}

	}
}