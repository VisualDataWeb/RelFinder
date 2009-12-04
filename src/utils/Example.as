package utils 
{
	import connection.config.IConfig;
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectUtil;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class Example
	{
		
		[Bindable]
		public var objects:ArrayCollection = new ArrayCollection();
		
		public var endpointConfig:IConfig;
		
		public function toString():String 
		{
			return endpointConfig.name + " - " + ObjectUtil.toString(objects.toArray());
		}
		
	}

}