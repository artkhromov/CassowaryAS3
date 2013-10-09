package cassowaryAS3.core
{
	public class CDouble
	{
		private var _value:Number;
		
		public function CDouble(value:Number = 0.0)
		{
			_value = value;
		}
		public function get value():Number
		{
			return _value;	
		}
		public function set value(v:Number):void
		{
			_value = v;
		}
		public function greaterThan(v:*):Boolean
		{
			if (v is Number) return _value > Number(v);
			else if (v is int) return _value > int(v);
			else if (v is CDouble) return _value > CDouble(v).value;
			else throw new Error("CDouble: unable to compare "+v);
		}
		public function lessThan(v:*):Boolean
		{
			if (v is Number) return _value < Number(v);
			else if (v is int) return _value < int(v);
			else if (v is CDouble) return _value < CDouble(v).value;
			else throw new Error("CDouble: unable to compare "+v);
		}
		
		public function greaterThanOrEqual(v:*):Boolean
		{
			if (v is Number) return _value >= Number(v);
			else if (v is int) return _value >= int(v);
			else if (v is CDouble) return _value >= CDouble(v).value;
			else throw new Error("CDouble: unable to compare "+v);
		}
		public function lessThanOrEqual(v:*):Boolean
		{
			if (v is Number) return _value <= Number(v);
			else if (v is int) return _value <= int(v);
			else if (v is CDouble) return _value <= CDouble(v).value;
			else throw new Error("CDouble: unable to compare "+v);
		}
		public function equal(v:*):Boolean
		{
			if (v is Number) return _value == Number(v);
			else if (v is int) return _value == int(v);
			else if (v is CDouble) return _value == CDouble(v).value;
			else throw new Error("CDouble: unable to compare "+v);
		}
		public function clone():CDouble
		{
			return new CDouble(_value);
		}
	}
}