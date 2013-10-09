package cassowaryAS3.core
{
	import cassowaryAS3.constraints.CLinearExpression;
	
	import flash.utils.Dictionary;
	
	import cassowaryAS3.variables.CVariable;

	public class CUtils
	{
	
		public function CUtils()
		{
		}
		
		
		
		public static function approxNumbers(a:Number,b:Number):Boolean
		{
			var result:Boolean;
			var epsilon:Number = 1.0e-8;
			if (a == 0.0) result =  Math.abs(b)<epsilon;
			else if (b==0.0) result =  Math.abs(a) < epsilon;
			else result = (Math.abs(a-b) < Math.abs(a)*epsilon);
			
			//trace("\n Approximate numbers "+a+" - "+b+" result: "+result);
			return result;
		}
		public static function approxVariableAndNumber(clv:CVariable,b:Number):Boolean
		{
			return approxNumbers(clv.value,b);
		}
		
		/**
		 * Syntax
		 * <li>[LinearExpression - LinearExpression]</li>
		 * <li>[LinearExpression - Number]</li>
		 * <li>[LinearExpression - Variable]</li>
		 * <li>[Number - LinearExpression]</li>
		 * <li>[Number - Variable]</li>
		 * <li>[Variable - LinearExpression]</li>
		 * <li>[Variable - Number]</li>
		 */ 
		public static function Plus(...args):CLinearExpression
		{
			if (args.length != 2) throw new ArgumentError("CUtils: incorrect number of arguments - expected 2");
			
			var e1:CLinearExpression;
			var e2:CLinearExpression;
			
			var value:Number;
			
			var var1:CVariable;
			
			if (args[0] is CLinearExpression)
			{
				e1 = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					return e1.plusExpr(e2);
				}
				else if (args[1] is Number)
				{
					value = args[1];
					return e1.plusExpr(new CLinearExpression(value));
				}
				else if (args[1] is CVariable)
				{
					var1 = args[1];
					return e1.plusExpr(new CLinearExpression(var1));
				}
			}
			else if (args[0] is Number)
			{
				value = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					e1 = new CLinearExpression(value);
					return e1.plusExpr(e2);
				}
				else if (args[1] is CVariable)
				{
					var1 = args[1];
					e1 = new CLinearExpression(value);
					e2 = new CLinearExpression(var1);
					return e1.plusExpr(e2);
				}
			}
			else if (args[0] is CVariable)
			{
				var1 = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					e1 = new CLinearExpression(var1);
					return e1.plusExpr(e2);
				}
				else if (args[1] is Number)
				{
					value = args[1];
					e1 = new CLinearExpression(var1);
					e2 = new CLinearExpression(value);
					return e1.plusExpr(e2);
				}
			}
			throw new ArgumentError("CUtils Plus - incorrect arguments");
		}
		
		/**
		 * Syntax.
		 * <li>[LinearExpression - LinearExpression]</li>
		 * <li>[LinearExpression - Number]</li>
		 * <li>[Number - LinearExpression]</li>
		 */ 
		public static function Minus(...args):CLinearExpression
		{
			var e1:CLinearExpression;
			var e2:CLinearExpression;
			
			var value:Number;
			
			if (args.length != 2) throw new ArgumentError("CUtils: incorrect number of arguments - expected 2");

			if (args[0] is CLinearExpression)
			{
				e1 = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					return e1.minusExpr(e2);
				}
				else if (args[1] is Number)
				{
					value = args[1];
					e2 = new CLinearExpression(value);
					return e1.minusExpr(e2);
				}
			}
			else if (args[0] is Number)
			{
				value = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					e1 = new CLinearExpression(value);
					return e1.minusExpr(e2);
				}
			}
			throw new ArgumentError("CUtils Minus - incorrect arguments");
		}
	
		/**
		 * Syntax
		 * <li>[LinearExpression - LinearExpression]</li>
		 * <li>[LinearExpression - Number]</li>
		 * <li>[LinearExpression - Variable]</li>
		 * <li>[Number - LinearExpression]</li>
		 * <li>[Number - Variable]</li>
		 * <li>[Variable - LinearExpression]</li>
		 * <li>[Variable - Number]</li>
		 */ 
		public static function Times(...args):CLinearExpression
		{
			if (args.length != 2) throw new ArgumentError("CUtils: incorrect number of arguments - expected 2");
			
			var e1:CLinearExpression;
			var e2:CLinearExpression;
			
			var value:Number;
			
			var var1:CVariable;
			
			if (args[0] is CLinearExpression)
			{
				e1 = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					return e1.timesExpr(e2);//
				}
				else if (args[1] is Number)
				{
					value = args[1];
					return e1.timesExpr(new CLinearExpression(value));//
				}
				else if (args[1] is CVariable)
				{
					var1 = args[1];
					return e1.timesExpr(new CLinearExpression(var1));//
				}
			}
			else if (args[0] is Number)
			{
				value = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					e1 = new CLinearExpression(value);
					return e1.timesExpr(e2);//
				}
				else if (args[1] is CVariable)
				{
					var1 = args[1];
					e1 = new CLinearExpression(var1,value);
					return e1;//
				}
			}
			else if (args[0] is CVariable)
			{
				var1 = args[0];
				if (args[1] is CLinearExpression)
				{
					e2 = args[1];
					e1 = new CLinearExpression(var1);
					return e1.timesExpr(e2);//
				}
				else if (args[1] is Number)
				{
					value = args[1];
					e1 = new CLinearExpression(var1,value);
					return e1;//
				}
			}
			throw new ArgumentError("CUtils Times - incorrect arguments");
		}
	
		/**
		 * Syntax
		 * <li>[LinearExpression - LinearExpression]</li>
		 */ 
		public static function Divide(...args):CLinearExpression
		{
			if (args.length != 2) throw new ArgumentError("CUtils: incorrect number of arguments - expected 2");
			if (args[0] is CLinearExpression && args[1] is CLinearExpression)
			{
				var e1:CLinearExpression = args[0];
				var e2:CLinearExpression = args[1];
				return e1.divideExpr(e2);
			}
			throw new ArgumentError("CUtils Divide - incorrect arguments");
		}
		
	}
}