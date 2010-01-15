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
	public class ToggleSizeButtonSkinDown extends Border
	{
		
		public function ToggleSizeButtonSkinDown() 
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
			
			var buttonState:int = -1;
			
			if (parent &&  parent.parent && parent.parent is InputFieldBox) {
				buttonState = (parent.parent as InputFieldBox).size;
			}
			
			
			var xMid:Number = w / 2;
			var yMid:Number = h / 2;
			
			graphics.beginFill(0x000000, 0);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			var arrow_commands:Vector.<int> = new Vector.<int>();
			arrow_commands.push(1, 2, 2, 2, 2, 2, 2);

			var arrow_coord:Vector.<Number> = new Vector.<Number>();
			
			
			switch (name)
			{			
				case "selectedUpSkin":
				case "selectedOverSkin":
				{
					arrow_coord.push(
					xMid - 2, yMid - 4,
					xMid + 2, yMid - 4,
					xMid + 2, yMid,
					xMid + 4, yMid,
					xMid, yMid + 5,
					xMid - 4, yMid,
					xMid - 2, yMid);
					
					graphics.beginFill(borderColorDrk1, 0.9);
					graphics.drawPath(arrow_commands, arrow_coord);
					graphics.endFill();
					
					break;
				}

				case "upSkin":
				{
					arrow_coord.push(
					xMid - 2, yMid - 4,
					xMid + 2, yMid - 4,
					xMid + 2, yMid,
					xMid + 4, yMid,
					xMid, yMid + 5,
					xMid - 4, yMid,
					xMid - 2, yMid);
					
					graphics.beginFill(borderColorDrk1, 0.9);
					graphics.drawPath(arrow_commands, arrow_coord);
					graphics.endFill();
					break;
				}
							
				case "overSkin":
				{
					
					graphics.beginGradientFill(GradientType.RADIAL, [ themeColor, themeColor ], [0.25, 0.0], null, verticalGradientMatrix(0, 0, w, h));
					graphics.drawRect(0, 0, width, height);
					graphics.endFill();
					
					arrow_coord.push(
					xMid - 2, yMid - 4,
					xMid + 2, yMid - 4,
					xMid + 2, yMid,
					xMid + 4, yMid,
					xMid, yMid + 5,
					xMid - 4, yMid,
					xMid - 2, yMid);
					
					graphics.beginFill(themeColor, 0.9);
					graphics.drawPath(arrow_commands, arrow_coord);
					graphics.endFill();
						
					break;
				}
										
				case "downSkin":
				case "selectedDownSkin":
				{
					
					graphics.beginGradientFill(GradientType.RADIAL, [ themeColorDrk1, themeColorDrk1 ], [0.25, 0.0], null, verticalGradientMatrix(0, 0, w, h));
					graphics.drawRect(0, 0, width, height);
					graphics.endFill();
					
					arrow_coord.push(
					xMid - 2, yMid - 4,
					xMid + 2, yMid - 4,
					xMid + 2, yMid,
					xMid + 4, yMid,
					xMid, yMid + 5,
					xMid - 4, yMid,
					xMid - 2, yMid);
					
					graphics.beginFill(themeColorDrk1, 0.9);
					graphics.drawPath(arrow_commands, arrow_coord);
					graphics.endFill();
				}
							
				case "disabledSkin":
				case "selectedDisabledSkin":
				{
					arrow_coord.push(
					xMid - 2, yMid - 4,
					xMid + 2, yMid - 4,
					xMid + 2, yMid,
					xMid + 4, yMid,
					xMid, yMid + 5,
					xMid - 4, yMid,
					xMid - 2, yMid);
					
					graphics.beginFill(lineColor, 0.5);
					graphics.drawPath(arrow_commands, arrow_coord);
					graphics.endFill();
				}
			}
			
			
			graphics.lineStyle(1, borderColor, 0.9);
			graphics.moveTo(0, yMid);
			graphics.lineTo(xMid - 5, yMid);
			graphics.moveTo(xMid + 5, yMid);
			graphics.lineTo(w, yMid);
			
		}

	}
}