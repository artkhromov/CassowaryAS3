package cassowaryAS3.constraints
{
	import cassowaryAS3.variables.CVariable;
	import cassowaryAS3.core.CStrength;

	public class CEditOrStayConstraint extends CConstraint
	{
		protected var _variable:CVariable;
		protected var _expression:CLinearExpression;
		
		public function CEditOrStayConstraint(aVariable:CVariable,aStrength:CStrength=null, aWeight:Number=1.0)
		{
			super(aStrength, aWeight);
			_variable = aVariable;
			_expression = new CLinearExpression(_variable,-1.0,_variable.value);
		}
		public function get variable():CVariable
		{
			return _variable;
		}
		override public function get expression():CLinearExpression
		{
			return _expression;
		}
		
	}
}