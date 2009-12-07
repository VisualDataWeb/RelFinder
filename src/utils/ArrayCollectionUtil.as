package utils 
{
	import mx.collections.ArrayCollection;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class ArrayCollectionUtil
	{
		
		// 0: equal
		// Number.MIN_VALUE: both null
		// Number.MAX_VALUE: one null
		// <0: different lenght
		// >0: different entries
		public static function compare(ac1:ArrayCollection, ac2:ArrayCollection):Number {
			
			if (ac1 == null && ac2 == null) {
				return Number.MIN_VALUE;
			}
			
			if (ac1 == null || ac2 == null) {
				return Number.MAX_VALUE;
			}
			
			var a1:Array = ac1.source;
			var a2:Array = ac2.source;
			
			if (a1.length != a2.length) {
				return -Math.abs(a1.length - a2.length);
			}
			
			a1.sort();
			a2.sort();
			
			var compare:Number = 0;
			
			for (var i:int = 0; i < a1.length; i++) {
				if (a1[i].toString() != a2[i].toString()) {
					compare++;
				}
			}
			
			return compare;
			
		}
		
	}

}