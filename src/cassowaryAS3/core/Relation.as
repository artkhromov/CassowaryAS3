package cassowaryAS3.core
{
	public class Relation
	{
		public static const LESS_OR_EQUAL:String = "lessOrEqual";
		public static const GREATER_OR_EQUAL:String = "greaterOrEqual";
		public function Relation()
		{
		}
		
		public static function checkValue(v:String):Boolean
		{
			return v == LESS_OR_EQUAL || v == GREATER_OR_EQUAL;
		}
	}
}