package cassowaryAS3.core
{
	public class CSymbolicWeight
	{
		private var _values:Vector.<Number>;
		
		public static const clsZero:CSymbolicWeight = new CSymbolicWeight(new <Number>[0.0,0.0,0.0]);
		
		public function CSymbolicWeight(...args):void
		{
			var i:int;
			var a:int;
			_values = new Vector.<Number>;
			
			for (i = 0;i<args.length;i++)
			{
				if (args[i] is Array)
				{
					var arr:Array = args[i];
					for (a = 0;a<arr.length;a++)
					{
						_values.push(arr[a]);
					}
				}
				else if (args[i] is Vector.<Number>)
				{
					var vec:Vector.<Number> = args[i];
					for (a=0;a<vec.length;a++)
					{
						_values.push(vec[a]);
					}
				}
				else if (args[i] is Number)
				{
					_values.push(args[i]);
				}
			}
			
		}
		public function clone():CSymbolicWeight
		{
			return new CSymbolicWeight(_values);
		}
		public function times(n:Number):CSymbolicWeight
		{
			var sw:CSymbolicWeight = clone();
			for (var i:int = 0;i<_values.length;i++)
			{
				sw.rawValues[i] *= n;
			}
			return sw;
		}
		public function divideBy(n:Number):CSymbolicWeight
		{
			var sw:CSymbolicWeight = clone();
			for (var i:int = 0;i<_values.length;i++)
			{
				sw.rawValues[i] /= n;
			}
			return sw;
		}
		public function add(s:CSymbolicWeight):CSymbolicWeight
		{
			var sw:CSymbolicWeight = clone();
			for (var i:int = 0;i<_values.length;i++)
			{
				sw.rawValues[i] += s._values[i];
			}
			return sw;
		}
		public function subtract(s:CSymbolicWeight):CSymbolicWeight
		{
			var sw:CSymbolicWeight = clone();
			for (var i:int = 0;i<_values.length;i++)
			{
				sw.rawValues[i] -= s._values[i];
			}
			return sw;
		}
		public function lessThan(s:CSymbolicWeight):Boolean
		{
			for (var i:int = 0;i<_values.length;i++)
			{
				if (_values[i] < s.rawValues[i]) return true;
				else if (_values[i] > s.rawValues[i]) return false;
			}
			return false;
		}
		public function lessThanOrEqual(s:CSymbolicWeight):Boolean
		{
			for (var i:int = 0;i<_values.length;i++)
			{
				if (_values[i] < s.rawValues[i]) return true;
				else if (_values[i] > s.rawValues[i]) return false;
			}
			return true;
		}
		public function equal(s:CSymbolicWeight):Boolean
		{
			for (var i:int = 0;i<_values.length;i++)
			{
				if (_values[i] != s.rawValues[i]) return false;
			}
			return true;
		}
		public function greaterThan(s:CSymbolicWeight):Boolean
		{
			return !lessThanOrEqual(s);
		}
		
		public function greaterThanOrEqual(s:CSymbolicWeight):Boolean
		{
			return !lessThan(s);
		}
		public function isNegative():Boolean
		{
			return lessThan(clsZero);
		}
		public function asNumber():Number
		{
			var sw:CSymbolicWeight = clone();
			var sum:Number = 0;
			var factor:Number = 1;
			var multiplier:Number = 1000;
			
			for (var i:int = _values.length-1;i>=0;i--)
			{
				sum += _values[i]*factor;
				factor *= multiplier;
			}
			return sum;
		}
		
		public function toString():String
		{
			var result:String = "[";
			for (var i:int = 0;i<_values.length;i++)
			{
				result += _values[i].toString();
				result += ",";
			}
			result += _values[_values.length-1].toString();
			result += "]";
			return result;
		}
		
		public function cLevels():int
		{
			return _values.length;
		}
		public function get rawValues():Vector.<Number>
		{
			return _values;
		}
		
	
		
	}
}