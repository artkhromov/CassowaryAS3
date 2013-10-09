package cassowaryAS3.constraints
{
	import cassowaryAS3.errors.AbstractMethodError;
	
	import cassowaryAS3.core.CStrength;
	import cassowaryAS3.core.CUtils;
	

	public class CConstraint
	{
		protected var _strength:CStrength;
		protected var _weight:Number;
		protected var _attachedObject:Object;
				
		public function CConstraint(aStrength:CStrength = null,aWeight:Number = 1.0):void
		{
			if (!aStrength) _strength = CStrength.required();
			else _strength = aStrength;
			_weight = aWeight;
		}
		
		public function get expression():CLinearExpression
		{
			throw new AbstractMethodError("constraints.CConstraint","expression()");
			return null;
		}
		
		public function isEditConstraint():Boolean
		{
			return false;
		}
		
		public function isInequality():Boolean
		{
			return false
		}

		public function isRequired():Boolean
		{
			return _strength.name == CStrength.REQUIRED; //replace with Strength.isRequired for internal check
		}

		public function isStayConstraint():Boolean
		{
			return false;
		}

		public function get strength():CStrength
		{
			return _strength;
		}
		public function get weight():Number
		{
			return _weight;
		}
		
		public function toString():String
		{
			return _strength.toString() + " {" + weight + "} (" +expression.toString();
		}
	
		public function set attachedObject(o:Object):void
		{
			_attachedObject = o;
		}
		public function get attachedObject():Object
		{
			return _attachedObject;
		}
		
		internal function setWeight(v:Number = 1.0):void
		{
			_weight = v;
		}
		internal function setStrength(v:CStrength = null):void
		{
			if (v) _strength = v;
			else
			{
				if (!_strength) _strength = CStrength.required();
			}
		}

	}
}