package cassowaryAS3.core
{
	public class CStrength
	{
		private var _name:String;
		private var _symbolicWeight:CSymbolicWeight;
		
		public static const STRONG:String = "strong";
		public static const MEDIUM:String = "medium";
		public static const WEAK:String = "weak";
		public static const REQUIRED:String = "required";
			
		public function CStrength(name:String,w1:Number,w2:Number,w3:Number):void
		{
			_name = name;
			_symbolicWeight = new CSymbolicWeight(new <Number>[w1,w2,w3]);
		}
		public static function strong():CStrength
		{
			return new CStrength(CStrength.STRONG,1.0,0.0,0.0);
		}
		public static function medium():CStrength
		{
			return new CStrength(CStrength.MEDIUM,0.0,1.0,0.0);
		}
		public static function weak():CStrength
		{
			return new CStrength(CStrength.WEAK,0.0,0.0,1.0);
		}
		public static function required():CStrength
		{
			return new CStrength(CStrength.REQUIRED,1000.0,1000.0,1000.0);
		}
		
		public function get symbolicWeigth():CSymbolicWeight
		{
			return _symbolicWeight;
		}
		public function get name():String
		{
			return _name;
		}
		public function toString():String
		{
			return "[Strength: name: "+name+" symbolicWeight: "+_symbolicWeight.rawValues+"]";
		}
			
	}
}