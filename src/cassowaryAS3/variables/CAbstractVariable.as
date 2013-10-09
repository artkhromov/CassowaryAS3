package cassowaryAS3.variables
{
	import cassowaryAS3.errors.AbstractMethodError;
	
	import cassowaryAS3.core.CUtils;

	public class CAbstractVariable
	{
		protected var _name:String;
		private static var iVariableNumber:int;
		
		public function CAbstractVariable(aName:String = ""):void
		{
			if (aName != "") _name = aName;
			else _name = "v"+iVariableNumber.toString();
			iVariableNumber++;
		}
		
		public function get name():String
		{
			return _name;
		}
		public function set name(value:String):void
		{
			_name = value;
		}
		public function isDummy():Boolean
		{
			return false;
		}
		public static function numCreated():int
		{
			return iVariableNumber;
		}
		public function isExternal():Boolean
		{
			throw new AbstractMethodError("variables.CAbstractVariable","isExternal()");
			return false;
		}
		public function isPivotable():Boolean
		{
			throw new AbstractMethodError("variables.CAbstractVariable","isPivotable()");
			return false;
		}
		public function isRestricted():Boolean
		{
			throw new AbstractMethodError("variables.CAbstractVariable","isRestricted()");
			return false;
		}
		public function toString():String
		{
			return "["+name+" :abstract]";
		}
	}
}