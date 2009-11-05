////////////////////////////////////////////////////////////////////////////////
//
//	Copyright (c) 2007 Tink Ltd | http://www.tink.ws
//	
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//	documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
//	to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//	
//	The above copyright notice and this permission notice shall be included in all copies or substantial portions
//	of the Software.
//	
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
//	THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

package positionedTabNavigator
{
	
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import positionedTabNavigator.events.CloseTabEvent;
	import mx.controls.Button;
	import mx.controls.tabBarClasses.Tab;
	import mx.skins.halo.ButtonSkin;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManager;
	import mx.core.UIComponent;
	import positionedTabNavigator.skins.FilterTabSkin;
	import positionedTabNavigator.skins.PositionedTabSkin;

	
	[Style(name="position", type="String", enumeration="top,bottom,left,right", inherit="no")]
	
	/**
     *  Name of CSS style declaration that specifies the style to use for the 
     *  close button
     */
    [Style(name="closeButtonStyleName", type="String", inherit="no")]

	public class PositionedTab extends Tab
	{
		
        /**
         * Static variables indicating the policy to show the close button.
         * 
         * CLOSE_ALWAYS means the close button is always shown
         * CLOSE_SELECTED means the close button is only shown on the currently selected tab
         * CLOSE_ROLLOVER means the close button is show if the mouse rolls over a tab
         * CLOSE_NEVER means the close button is never show.
         */
        public static const CLOSE_ALWAYS:String = "close_always";
        public static const CLOSE_SELECTED:String = "close_selected";
        public static const CLOSE_ROLLOVER:String = "close_rollover";
        public static const CLOSE_NEVER:String = "close_never";
        
		public static const CLOSE_BUTTON_SIZE:int = 12;
		public static const CLOSE_BUTTON_X_OFFSET:int = 4;
		public static const CLOSE_BUTTON_Y_OFFSET:int = 3;
		
		
        // Our private variable to track the rollover state
        protected var _rolledOver:Boolean = false;

		protected var closeButton:Button;
		protected var indicator:DisplayObject;

		
	    /**
	     *  Constructor.
	     */
		public function PositionedTab()
		{
			super();
			this.mouseChildren = true;
		}
		
		private var _closePolicy:String = PositionedTab.CLOSE_ALWAYS;
        
        /**
         * A string representing when to show the close button for the tab.
         * Possible values include: SuperTab.CLOSE_ALWAYS, SuperTab.CLOSE_SELECTED,
         * SuperTab.CLOSE_ROLLOVER, SuperTab.CLOSE_NEVER
         */
        public function get closePolicy():String {
            return _closePolicy;
        }
        
        public function set closePolicy(value:String):void {
            this._closePolicy = value;
            this.invalidateDisplayList();
        }
        
        private var _showIndicator:Boolean = false;
        protected var _indicatorOffset:Number = 0;
        
        /**
         * A Boolean to determine whether we should draw the indicator arrow icon.
         */
        public function get showIndicator():Boolean {
            return _showIndicator;
        }
        
        public function set showIndicator(val:Boolean):void {
            this._showIndicator = val;
            
            this.invalidateDisplayList();
        }
        
        public function showIndicatorAt(x:Number):void {
            this._indicatorOffset = x;
            this.showIndicator = true;    
        }
		
		//--------------------------------------------------------------------------
	    //
	    //  Setup default styles.
	    //
	    //--------------------------------------------------------------------------
	    
		private static var defaultStylesSet	: Boolean = setDefaultStyles();
		
		/* extended ButtonTab overrides this function
		override protected function createChildren():void 
		{
			super.createChildren();
			
			// Here the width and height of the closeButton are hardcoded.
            // To make the component more customizable I suppoose the width and
            // height could be controlled by either a button skin, or by a property 
            closeButton = new Button();
            closeButton.width = CLOSE_BUTTON_SIZE;
            closeButton.height = CLOSE_BUTTON_SIZE;
            
            // We have to listen for the click event so we know to close the tab
            closeButton.addEventListener(MouseEvent.CLICK, closeClickHandler, false, 0, true); 
        
            // This allows someone to specify a CSS style for the close button
            //closeButton.styleName = getStyle("closeButtonStyleName");
            
			closeButton.setStyle( "skin", CloseButtonSkin );
			
            var indicatorClass:Class = getStyle("indicatorClass") as Class;
            if(indicatorClass) {
                indicator = new indicatorClass() as DisplayObject;
            }
            else {
                indicator = new UIComponent();
            }
            
            addChild(indicator);
            addChild(closeButton);
		}*/
		
		/*
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
            
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            // We need to make sure that the closeButton and the indicator are
            // above all other display items for this button. Otherwise the button
            // skin or icon or text are placed over the closeButton and indicator.
            // That's no good because then we can't get clicks and it looks funky.
            setChildIndex(closeButton, numChildren - 2);
            setChildIndex(indicator, numChildren - 1);
            
            
            closeButton.visible = false;
            indicator.visible = false;
            
            // Depedning on the closePolicy we might be showing the closeButton
            // and it may or may not be enabled.
            if(_closePolicy == PositionedTab.CLOSE_SELECTED) {
                if(selected) {
                    closeButton.visible = true;
                    closeButton.enabled = true;
                }
            }
            else {
                if(!_rolledOver) {
                    if(_closePolicy == PositionedTab.CLOSE_ALWAYS){
                        closeButton.visible = true;
                        closeButton.enabled = false;
                    }
                    else if(_closePolicy == PositionedTab.CLOSE_ROLLOVER) {
                        closeButton.visible = false;
                        closeButton.enabled = false;
                    }
                }
                else {
                    if(_closePolicy != PositionedTab.CLOSE_NEVER) {
                        closeButton.visible = true;
                        closeButton.enabled = true;
                    }
                }
            }
            
            if(_showIndicator) {
                indicator.visible = true;
                indicator.x = _indicatorOffset - indicator.width/2;
                indicator.y = this.height - 12;
            }
            
            if(closeButton.visible) {
                // Resize the text if we're showing the closeIcon, so the
                // closeIcon won't overlap the text. This means the text may
                // have to truncate using the "..." differently.
				
                this.textField.width = unscaledWidth - closeButton.width - CLOSE_BUTTON_X_OFFSET - 2;
                this.textField.truncateToFit();
                
                // We place the closeButton 4 pixels from the top and 4 pixels from the left.
                // Why 4 pixels? Because I said so. 
                closeButton.x = unscaledWidth-closeButton.width - CLOSE_BUTTON_X_OFFSET;
                closeButton.y = CLOSE_BUTTON_Y_OFFSET;
                //closeButton.y = unscaledHeight - closeButton.height - 5;
            }
        }
		*/
        
        /**
         * We keep track of the rolled over state internally so we can set the
         * closeButton to enabled or disabled depending on the state.
         */
        override protected function rollOverHandler(event:MouseEvent):void{
            _rolledOver = true;
            //
            //super.rollOverHandler(event);    
        }
        
        override protected function rollOutHandler(event:MouseEvent):void{
            _rolledOver = false;
            
            super.rollOutHandler(event);    
        }
        
        /**
         * The click handler for the close button.
         * This makes the SuperTab dispatch a CLOSE_TAB_EVENT. This doesn't actually remove
         * the tab. We don't want to remove the tab itself because that will happen
         * when the SuperTabNavigator or SuperTabBar removes the child container. So within the SuperTab
         * all we need to do is announce that a CLOSE_TAB_EVENT has happened, and we leave
         * it up to someone else to ensure that the tab is actually removed.
         */
        protected function closeClickHandler(event:MouseEvent):void {
            dispatchEvent(event);
            event.stopImmediatePropagation();
        }
		
		/**
	     *  @private
	     */
		private static function setDefaultStyles():Boolean
		{
			var style:CSSStyleDeclaration = StyleManager.getStyleDeclaration( "PositionedTab" );
			
		    if( !style )
		    {
		        style = new CSSStyleDeclaration();
		        StyleManager.setStyleDeclaration( "PositionedTab", style, true );
		    }
		    
		    if( style.defaultFactory == null )
	        {
	        	style.defaultFactory = function():void
	            {
	            	this.position = "left";
					this.paddingLeft = 1;
					this.paddingRight = 1;
	            	this.skin = FilterTabSkin;
	            };
	        }
			
			

		    return true;
		}
	}
}