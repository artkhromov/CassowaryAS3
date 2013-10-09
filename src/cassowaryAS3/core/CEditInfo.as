package cassowaryAS3.core
{
	import cassowaryAS3.constraints.CConstraint;
	import cassowaryAS3.constraints.CEditConstraint;
	import cassowaryAS3.variables.CSlackVariable;
	
	public class CEditInfo
	{
		protected var _editConstraint:CEditConstraint;
		protected var _eplus:CSlackVariable;
		protected var _eminus:CSlackVariable;
		protected var _prevEditConstant:Number;
		protected var _set:CEditInfoSet;
		
		public function CEditInfo(editConstraint:CEditConstraint,eplus:CSlackVariable,eminus:CSlackVariable,
									prevEditConstant:Number,set:CEditInfoSet)
		{
			_editConstraint = editConstraint;
			_eplus = eplus;
			_eminus = eminus;
			_prevEditConstant = prevEditConstant;
			_set = set;
		}
		public function get index():int
		{
			return _set.getInfoIndex(this);
		}
		public function get constraint():CConstraint
		{
			return _editConstraint;
		}
		public function get ClvEditPlus():CSlackVariable
		{
			return _eplus;
		}
		public function get ClvEditMinus():CSlackVariable
		{
			return _eminus;
		}
		public function get prevEditConstant():Number
		{
			return _prevEditConstant;
		}
		public function set prevEditConstant(v:Number):void
		{
			_prevEditConstant = v;
		}
		
	}
}