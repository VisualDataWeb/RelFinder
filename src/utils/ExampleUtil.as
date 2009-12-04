package utils 
{
	import connection.model.ConnectionModel;
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	import mx.utils.ObjectUtil;
	/**
	 * ...
	 * @author Timo Stegemann
	 */
	public class ExampleUtil
	{
		
		public static function setExamplesFromXML(xml:Object):void {
			
			for each (var example:Object in xml.example) {
				var ex:Example = new Example();
				for each(var obj:Object in (example.object as ArrayCollection)) {
					
					obj.uris = new Array(obj.uri);
					
					ex.objects.addItem(obj);
				}
				
				ex.endpointConfig = ConnectionModel.getInstance().getSPARQLByAbbreviation(example.endpoint.toString());
				
				((Application.application as Main).tabExamples as ExampleBox).examples.addItem(ex);
			}
			
		}
		
	}

}