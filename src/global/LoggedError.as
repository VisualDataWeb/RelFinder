package global 
{
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.FaultEvent;
	import mx.utils.ObjectUtil;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class LoggedError
	{
		
		public function LoggedError(error:Object) 
		{
			this.error = error
		}
		
		private var _error:Object;
		
		public function set error(value:Object):void {
			_error = value;
			time = new Date();
		}
		
		[Bindable]
		public function get error():Object {
			return _error;
		}
		
		private var _time:Date = null;
		
		private function set time(value:Date):void {
			_time = value;
		}
		
		[Bindable]
		public function get time():Date {
			return _time;
		}
		
		public function toString():String 
		{
			if (_error is FaultEvent) {
				try {
					var e:FaultEvent = error as FaultEvent;
					var faultString:String = e.fault.faultString;
					var message:HTTPRequestMessage = e.token.message as HTTPRequestMessage;
					
					var returnMsg:String = faultString + "\n" + "\turl: " + message.url + "\n";
					for (var key:Object in message.body) {
						returnMsg += "\t" + key.toString() + ": " + message.body[key] + "\n";
					}
					return returnMsg;
					
				}catch (err:Error) {
					return ObjectUtil.toString(_error);
				}
				
			}
			return ObjectUtil.toString(_error);
		}
		
	}

}