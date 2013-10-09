package cassowaryAS3.constraints
{
	import cassowaryAS3.variables.CVariable;
	import cassowaryAS3.core.CStrength;

	public class CStayConstraint extends CEditOrStayConstraint
	{
		public function CStayConstraint(aVariable:CVariable, aStrength:CStrength=null, aWeight:Number=1.0)
		{
			if (!aStrength) aStrength = CStrength.weak();
			super(aVariable, aStrength, aWeight);
		}
		override public function isStayConstraint():Boolean
		{
			return true;
		}
		override public function toString():String
		{
			return "stay "+super.toString();
		}
	}
}