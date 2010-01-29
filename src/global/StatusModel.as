package global 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import mx.collections.ArrayCollection;
	
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class StatusModel implements IEventDispatcher
	{
		//*** Singleton **********************************************************
		private static var instance:StatusModel;
		
		private var eventDispatcher:EventDispatcher;
		
		public function StatusModel(singleton:SingletonEnforcer) 
		{
			eventDispatcher = new EventDispatcher();
		}
		
		public static function getInstance():StatusModel{
			if (StatusModel.instance == null){
				StatusModel.instance = new StatusModel(new SingletonEnforcer());
				
			}
			return StatusModel.instance;
		}
		//************************************************************************	
		
		
		private var _message:String = GlobalString.IDLE;
		
		[Bindable(event = "eventMessageChanged")]
		public function get message():String {
			
			if (_searchCount == _errorCount && _searchCountLookUp == _errorCountLookUp && _searchCount != 0) {
				
				_message = GlobalString.NOCONNECTION;
				
			}else {
				
				if ((_searchCount > _foundCount) && (_searchCountLookUp == _foundCountLookUp)) {
					_message = GlobalString.SEARCHINGRELATION;
				}else if ((_searchCount == _foundCount) && (_searchCountLookUp > _foundCountLookUp)) {
					_message = GlobalString.LOOKUP;
				}else if ((_searchCount > _foundCount) && (_searchCountLookUp > _foundCountLookUp)) {
					_message = GlobalString.SEARCHINGRELATION + " / " + GlobalString.LOOKUP;
				}else {
					
					if (_noRelationFound) {
						_message = GlobalString.NORELATION;
					}else {
						_message = GlobalString.IDLE;
					}
				}
				
			}
			
			if (!_queueIsEmpty) {
				_message += " / " + GlobalString.BUILDING;
			}
			
			if (_errorsOccured) {
				_message += " / " + GlobalString.SOMEERRORS;
			}
			
			return _message;
		}
		
		public function set message(message:String):void {
			_message = message;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		private var _searchCountLookUp:int = 0;
		private var _foundCountLookUp:int = 0;
		private var _errorCountLookUp:int = 0;
		
		public function addSearchLookUp():void {
			_searchCountLookUp++;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		public function addFoundLookUp():void {
			_foundCountLookUp++;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		public function addErrorLookUp(error:Object):void {
			_errorCountLookUp++;
			_errorsOccured = true;
			_errorLog.addItem(new LoggedError(error));
			dispatchEvent(new Event("eventMessageChanged"));
			dispatchEvent(new Event("errorLogChanged"));
		}
		
		private var _searchCount:int = 0;
		private var _foundCount:int = 0;
		private var _errorCount:int = 0;
		
		private var _queueIsEmpty:Boolean = true;
		
		public function addSearch():void {
			_searchCount++;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		public function addFound():void {
			_foundCount++;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		public function addError(error:Object):void {
			_errorCount++;
			_errorsOccured = true;
			_errorLog.addItem(new LoggedError(error));
			dispatchEvent(new Event("eventMessageChanged"));
			dispatchEvent(new Event("errorLogChanged"));
		}
		
		[Bindable(event="eventMessageChanged")]
		public function get searchCount():int {
			return _searchCount + _searchCountLookUp;
		}
		
		[Bindable(event="eventMessageChanged")]
		public function get foundCount():int {
			return _foundCount + _foundCountLookUp;
		}
		
		[Bindable(event="eventMessageChanged")]
		public function get errorCount():int {
			return _errorCount + _errorCountLookUp;
		}
		
		public function set queueIsEmpty(b:Boolean):void {
			if (_queueIsEmpty != b) {
				_queueIsEmpty = b;
				dispatchEvent(new Event("eventMessageChanged"));
			}
		}
		
		private var _errorLog:ArrayCollection = new ArrayCollection();
		
		[Bindable(event="errorLogChanged")]
		public function get errorLog():ArrayCollection {
			return _errorLog;
		}
		
		private var _noRelationFound:Boolean = false;
		
		public function resetNoRelationFound():void {
			_noRelationFound = true;
			_errorsOccured = false;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		public function addWasRelationFound(wasRelationFound:Boolean):void {
			_noRelationFound = _noRelationFound && !wasRelationFound;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		private var _errorsOccured:Boolean = false;
		
		public function clear():void {
			_searchCount = 0;
			_foundCount = 0;
			_errorCount = 0;
			_searchCountLookUp = 0;
			_foundCountLookUp = 0;
			_errorCountLookUp = 0;
			_noRelationFound = false;
			_errorsOccured = false;
			_queueIsEmpty = true;
			_errorLog.removeAll();
			_message = GlobalString.IDLE;
			dispatchEvent(new Event("eventMessageChanged"));
		}
		
		[Bindable(event = "eventMessageChanged")]
		public function get isSearching():Boolean{
			if ((_searchCount == 0) && (_queueIsEmpty)) {
				return false;
			}
			if (_searchCount == _errorCount) {
				
				return false;
				
			}else {
				
				if ((_searchCount > _foundCount) || (!_queueIsEmpty)) {
					return true;
				}else {
					return false;
				}
			}
		}
		
		//*** IEventDispatcher ***************************************************
		public function addEventListener(type:String, listener:Function,
			useCapture:Boolean = false, priority:int = 0, weakRef:Boolean = false):void{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, weakRef);
		}
		
		public function dispatchEvent(event:Event):Boolean{
			return eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean{
			return eventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function,
			useCapture:Boolean = false):void{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean {
			return eventDispatcher.willTrigger(type);
		}
		//************************************************************************
	}
}
class SingletonEnforcer{}