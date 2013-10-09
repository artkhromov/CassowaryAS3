package cassowaryAS3.core
{
	import cassowaryAS3.errors.InternalError;
	
	import cassowaryAS3.data.iterators.IIterator;
	
	import flash.utils.Dictionary;
	import cassowaryAS3.variables.CAbstractVariable;
	import cassowaryAS3.constraints.CEditConstraint;
	import cassowaryAS3.variables.CSlackVariable;
	import cassowaryAS3.variables.CVariable;
	import cassowaryAS3.data.ArrayList;
	import cassowaryAS3.data.HashMap;
	

	public class CEditInfoSet
	{
		protected var varList:ArrayList;
		protected var editList:ArrayList;
		protected var varToEditInfoMap:HashMap;
		
		public function CEditInfoSet():void
		{
			varList = new ArrayList();
			editList = new ArrayList();
			varToEditInfoMap = new HashMap();
		}
		
		public function newEditInfo(editConstraint:CEditConstraint,eplus:CSlackVariable,eminus:CSlackVariable,
									 prevEditConstant:Number):CEditInfo
		{
			
			var info:CEditInfo = new CEditInfo(editConstraint,eplus,eminus,prevEditConstant,this);
			var clv:CVariable = editConstraint.variable;
			if (varToEditInfoMap.hasKey(clv))
			{
				trace("Variable has existing EditInfo in var_to_edit_info_map.");
				throw new InternalError("Variable has existing EditInfo in var_to_edit_info_map.");
			}
			varToEditInfoMap.add(clv,info);
			varList.add(editConstraint.variable);
			editList.add(info);
			return info;
			
		}
		
		public function getInfoIndex(info:CEditInfo):int
		{
			var i:int = editList.indexOf(info);
			if (i == -1) throw new InternalError("ClEditInfo not found in edit_list");
			return i;
		}
	
		public function getInfoAt(i:int):CEditInfo
		{
			if (i<0 || i >= editList.size) throw new Error("Array index is out of bounds");
			return editList.getAt(i) as CEditInfo;
		}
	
		public function getVariableIndex(clv:CAbstractVariable):int
		{
			var i:int = varList.indexOf(clv);
			if (i == -1) throw new InternalError("Variable not found in var_list");
			return i;
		}
		public function getVariableAt(i:int):CVariable
		{
			if (i<0 || i >= varList.size) throw new Error("Array index is out of bounds");
			return varList.getAt(i) as CVariable;
		}
		
		public function getInfoByVariable(clv:CAbstractVariable):CEditInfo
		{
			var i:int = getVariableIndex(clv);
			return editList.getAt(i) as CEditInfo;
		}
		public function getTailVariables(n:int):ArrayList
		{
			var result:ArrayList = new ArrayList();
			if (n<0 || n>varList.size) throw new Error("Array index is out of bounds");
			var aVar:CVariable;
			
			for (var i:int = varList.size-1;i>=n;i--)
			{
				aVar = getVariableAt(i);
				result.add(aVar);
			}
			return result;
		}
		public function removeVariable(clv:CAbstractVariable):void
		{
			
			var i:int = getVariableIndex(clv);
			varList.removeAt(i);
			editList.removeAt(i);			
			
			var info:CEditInfo = varToEditInfoMap.getValue(clv) as CEditInfo;
			
			varToEditInfoMap.removeByKey(clv);
			
			if (info == null)
			{
				throw new InternalError("Removing ClVariable without assoicated ClEditInfo.");
			}
			
		}
		public function get size():int
		{
			return varList.size;
		}
			
	}
}