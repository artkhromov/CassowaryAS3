package cassowaryAS3.variables
{

	public class CObjectiveVariable extends CAbstractVariable
	{
		public function CObjectiveVariable(aName:String="")
		{
			super(aName);
		}
		override public function toString():String
		{
			return "["+name+" :obj]";
		}
		override public function isExternal():Boolean
		{
			return false;
		}
		
		override public function isPivotable():Boolean
		{
			return false;
		}
		
		override public function isRestricted():Boolean
		{
			return false;
		}
		
		
	}
}