package cassowaryAS3.variables
{

	public class CDummyVariable extends CAbstractVariable
	{
		public function CDummyVariable(aName:String = ""):void
		{
			super(aName);
		}
		
		override public function toString():String
		{
			return "["+name+" :dummy]";
		}
		override public function isDummy():Boolean
		{
			return true;
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
			return true;
		}
	}
}