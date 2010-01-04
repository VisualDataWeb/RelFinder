package global 
{
	/**
	 * ...
	 * @author ...
	 */
	public class GlobalString
	{
		// LookUp
		public static const SEPARATOR:String = "-----------------------------------------";
		public static const SEARCHING:String = "Searching...";
		public static const NORESULTS:String = "No results found";
		public static const SEARCHMORE:String = "Search for more";
		public static const ERROR:String = "Error. Please check SPARQL configuration.";
		
		// Status Model
		public static const STATUS:String = "Status";
		public static const IDLE:String = "Idle";
		public static const NOCONNECTION:String = "Database not available. Check network connection.";
		public static const SOMEERRORS:String = "Some Errors occured.";
		public static const NORELATION:String = "No Relation found";
		public static const SEARCHINGRELATION:String = "Searching for relations";
		public static const LOOKUP:String = "Searching for resources";
		public static const BUILDING:String = "Building graph";
		
		// Error Log
		public static const FINE:String = "Everything seems to be fine. No Errors were received";
		
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