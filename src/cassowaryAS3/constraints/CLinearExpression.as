package cassowaryAS3.constraints
{
	import cassowaryAS3.errors.InternalError;
	import cassowaryAS3.errors.NonLinearExpressionError;
	
	import cassowaryAS3.core.CDouble;
	import cassowaryAS3.core.CTableau;
	import cassowaryAS3.core.CUtils;
	
	import cassowaryAS3.data.HashMap;
	import cassowaryAS3.data.iterators.IIterator;
	
	import flash.utils.Dictionary;
	
	import cassowaryAS3.variables.CAbstractVariable;
	import cassowaryAS3.variables.CVariable;
	

	public class CLinearExpression
	{
		
		/**
		 * HashMap. [CAbstractVariable - CDouble]
		 */ 
		protected var _terms:HashMap;
		protected var _constant:CDouble;
		
		/**
		 * Syntax.
		 * <li>[blank (initialize with constant = 0)]</li>
		 * <li>[constant:Number]</li>
		 * <li>[variable : Variable - value:Number (optional) - constant:Number (optional)]</li>
		 */ 
		public function CLinearExpression(...args):void
		{
			_terms = new HashMap();
			
			var numArgs:int = args.length;
			var aVariable:CVariable;
			var aValue:Number = 1.0;
			_constant = new CDouble(0.0);
			
			if (numArgs >= 1)
			{
				if (args[0] is CVariable)
				{
					aVariable = args[0];
					if (numArgs >= 2) aValue = args[1];
					if (numArgs >= 3) _constant.value = args[2];
					
					_terms.add(aVariable,new CDouble(aValue));
					//init with variable
				}
				else if (args[0] is Number)
				{
					_constant.value = args[0]; //init with constant
				}
			}
			//if blank - init with constant
			//could cause errors
			aVariable = null;
		}
		
		
		protected function fromMap(aConstant:CDouble,aMap:HashMap):CLinearExpression
		{
			_constant = aConstant.clone();
			_terms = new HashMap();
			var av:CAbstractVariable;
			var val:CDouble;
			var it:IIterator = aMap.getIterator();
			while (it.hasNext())
			{
				av = CAbstractVariable(it.key());
				val = CDouble(it.current()).clone();
				_terms.add(av,val);
				it.next();
			}
			
			return this;
		}
		public function multiplyMe(x:Number):CLinearExpression
		{
			_constant.value *=x;
			var it:IIterator = _terms.getIterator();
			var val:CDouble;
			var value:Number;
			while(it.hasNext())
			{
				val = CDouble(it.current());
				val.value *= x;
				_terms.setValueForKey(it.key(),val);
				it.next();
			}
			it.dispose();
			it = null;
			
			return this;
		}
		
		public function clone():CLinearExpression
		{
			return (new CLinearExpression()).fromMap(_constant,_terms);
		}
		public final function times(x:Number):CLinearExpression
		{
			return clone().multiplyMe(x);
		}
		public final function timesExpr(expr:CLinearExpression):CLinearExpression
		{
			if (isConstant())
			{
				return expr.times(_constant.value);
			}
			else if (!expr.isConstant())
			{
				throw new NonLinearExpressionError();
			}
			return times(expr._constant.value);
		}
		public final function plusExpr(expr:CLinearExpression):CLinearExpression
		{
			return clone().addExpression(expr,1.0);
		}
		public final function plusVar(v:CVariable):CLinearExpression
		{
			return clone().addVariable(v,1.0);
		}
		public final function minusExpr(expr:CLinearExpression):CLinearExpression
		{
			return clone().addExpression(expr,-1.0);
		}
		public final function minusVar(v:CVariable):CLinearExpression
		{
			return clone().addVariable(v,-1.0);
		}
		public final function divide(x:Number):CLinearExpression
		{
			if (CUtils.approxNumbers(x,0.0)) throw new NonLinearExpressionError();
			return times(1.0/x);
		}
		public final function divideExpr(expr:CLinearExpression):CLinearExpression
		{
			if (!expr.isConstant()) throw new NonLinearExpressionError();
			return divide(expr._constant.value);
		}
		
		public final function divFromExpr(expr:CLinearExpression):CLinearExpression
		{
			if (!isConstant() || CUtils.approxNumbers(_constant.value,0.0))
			{
				throw new NonLinearExpressionError();
			}
			return expr.divide(_constant.value);
		}
		public final function subrtactFromExpr(expr:CLinearExpression):CLinearExpression
		{
			return expr.minusExpr(this);
		}

		// Add n*expr to this expression from another expression expr.
		// Notify the solver if a variable is added or deleted from this
		// expression.
		public final function addExpression(expr:CLinearExpression,n:Number=1.0,subject:CAbstractVariable=null,solver:CTableau=null):CLinearExpression
		{
			incrementConstant(n*expr.constant());
			
			var it:IIterator = expr.getTermsIterator();
			var coeff:Number;
			var aVar:CAbstractVariable;
			
			while (it.hasNext())
			{
				coeff = CDouble(it.current()).value;
				aVar = CAbstractVariable(it.key());
				addVariable(aVar,coeff*n,subject,solver);
				it.next();
			}
			it.dispose();
			it = null;
			return this;
			
		}
		
		
		// Add a term c*v to this expression.  If the expression already
		// contains a term involving v, add c to the existing coefficient.
		// If the new coefficient is approximately 0, delete v.
		public final function addVariable(v:CAbstractVariable,c:Number=1.0,subject:CAbstractVariable=null,solver:CTableau=null):CLinearExpression
		{
			
				var coeff:CDouble = CDouble(_terms.getValue(v));
				if (coeff != null)
				{
					var new_coefficient:Number = coeff.value+c;
					if (CUtils.approxNumbers(new_coefficient,0.0))
					{
						if (solver) solver.noteRemovedVariable( v, subject );
						_terms.removeByKey(v);
					}
					else
					{
						coeff.value = new_coefficient;
					}
				}
				else
				{
					if (!CUtils.approxNumbers(c,0.0))
					{
						_terms.add(v,new CDouble(c));
						if (solver) solver.noteAddedVariable( v, subject );
					}
				}
				return this;
		
		}
	
		public final function setVariable(v:CAbstractVariable,c:Number):CLinearExpression
		{
			var coeff:CDouble = CDouble(_terms.getValue(v));
			if (coeff != null)
			{
				coeff.value = c;
			}
			else _terms.add(v,new CDouble(c));
			return this;
		}
		
		
		// Return a pivotable variable in this expression.  (It is an error
		// if this expression is constant -- signal ExCLInternalError in
		// that case).  Return null if no pivotable variables
		public final function anyPivotableVariable():CAbstractVariable
		{
			if (isConstant()) throw new InternalError("anyPivotableVariable called on a constant");
			var it:IIterator = _terms.getIterator();
			var aVariable:CAbstractVariable;
			
			while(it.hasNext())
			{
				aVariable = it.current() as CAbstractVariable;
				if (aVariable.isPivotable()) 
				{
					it.dispose();
					it = null;
					return aVariable;
				}
				else it.next();
			}
			it.dispose();
			it = null;
			
			return null;
		}
		
		// Replace var with a symbolic expression expr that is equal to it.
		// If a variable has been added to this expression that wasn't there
		// before, or if a variable has been dropped from this expression
		// because it now has a coefficient of 0, inform the solver.
		// PRECONDITIONS:
		//   var occurs with a non-zero coefficient in this expression.
		public final function substituteOut(aVariable:CAbstractVariable,expr:CLinearExpression,
											subject:CAbstractVariable,solver:CTableau):void
		{
			var multiplier:Number = CDouble(_terms.getValue(aVariable)).value;
			_terms.removeByKey(aVariable);
			
			incrementConstant(multiplier*expr.constant());
			
			var coeff:Number;
			var d_old_coeff:CDouble;
			
			var it:IIterator = expr.getTermsIterator();
			var aVar:CAbstractVariable;
			
			while (it.hasNext())
			{
				aVar = it.key() as CAbstractVariable;
				
				coeff = CDouble(it.current()).value;
				d_old_coeff = CDouble(_terms.getElement(aVar));
				
				if (d_old_coeff != null)
				{
					var old_coeff:Number = d_old_coeff.value;
					var newCoeff:Number = old_coeff + multiplier*coeff;
					
					if (CUtils.approxNumbers(newCoeff,0.0))
					{
						solver.noteRemovedVariable(aVar,subject);
						_terms.removeByKey(aVar);
					}
					else
					{
						d_old_coeff.value = newCoeff;
					}
				}
				else
				{
					_terms.add(aVar,new CDouble(multiplier*coeff));
					solver.noteAddedVariable(aVar,subject);
				}
			it.next();
			}
			it.dispose();
			it = null;
		}
			
		
		// This linear expression currently represents the equation
		// oldSubject=self.  Destructively modify it so that it represents
		// the equation newSubject=self.
		//
		// Precondition: newSubject currently has a nonzero coefficient in
		// this expression.
		//
		// NOTES
		//   Suppose this expression is c + a*newSubject + a1*v1 + ... + an*vn.
		//
		//   Then the current equation is
		//       oldSubject = c + a*newSubject + a1*v1 + ... + an*vn.
		//   The new equation will be
		//        newSubject = -c/a + oldSubject/a - (a1/a)*v1 - ... - (an/a)*vn.
		//   Note that the term involving newSubject has been dropped.
		public final function changeSubject(old_subject:CAbstractVariable, new_subject:CAbstractVariable):void
		{
			var cld:CDouble = CDouble(_terms.getValue(old_subject));
			if (cld != null)
			{
				cld.value = newSubject(new_subject);
			}
			else
			{
				_terms.add(old_subject,new CDouble(newSubject(new_subject)));
			}
		}
				
		// This linear expression currently represents the equation self=0.  Destructively modify it so
		// that subject=self represents an equivalent equation.
		//
		// Precondition: subject must be one of the variables in this expression.
		// NOTES
		//   Suppose this expression is
		//     c + a*subject + a1*v1 + ... + an*vn
		//   representing
		//     c + a*subject + a1*v1 + ... + an*vn = 0
		// The modified expression will be
		//    subject = -c/a - (a1/a)*v1 - ... - (an/a)*vn
		//   representing
		//    subject = -c/a - (a1/a)*v1 - ... - (an/a)*vn
		//
		// Note that the term involving subject has been dropped.
		// Returns the reciprocal, so changeSubject can use it, too
		public final function newSubject(subject:CAbstractVariable):Number
		{
			var coeff:CDouble = CDouble(_terms.getElement(subject));
			_terms.removeByKey(subject);
			var reciprocal:Number = 1.0/coeff.value;
			multiplyMe(-reciprocal);
			return reciprocal;
		}
		
		// Return the coefficient corresponding to variable var, i.e.,
		// the 'ci' corresponding to the 'vi' that var is:
		//     v1*c1 + v2*c2 + .. + vn*cn + c
		public final function coefficientFor(aVariable:CAbstractVariable):Number
		{
			var coeff:CDouble = CDouble(_terms.getValue(aVariable));
			if (coeff != null)
			{
				return coeff.value;
			}
			else return 0.0;
		}
	
		public final function constant():Number
		{
			return _constant.value;
		}

		public final function set_constant(c:Number):void
		{
			_constant.value = c;
		}

		public final function getTermsIterator():IIterator
		{
			return _terms.getIterator();
		}
		public final function getTermsMap():HashMap
		{
			return _terms;
		}

		public final function incrementConstant(c:Number):void
		{
			_constant.value += c;
		}

		public final function isConstant():Boolean
		{
			return termsSize == 0;
		}
		
		protected function get termsSize():int
		{
			return _terms.size;
		}
	
		public function toString():String
		{
			var result:String = "";
			var plus:String = "";
			if (!CUtils.approxNumbers(_constant.value,0.0) || termsSize == 0)
			{
				result += _constant.value;
			}
			
			
			var coeff:CDouble;
			var it:IIterator = getTermsIterator();
			while(it.hasNext())
			{
				coeff = CDouble(it.current());
				result += plus + coeff.value + "*" + CAbstractVariable(it.key());
				plus = "+";
				it.next();
			}
			it.dispose();
			it = null;
			return result;
		}
		
		public static function Plus(e1:CLinearExpression,e2:CLinearExpression):CLinearExpression
		{
			return e1.plusExpr(e2);
		}
		public static function Minus(e1:CLinearExpression,e2:CLinearExpression):CLinearExpression
		{
			return e1.minusExpr(e2);
		}
		public static function Times(e1:CLinearExpression,e2:CLinearExpression):CLinearExpression
		{
			return e1.timesExpr(e2);
		}
		public static function Divide(e1:CLinearExpression,e2:CLinearExpression):CLinearExpression
		{
			return e1.divideExpr(e2);
		}
		public static function Equals(e1:CLinearExpression,e2:CLinearExpression):Boolean
		{
			return e1 == e2;
		}
	}
}