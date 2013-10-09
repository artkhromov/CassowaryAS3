package cassowaryAS3.constraints
{
	import cassowaryAS3.variables.CVariable;
	import cassowaryAS3.core.CStrength;

	public class CLinearEquation extends CLinearConstraint
	{
		/**
		 * Syntax.
		 * <li> [variable : Variable - expression : LinearExpression - strength:Strength (optional) - weight:Number (optional)] </li>
		 * <li> [variable : Variable - value:Number - strength:Strength (optional) - weight:Number (optional)] </li> 
		 * <li> [expression : LinearExpression - strength:Strength (optional) - weight:Number (optional)]</li>
		 * <li> [expression : LinearExpression - variable : Variable - strength:Strength (optional) - weight:Number (optional)] </li>
		 * <li> [expression : LinearExpression - expression : LinearExpression - strength:Strength (optional) - weight:Number (optional)] </li>
		 */ 
		public function CLinearEquation(...args):void
		{
			super();
			
			var numArgs:int = args.length;
			var aVariable:CVariable;
			var aExpression1:CLinearExpression;
			var aExpression2:CLinearExpression;
			var aStrength:CStrength;
			var aValue:Number = 0.0;
			var aWeight:Number = 1.0;
			
			if (numArgs == 0) 
			{
				throw new ArgumentError("LinearEquation: at least one parameter is expected in constructor");
			}
			if (args[0] is CVariable)
			{
				aVariable = args[0];
								
				if (numArgs >= 2)
				{ 
					if (args[1] is Number)
					{
						aValue = args[1];
						if (numArgs >= 3 && args[2] is CStrength) aStrength = args[2];
						if (numArgs >= 4 && args[3] is Number) aWeight = args[3];
						
						aExpression1 = new CLinearExpression(aValue);
						
						setExpression(aExpression1);
						setStrength(aStrength);
						setWeight(aWeight);
						
						//super(aExpression1,aStrength,aWeight);
						_expression.addVariable(aVariable,-1.0);
					}
					else if (args[1] is CLinearExpression)
					{
						aExpression1 = args[1];
						if (numArgs >= 3 && args[2] is CStrength) aStrength = args[2];
						if (numArgs >= 4 && args[3] is Number) aWeight = args[3];
						
						setExpression(aExpression1);
						setStrength(aStrength);
						setWeight(aWeight);
						//super(aExpression1,aStrength,aWeight);
						_expression.addVariable(aVariable,-1.0);
						
					}
					else throw new ArgumentError("LinearEquation: if 1st paramter is Variable - expression or value is expected as 2nd parameter");
				}
				else throw new ArgumentError("LinearEquation: if 1st paramter is Variable - expression or value is expected as 2nd parameter");
			}
			else if (args[0] is CLinearExpression)
			{
				aExpression1 = args[0];
				if (numArgs >= 2)
				{
					if (args[1] is CVariable)
					{
						aVariable = args[1];
						if (numArgs >= 3 && args[2] is CStrength) aStrength = args[2];
						if (numArgs >= 4 && args[3] is Number) aWeight = args[3];
						
						setExpression(aExpression1.clone());
						setStrength(aStrength);
						setWeight(aWeight);
						
						//super(aExpression1.clone(),aStrength,aWeight);
						_expression.addVariable(aVariable,-1.0);
					}
					else if (args[1] is CLinearExpression)
					{
						aExpression2 = args[1];
						if (numArgs >= 3 && args[2] is CStrength) aStrength = args[2];
						if (numArgs >= 4 && args[3] is Number) aWeight = args[3];
						
						setExpression(aExpression1.clone());
						setStrength(aStrength);
						setWeight(aWeight);
						
						//super(aExpression1.clone(),aStrength,aWeight);
						_expression.addExpression(aExpression2,-1.0);
					}
					else if (args[1] is CStrength) 
					{
						aStrength = args[1];
						if (numArgs >= 3 && args[2] is Number) aWeight = args[2];
						
						setExpression(aExpression1);
						setStrength(aStrength);
						setWeight(aWeight);
						
						//super(aExpression1,aStrength,aWeight);//
					}
				}
				else 
				{
					setExpression(aExpression1);
					setStrength(aStrength);
					setWeight(aWeight);
					
					//super(aExpression1,aStrength,aWeight);//
				}
			}
			else 
			{
				throw new ArgumentError("Linear equation: paramter order mismatch " +
				"- Variable or LinearExpression is expected as first.");
			}
			
			//could cause errors!
			
			aVariable = null;
			aExpression1 = null;
			aExpression2 = null;
			aStrength = null;
			
		}
	
		override public function toString():String
		{
			return super.toString() + " = 0 )"
		}

	
	}
}