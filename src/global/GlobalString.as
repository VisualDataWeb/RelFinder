package global 
{
	/**
	 * ...
	 * @author ...
	 */
	public class GlobalString
	{
		
		public static const SEPARATOR:String = "-----------------------------------------";
		public static const SEARCHING:String = "Searching...";
		public static const NORESULTS:String = "No results found";
		public static const SEARCHMORE:String = "Search for more";
		public static const ERROR:String = "Error. Please check SPARQL configuration.";
		
		public static function getStrings():Array {
			var strings:Array = new Array();
			strings.push(SEPARATOR);
			strings.push(SEARCHING);
			strings.push(NORESULTS);
			strings.push(SEARCHMORE);
			strings.push(ERROR);
			return strings;
		}
		
	}

}