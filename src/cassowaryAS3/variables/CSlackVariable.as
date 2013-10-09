package cassowaryAS3.variables
{

	public class CSlackVariable extends CAbstractVariable
	{
		public function CSlackVariable(aName:String="")
		{
			super(aName);
		}
		
		override public function isExternal():Boolean
		{
			return false;
		}
		
		override public function isPivotable():Boolean
		{
			return true;
		}
		
		override public function isRestricted():Boolean
		{
			return true;
		}
		override public function toString():String
		{
			return "["+name+" :slack]";
		}
		
		
	}
}