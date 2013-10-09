package cassowaryAS3.constraints
{
	import cassowaryAS3.core.CStrength;

	public class CLinearConstraint extends CConstraint
	{
		protected var _expression:CLinearExpression;
		
		public function CLinearConstraint(aExpression:CLinearExpression = null,aStrength:CStrength=null, aWeight:Number=1.0)
		{
			super(aStrength, aWeight);
			_expression = aExpression;
			
		}
		override public function get expression():CLinearExpression
		{
			return _expression;
		}
		protected function setExpression(expr:CLinearExpression):void
		{
			_expression = expr;
		}
	}
}