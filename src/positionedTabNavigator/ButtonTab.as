package positionedTabNavigator 
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import mx.core.UIComponent;
	import positionedTabNavigator.events.CloseTabEvent;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.ButtonLabelPlacement;
	import mx.controls.ToolTip;
	import mx.core.EdgeMetrics;
	import mx.core.FlexVersion;
	import mx.core.IBorder;
	import mx.core.IFlexAsset;
	import mx.core.mx_internal;
	import mx.core.UITextField;
	import mx.events.CloseEvent;
	import mx.events.MoveEvent;
	import mx.managers.ToolTipManager;
	import positionedTabNavigator.skins.BorderlessButtonSkin;
	
	use namespace mx_internal;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class ButtonTab extends PositionedTab
	{
		
		public static const CLOSE_BUTTON_SIZE:int = 18;
		public static const CLOSE_BUTTON_X_OFFSET:int = 2;
		public static const CLOSE_BUTTON_Y_OFFSET:int = 2;
		
		public function ButtonTab() 
		{
			super();
			addEventListener(MouseEvent.MOUSE_OVER, mouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOut);
		}
		
		protected var originalLabel:String;
		
		private var ft:FilterTab;
		
		//private var tip:ToolTip;
		
		private function mouseOver(event:MouseEvent):void {
			
			/*
			toolTip = originalLabel;
			if (toolTip !== "" && toolTip !== null) {
				var pt:Point = new Point(event.currentTarget.x, event.currentTarget.y);
				pt = event.currentTarget.contentToGlobal(pt);
				
				// Tooltip under Textfield
				tip = ToolTipManager.createToolTip(toolTip, pt.x, pt.y - event.currentTarget.y + textField.height) as ToolTip;
				// Tooltip right of textfield
				//tip = ToolTipManager.createToolTip(toolTip, pt.x + event.currentTarget.width, pt.y - event.currentTarget.y) as ToolTip;
				toolTip = "";
			}
			*/
		}
		
		private function mouseOut(event:MouseEvent):void {
			/*
			if (tip !== null) {
				ToolTipManager.destroyToolTip(tip);	
			}
			*/
		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			
			ft = null;
			
			// Search this tab in tabbar
			for (var i:int = 0; i < parent.parent.numChildren; i++) {
				if (parent.parent.getChildAt(i) is FilterTab) {
					if ((parent.parent.getChildAt(i) as FilterTab).label == originalLabel) {
						ft = (parent.parent.getChildAt(i) as FilterTab)
					}
				}
			}
			
			if (ft == null) {
				closeButton = new Button();
			}else {
				
				closeButton = new Button();
				closeButton.width = CLOSE_BUTTON_SIZE;
				closeButton.height = CLOSE_BUTTON_SIZE;
				
				closeButton.setStyle( "skin", BorderlessButtonSkin );
				
				closeButton.addEventListener(MouseEvent.ROLL_OVER, mouseOverButton);
				
				var indicatorClass:Class = getStyle("indicatorClass") as Class;
				if(indicatorClass) {
					indicator = new indicatorClass() as DisplayObject;
				}
				else {
					indicator = new UIComponent();
				}
				
				addChild(indicator);
				addChild(closeButton);
				
				ft.filterButton = closeButton;
			}
			
		}
		
		private function mouseOverButton(event:MouseEvent):void {
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            // We need to make sure that the closeButton and the indicator are
            // above all other display items for this button. Otherwise the button
            // skin or icon or text are placed over the closeButton and indicator.
            // That's no good because then we can't get clicks and it looks funky.
            setChildIndex(closeButton, numChildren - 1);
            setChildIndex(indicator, numChildren - 1);
            
            
            closeButton.visible = false;
            indicator.visible = false;
            
            // Depedning on the closePolicy we might be showing the closeButton
            // and it may or may not be enabled.
            if(closePolicy == PositionedTab.CLOSE_SELECTED) {
                if(selected) {
                    closeButton.visible = true;
                    closeButton.enabled = true;
                }
            }
            else {
                if(!_rolledOver) {
                    if(closePolicy == PositionedTab.CLOSE_ALWAYS){
                        closeButton.visible = true;
                        closeButton.enabled = false;
                    }
                    else if(closePolicy == PositionedTab.CLOSE_ROLLOVER) {
                        closeButton.visible = false;
                        closeButton.enabled = false;
                    }
                }
                else {
                    if(closePolicy != PositionedTab.CLOSE_NEVER) {
                        closeButton.visible = true;
                        closeButton.enabled = true;
                    }
                }
            }
            showIndicator = true;
            if(showIndicator) {
                indicator.visible = true;
                indicator.x = _indicatorOffset - indicator.width/2;
                indicator.y = this.height - 12;
            }
            
            if(closeButton.visible) {
                // Resize the text if we're showing the closeIcon, so the
                // closeIcon won't overlap the text. This means the text may
                // have to truncate using the "..." differently.
				
                //this.textField.width = unscaledWidth - closeButton.width - CLOSE_BUTTON_X_OFFSET - 2;
                //this.textField.truncateToFit();
                
                // We place the closeButton 4 pixels from the top and 4 pixels from the left.
                // Why 4 pixels? Because I said so. 
                closeButton.x = CLOSE_BUTTON_X_OFFSET;
                closeButton.y = CLOSE_BUTTON_Y_OFFSET;
                //closeButton.y = unscaledHeight - closeButton.height - 5;
            }
        }
		
		override public function set label(value:String):void{
			originalLabel = value;
			var last:int = value.lastIndexOf("/");
			if (value.lastIndexOf("\\") > last) {
				last = value.lastIndexOf("\\");
			}
			super.label = value.substring(last + 1);
		}
		
		mx_internal override function layoutContents(unscaledWidth:Number, unscaledHeight:Number, offset:Boolean):void
		{
					
			var labelWidth:Number = 0;
			var labelHeight:Number = 0;

			var labelX:Number = 0;
			var labelY:Number = 0;

			var iconWidth:Number = 0;
			var iconHeight:Number = 0;

			var iconX:Number = 0;
			var iconY:Number = 0;

			var horizontalGap:Number = 0;
			var verticalGap:Number = 0;

			var paddingLeft:Number = getStyle("paddingLeft");
			var paddingRight:Number = getStyle("paddingRight");
			var paddingTop:Number = getStyle("paddingTop");
			var paddingBottom:Number = getStyle("paddingBottom");
			
			var textWidth:Number = 0;
			var textHeight:Number = 0;

			var lineMetrics:TextLineMetrics;
			
			if (label)
			{
				lineMetrics = measureText(label);
				textWidth = lineMetrics.width + TEXT_WIDTH_PADDING;
				textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
			}
			else
			{
				lineMetrics = measureText("Wj");
				textHeight = lineMetrics.height + UITextField.TEXT_HEIGHT_PADDING;
			}

			var n:Number = offset ? buttonOffset : 0;

			var textAlign:String = getStyle("textAlign");
			
			var viewWidth:Number = unscaledWidth;
			var viewHeight:Number = unscaledHeight;

			var bm:EdgeMetrics = currentSkin &&
								 currentSkin is IBorder && !(currentSkin is IFlexAsset) ?
								 IBorder(currentSkin).borderMetrics :
								 null;

			if (bm)
			{
				viewWidth -= bm.left + bm.right;
				viewHeight -= bm.top + bm.bottom;
			}

			if (currentIcon)
			{
				iconWidth = currentIcon.width;
				iconHeight = currentIcon.height;
			}

			if (labelPlacement == ButtonLabelPlacement.LEFT || labelPlacement == ButtonLabelPlacement.RIGHT) {
				horizontalGap = getStyle("horizontalGap");

				if (iconWidth == 0 || textWidth == 0)
					horizontalGap = 0;

				if (textWidth > 0)
				{
					textField.width = labelWidth = 
						Math.max(Math.min(viewWidth - iconWidth - horizontalGap -
										  paddingLeft - paddingRight - closeButton.width - 2*CLOSE_BUTTON_X_OFFSET, textWidth), 0);
				}
				else
				{
					textField.width = labelWidth = 0;
				}
				textField.height = labelHeight = Math.min(viewHeight, textHeight);
				
				if (textAlign == "left")
				{
					labelX += paddingLeft;
				}
				else if (textAlign == "right")
				{
					labelX += (viewWidth - labelWidth - iconWidth - 
							   horizontalGap - paddingRight);
				}
				else // "center" -- default value
				{
					
					labelX += ((viewWidth - labelWidth - iconWidth - 
                           horizontalGap - paddingLeft - paddingRight) / 2) + paddingLeft;
				}

				if (labelPlacement == ButtonLabelPlacement.RIGHT)
				{
					labelX += iconWidth + horizontalGap;
					iconX = labelX - (iconWidth + horizontalGap);
				}
				else
				{
					iconX  = labelX + labelWidth + horizontalGap; 
				}

				iconY  = ((viewHeight - iconHeight - paddingTop - paddingBottom) / 2) + paddingTop;
				labelY = ((viewHeight - labelHeight - paddingTop - paddingBottom) / 2) + paddingTop;
			}
			else
			{
				verticalGap = getStyle("verticalGap");

				if (iconHeight == 0 || label == "")
					verticalGap = 0;

				if (textWidth > 0)
				{
					textField.width = labelWidth = Math.max(viewWidth - paddingLeft - paddingRight, 0);
					textField.height = labelHeight =
						Math.min(viewHeight - iconHeight - paddingTop - paddingBottom - verticalGap, textHeight);
				}
				else
				{
					textField.width = labelWidth = 0;
					textField.height = labelHeight = 0;
				}
				labelX = paddingLeft;

				if (textAlign == "left")
				{
					iconX += paddingLeft;
				}
				else if (textAlign == "right")
				{
					iconX += Math.max(viewWidth - iconWidth - paddingRight, paddingLeft);
				}
				else
				{
					iconX += ((viewWidth - iconWidth - paddingLeft - paddingRight) / 2) + paddingLeft;
				}

				if (labelPlacement == ButtonLabelPlacement.TOP)
				{
					labelY += ((viewHeight - labelHeight - iconHeight - 
								paddingTop - paddingBottom - verticalGap) / 2) + paddingTop;
					iconY += labelY + labelHeight + verticalGap;
				}
				else
				{
					iconY += ((viewHeight - labelHeight - iconHeight - 
								paddingTop - paddingBottom - verticalGap) / 2) + paddingTop;
					labelY += iconY + iconHeight + verticalGap;
				}

			}
			var buffX:Number = n;
			var buffY:Number = n;

			if (bm)
			{
				buffX += bm.left;
				buffY += bm.top;
			}

// Changed Label always on top an center
			textField.x = Math.round(labelX + buffX);
			//textField.y = Math.round(labelY + buffY);
			textField.y = Math.round(labelY + buffY);

			if (currentIcon)
			{
				iconX += buffX;
				iconY += buffY;

				// dispatch a move on behalf of the icon
				// the focus system uses that to adjust
				// focus rectangles
				var moveEvent:MoveEvent = new MoveEvent(MoveEvent.MOVE);
				moveEvent.oldX = currentIcon.x;
				moveEvent.oldY = currentIcon.y;

				currentIcon.x = Math.round(iconX);
				currentIcon.y = Math.round(iconY);
				currentIcon.dispatchEvent(moveEvent);
			}

			// The skins and icons get created on demand as the user interacts
			// with the Button, and as they are created they become the
			// frontmost child.
			// Here we ensure that the textField is the frontmost child,
			// with the current icon behind it and the current skin behind that.
			// Any other skins and icons are left behind these three,
			// with arbitrary layering.
			if (currentSkin)
				setChildIndex(DisplayObject(currentSkin), numChildren - 1);
			if (currentIcon)
				setChildIndex(DisplayObject(currentIcon), numChildren - 1);
			if (textField)
				setChildIndex(DisplayObject(textField), numChildren - 1);
			if (closeButton){
				setChildIndex(DisplayObject(closeButton), numChildren - 1);
				setChildIndex(indicator, numChildren - 1);
			}
		}
		
	}
	
}