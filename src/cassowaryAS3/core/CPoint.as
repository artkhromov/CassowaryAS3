package cassowaryAS3.core
{
	import cassowaryAS3.variables.CVariable;

	public class CPoint
	{
		private var _xVar:CVariable;
		private var _yVar:CVariable;
		
		/**
		 * Syntax.
		 * <li> [Blank - defaluts to 0.0 ]</li>
		 * <li>[x : Number - y : Number]</li>
		 * <li> [x : Variable - y : Variable]</li>
		 * Parameters could be different types of even "null";
		 */ 
		public function CPoint(...args):void
		{
		
			var xValue:Number = 0.0;
			var yValue:Number = 0.0;
			var a:Number = 0;
			
			if (args.length >= 1)
			{
				if (args[0] is CVariable) _xVar = args[0];
				else if (args[0] is Number) xValue = args[0];
				else if (args[0] is int) xValue = args[0];
			}
			if (args.length >= 2)
			{
				if (args[1] is CVariable) _yVar = args[1];
				else if (args[1] is Number) yValue = args[1];
				else if (args[1] is int) yValue = args[0];
			}
			if (args.length >= 3)
			{
				if (args[2] is Number) a = args[2];
			}
			
			if (!_xVar) _xVar = new CVariable("x"+a,xValue);
			if (!_yVar) _yVar = new CVariable("y"+a,yValue);
			
		}
		
		public function get xVar():CVariable
		{
			return _xVar;
		}
		public function get yVar():CVariable
		{
			return _yVar;
		}
		public function setXY(x:Number,y:Number):void
		{
			_xVar.value = x;
			_yVar.value = y;
		}
		public function setXYVar(x:CVariable,y:CVariable):void
		{
			_xVar = x;
			_yVar = y;
		}
		public function get x():Number
		{
			return _xVar.value;
		}
		public function get y():Number
		{
			return _yVar.value;
		}
		public function toString():String
		{
			return "("+_xVar.toString()+", "+_yVar.toString()+")";
		}
			
	}
}