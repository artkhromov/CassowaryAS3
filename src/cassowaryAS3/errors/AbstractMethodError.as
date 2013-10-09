package cassowaryAS3.errors
{
	public class AbstractMethodError extends Error
	{
		public function AbstractMethodError(className:String,methodName:String, id:*=0)
		{
			var msg:String = "AbstractMethodError: Method "+methodName+" of class "+className+" must be overriden";
			super(msg, id);
		}
	}
}