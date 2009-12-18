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
			
			if (xml.example is ArrayCollection) {
				
				for each (var example:Object in xml.example) {
					var ex:Example = new Example();
					
					for each(var obj:Object in (example.object as ArrayCollection)) {
						
						obj.uris = new Array(obj.uri);
						
						ex.objects.addItem(obj);
					}
					
					ex.endpointConfig = ConnectionModel.getInstance().getSPARQLByAbbreviation(example.endpoint.toString());
					
					((Application.application as Main).tabExamples as ExampleBox).examples.addItem(ex);
				}
				
			}else {
				
				var ex2:Example = new Example();
				
				ex2.endpointConfig = ConnectionModel.getInstance().getSPARQLByAbbreviation(xml.example.endpoint.toString());
				
				for each(var obj2:Object in (xml.example.object as ArrayCollection)) {
						
					obj2.uris = new Array(obj2.uri);
					
					ex2.objects.addItem(obj2);
				}
				
				((Application.application as Main).tabExamples as ExampleBox).examples.addItem(ex2);
				
			}
			
			
		}
		
	}

}