package cassowaryAS3.constraints
{
	import cassowaryAS3.variables.CVariable;
	import cassowaryAS3.core.CStrength;

	public class CEditConstraint extends CEditOrStayConstraint
	{
		public function CEditConstraint(aVariable:CVariable, aStrength:CStrength=null, aWeight:Number=1.0)
		{
			if (aStrength == null) aStrength = CStrength.strong();
			super(aVariable, aStrength, aWeight);
		}
		override public function isEditConstraint():Boolean
		{
			return true;
		}
		override public function toString():String
		{
			return "edit "+super.toString();
		}
	}
}