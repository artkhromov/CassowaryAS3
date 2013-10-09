package cassowaryAS3.variables
{

	public class CVariable extends CAbstractVariable
	{
		private static var _map:Object;
		private var _value:Number;
		private var _attachedObject:Object;
		
		public function CVariable(aName:String = "",aValue:Number = 0.0):void
		{
			super(aName);
			_value = aValue;
			if (_map)
			{
				_map[aName] = this;
			}
		}
		override public function isDummy():Boolean
		{
			return false;
		}
		
		override public function isExternal():Boolean
		{
			return true;
		}
		
		override public function isPivotable():Boolean
		{
			return false;
		}
		
		override public function isRestricted():Boolean
		{
			return false;
		}
		override public function toString():String
		{
			return "["+_name+":"+_value+"]";
		}
		public final function get value():Number
		{
			return _value;
		}
		public final function set value(v:Number):void
		{
			_value = v;
		}
		public function change_value(v:Number):void
		{
			_value = v;
		}
		public function set attachedObject(o:Object):void
		{
			_attachedObject = o;
		}
		public function get attachedObject():Object
		{
			return _attachedObject;
		}
		public static function set varMap(m:Object):void
		{
			_map = m;
		}
		public static function get varMap():Object
		{
			return _map;
		}
		
		
		
		
	}
}