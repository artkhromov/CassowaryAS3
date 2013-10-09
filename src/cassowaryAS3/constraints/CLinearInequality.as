package cassowaryAS3.constraints
{
	import cassowaryAS3.errors.InternalError;
	import cassowaryAS3.variables.CVariable;
	import cassowaryAS3.core.CStrength;
	import cassowaryAS3.core.Relation;

	public class CLinearInequality extends CLinearConstraint
	{
		
		/**
		 * Syntax.
		 * <li>[expression : LinearExpression - strength : Strength (optional) - weight : Number (optional)]</li>
		 * <li>[expression : LinearExpression - relation : String - expression : LinearExpression - strength : Strength (optional) - weight : Number (optional)]</li>
		 * <li>[expression : LinearExpression - relation : String - variable : Variable - strength : Strength (optional) - weight : Number (optional)]</li>
		 * <li>[variable : Variable - relation : String - value : Number - strength:Strength (optional) - weight : Number (optional)]</li>
		 * <li>[variable : Variable - relation : String - variable : Variable - strength:Strength (optional) - weight : Number (optional)]</li>
		 * <li>[variable : Variable - relation : String - expression : LinearExpression - strength:Strength (optional) - weight : Number (optional)]</li>
		 */ 
		public function CLinearInequality(...args)
		{
			var numArgs:int = args.length;
			
			var expr1:CLinearExpression;
			var expr2:CLinearExpression;
			
			var var1:CVariable;
			var var2:CVariable;
			
			var varValue:Number;//check default
			
			var strength:CStrength;
			var weight:Number = 1.0;
			var relation:String;
			
			super();
			
			if (numArgs == 0) throw new ArgumentError("LinearInequality: constructor must receive at least 1 parameter");
			
			if (args[0] is CLinearExpression)
			{
				expr1 = args[0];
				
				if (numArgs >= 2)
				{
					if (args[1] is CStrength)
					{
						strength = args[1];
						if (numArgs>=3 && args[2] is Number) weight = args[2];
						
						//init with one expression
						setExpression(expr1);
						//super(expr1);
					}
					else if (args[1] is String) //relation
					{
						relation = args[1];
						
						if (!Relation.checkValue(relation)) throw new ArgumentError("LinearInequality: wrong relation value");
						
						if (numArgs >= 3)
						{
							if (args[2] is CVariable)
							{
								var1 = args[2];
								if (numArgs >= 4 && args[3] is CStrength) strength = args[3];
								if (numArgs >= 5 && args[4] is Number) weight = args[4];
								
								//init with expression - relation - variable
								setExpression(expr1.clone());
								setStrength(strength);
								setWeight(weight);
								//super(expr1.clone(),strength,weight);
								
								if (relation == Relation.LESS_OR_EQUAL)
								{
									_expression.multiplyMe(-1.0);
									_expression.addVariable(var1);
								}
								else if (relation == Relation.GREATER_OR_EQUAL)
								{
									_expression.addVariable(var1,-1.0);
								}
								//init end
							}
							else if (args[2] is CLinearExpression)
							{
								expr2 = args[2];
								if (numArgs >= 4 && args[3] is CStrength) strength = args[3];
								if (numArgs >= 5 && args[4] is Number) weight = args[4];
								
								//init with expression - relation - expression
								
								setExpression(expr2.clone());
								setStrength(strength);
								setWeight(weight);
								
								//super(expr2.clone(),strength,weight);
								
								if (relation == Relation.GREATER_OR_EQUAL)
								{
									_expression.multiplyMe(-1.0);
									_expression.addExpression(expr1);
								}
								else if (relation == Relation.LESS_OR_EQUAL)
								{
									_expression.addExpression(expr1,-1.0);
								}
								//init end
							}
							else
							{
								throw new ArgumentError("LinearInequality: invalid value after relation - must be variable or expression");
							}
						}
						else 
						{
							throw new ArgumentError("LinearInequality: must receive second value after relation");
						}
					}
					else
					{
						// init with one expression
						setExpression(expr1);
						//super(expr1);
					}
				}
				else 
				{
					// init with one expression
					setExpression(expr1);
					//super(expr1);
				}
			}// first expression end
			else if (args[0] is CVariable)
			{
				var1 = args[0];
				
				if (numArgs >= 2)
				{
					if (args[1] is String) //relation
					{
						relation = args[1];
						if (numArgs >=3)
						{
							if (args[2] is CVariable)
							{
								var2 = args[2];
								if (numArgs >= 4 && args[3] is CStrength) strength = args[3];
								if (numArgs >= 5 && args[4] is Number) weight = args[4];
								
								//init with variable - relation - variable
								setExpression(new CLinearExpression(var2));
								setStrength(strength);
								setWeight(weight);
								//super(new LinearExpression(var2),strength,weight);
								
								if (relation == Relation.GREATER_OR_EQUAL)
								{
									_expression.multiplyMe(-1.0);
									_expression.addVariable(var1);
								}
								else if (relation == Relation.LESS_OR_EQUAL)
								{
									_expression.addVariable(var1,-1.0);
								}
								//init end
								
							}
							else if (args[2] is CLinearExpression)
							{
								expr1 = args[2];
								if (numArgs >= 4 && args[3] is CStrength) strength = args[3];
								if (numArgs >= 5 && args[4] is Number) weight = args[4];
								
								//init with variable-relation-expression
								
								setExpression(expr1.clone());
								setStrength(strength);
								setWeight(weight);
								//super(expr1.clone(),strength,weight);
								
								if (relation == Relation.GREATER_OR_EQUAL)
								{
									_expression.multiplyMe(-1.0);
									_expression.addVariable(var1);
								}
								else if (relation == Relation.LESS_OR_EQUAL)
								{
									_expression.addVariable(var1,-1.0);
								}
								//init end
							}
							else if (args[2] is Number)
							{
								varValue = args[2];
								if (numArgs >= 4 && args[3] is CStrength) strength = args[3];
								if (numArgs >= 5 && args[4] is Number) weight = args[4];
								
								//init with variable - relation - value
								
								setExpression(new CLinearExpression(varValue));
								setStrength(strength);
								setWeight(weight);
								//super(new LinearExpression(varValue),strength,weight);
								
								if (relation == Relation.GREATER_OR_EQUAL)
								{
									_expression.multiplyMe(-1.0);
									_expression.addVariable(var1);
								}
								else if (relation == Relation.LESS_OR_EQUAL)
								{
									_expression.addVariable(var1,-1.0);
								}
								//init end
							}
							else
							{
								throw new ArgumentError("LinearInequality: invalid value after relation - " +
									"must be variable, value or expression");
							}
						}
						else
						{
							throw new ArgumentError("LinearInequality: must receive second value after relation");
						}
					}
					else
					{
						throw new ArgumentError("LinearInequality: must receive relation after variable");
					}
				}
				else 
				{
					throw new ArgumentError("LinearInequality: incorrect number of arguments + must receive relation ");
				}
			}
			//could cause errors!
			
			expr1 = null;
			expr2 = null;
			
			var1 = null;
			var2 = null;
			
			strength = null;
			
		}
		
		override public function isInequality():Boolean
		{
			return true;
		}
		override public function toString():String
		{
			return super.toString() + " >= 0 )";
		}
	}
}