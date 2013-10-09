package cassowaryAS3.core
{
	import cassowaryAS3.errors.ConstraintNotFoundError;
	import cassowaryAS3.errors.InternalError;
	import cassowaryAS3.errors.RequiredFailureError;
	
	
	import cassowaryAS3.constraints.CConstraint;
	import cassowaryAS3.constraints.CEditConstraint;
	import cassowaryAS3.constraints.CLinearExpression;
	import cassowaryAS3.constraints.CLinearInequality;
	import cassowaryAS3.constraints.CStayConstraint;
	
	import cassowaryAS3.data.ArrayList;
	import cassowaryAS3.data.HashMap;
	import cassowaryAS3.data.HashSet;
	import cassowaryAS3.data.iterators.IIterator;
	
	import flash.utils.Dictionary;
	
	import cassowaryAS3.variables.CAbstractVariable;
	import cassowaryAS3.variables.CDummyVariable;
	import cassowaryAS3.variables.CObjectiveVariable;
	import cassowaryAS3.variables.CSlackVariable;
	import cassowaryAS3.variables.CVariable;

	public class CSimplexSolver extends CTableau implements ISolver
	{
		
		/**
		 * see stayPlusErrorVars
		 */ 
		protected var _stayMinusErrorVars:ArrayList;
		
		/**
		 * An array of plus error variables (instances of ClSlackVariable) 
		 * for the stay constraints. The corresponding negative error 
		 * variable must have the same index in stayMinusErrorVars.
		 */ 
		protected var _stayPlusErrorVars:ArrayList;
	
		/**
		 * HashMap [Constraint - HashSet[SlackVariable]]
		 * 
		 * <p>A dictionary whose keys are constraints and whose 
		 * values are arrays of CSlackVariable. This dictionary
		 * gives the error variable (or variables) for a 
		 * given non-required constraint. 
		 * We need this if the constraint is deleted, 
		 * since the corresponding error variables must 
		 * be deleted from the objective function.</p>
		 */ 
		protected var _errorVars:HashMap;

		/**
		 * HashMap [Constraint - AbstractVariable]
		 * 
		 * <p>A dictionary whose keys are constraints and 
		 * whose values are instances of a subclass of 
		 * CAbstractVariable. This dictionary is used 
		 * to find the marker variable for a constraint 
		 * when deleting that constraint. A secondary 
		 * use is that iterating through the keys will 
		 * give all of the original constraints (useful for reset).</p>
		 */ 
		protected var _markerVars:HashMap;
		
		protected var _resolvePair:Vector.<CDouble>;
		
		/**
		 * Instance of CObjectiveVariable (named z) 
		 * that is the key for the objective row in the tableau.
		 */  
		protected var _objective:CObjectiveVariable;
		
		/**
		 * An array of constants (floats) for the edit constraints
		 *  on the previous iteration. The elements in this array 
		 * must be in the same order as editPlusErrorVars 
		 * and editMinusErrorVars, and the argument to the 
		 * resolve function.
		 */ 
		//protected var _prevEditConstants:Vector.<Number>;
		
		
		protected var edit_info_set:CEditInfoSet;
		
		/**
		 * Used for debugging. An integer used to generate names 
		 * for slack variables, which are useful when printing 
		 * out expressions. 
		 * (Thus we get slack variables named s1, s2, etc.)
		 */
		protected var _slackCounter:int;
		
		/**
		 * Simular to slackCounter, but for artificial variables.
		 */ 
		protected var _artificialCounter:int;
		
		/**
		 * Simular to slackCounter, but for dummy variables.
		 */
		protected var _dummyCounter:int;
		
		protected var _epsilon:Number;
		
		protected var _fOptimizeAutomatically:Boolean;
		
		protected var _fNeedsSolving:Boolean;
		
		protected var _stkCedcns:Vector.<int>;

		
		public function CSimplexSolver()
		{
			super();
			
			_stayMinusErrorVars = new ArrayList();
			_stayPlusErrorVars = new ArrayList();
			
			_errorVars = new HashMap();
			_markerVars = new HashMap();
			
			_resolvePair = new Vector.<CDouble>;
			_resolvePair.push(new CDouble(0.0));
			_resolvePair.push(new CDouble(0.0));
			
			_objective = new CObjectiveVariable("Z");
			
			edit_info_set = new CEditInfoSet();
			
			
			_slackCounter = 0;
			_artificialCounter = 0;
			_dummyCounter = 0;
			_epsilon = 1e-8;
			
			_fOptimizeAutomatically = true;
			_fNeedsSolving = false;
			
			var e:CLinearExpression = new CLinearExpression();
			_rows.add(_objective,e);
			
			_stkCedcns = new Vector.<int>;
			_stkCedcns.push(0);
			
			
		}
		
		
		// Convenience function for creating a linear inequality constraint
		public final function addLowerBound(v:CVariable,lower:Number):CSimplexSolver
		{
			var cn:CLinearInequality = new CLinearInequality(v,Relation.GREATER_OR_EQUAL, new CLinearExpression(lower));
			return addConstraint(cn);
		}
		
		
		// Convenience function for creating a linear inequality constraint
		public final function addUpperBound(v:CVariable,upper:Number):CSimplexSolver
		{
			var cn:CLinearInequality = new CLinearInequality(v,Relation.LESS_OR_EQUAL,new CLinearExpression(upper));
			return addConstraint(cn);
		}

		// Convenience function for creating a pair of linear inequality constraint
		public final function addBounds(v:CVariable,lower:Number,upper:Number):CSimplexSolver
		{
			addLowerBound(v,lower);
			addUpperBound(v,upper);
			return this;
		}
		
		// Add constraint "cn" to the solver
		public final function addConstraint(cn:CConstraint):CSimplexSolver
		{
			var eplus_eminus:ArrayList /*[CSlackVariable]*/ = new ArrayList();
			var prevEConstant:CDouble = new CDouble(0.0);
			var expr:CLinearExpression = newExpression(cn,eplus_eminus,prevEConstant);
			var fAddedOkDirectly:Boolean = false;
			
			try
			{
				fAddedOkDirectly = tryAddingDirectly(expr);
				if (!fAddedOkDirectly)
				{
					addWithArtificialVariable(expr);
				}
			}
			catch (e:RequiredFailureError)
			{
				throw e;
			}
			
			_fNeedsSolving = true;
			
			if (cn.isEditConstraint())
			{
				var cnEdit:CEditConstraint = cn as CEditConstraint;
				var clvEplus:CSlackVariable = eplus_eminus.getAt(0) as CSlackVariable;
				var clvEminus:CSlackVariable = eplus_eminus.getAt(1) as CSlackVariable;
				
				edit_info_set.newEditInfo(cnEdit,clvEplus,clvEminus,prevEConstant.value);
			}
			
			if (_fOptimizeAutomatically)
			{
				optimize(_objective);
				setExternalVariables();
			}
				
			return this;
						
		}
		
		/**
		 * We are trying to add the constraint expr=0 to the appropriate
		 * tableau.  Try to add expr directly to the tableax without
		 * creating an artificial variable.  Return true if successful and
		 * false if not.
		 */ 
		protected final function tryAddingDirectly(expr:CLinearExpression):Boolean
		{
			var subject:CAbstractVariable = chooseSubject(expr);
			if (subject == null)
			{
				return false;
			}
			
			expr.newSubject(subject);
			if (columnsHasKey(subject))
			{
				substituteOut(subject,expr);
			}
			addRow(subject,expr);
			
			return true;
		}
		
		
		/**
		 * Add the constraint expr=0 to the inequality tableau using an
		 * artificial variable.  To do this, create an artificial variable
		 * av and add av=expr to the inequality tableau, then make av be 0.
		 *(Raise an exception if we can't attain av=0.)
		 */
		protected final function addWithArtificialVariable(expr:CLinearExpression):void
		{
			_artificialCounter++;
			var vName:String = _artificialCounter.toString()+"a";
			var av:CSlackVariable = new CSlackVariable(vName);
			var az:CObjectiveVariable = new CObjectiveVariable("az");
			var azRow:CLinearExpression = expr.clone();
			
			addRow(az,azRow);
			addRow(av,expr);
			
			optimize(az);
			
			var azTableauRow:CLinearExpression = rowExpression(az);
			
			
			if (!CUtils.approxNumbers(azTableauRow.constant(),0.0))
			{
				removeRow(az);
				removeColumn(av);
				throw new RequiredFailureError();
			}
			
			// See if av is a basic variable
			var e:CLinearExpression = rowExpression(av);
			
			if (e != null) 
			{
				// find another variable in this row and pivot,
				// so that av becomes parametric
				if (e.isConstant())
				{
					// if there isn't another variable in the row
					// then the tableau contains the equation av=0 --
					// just delete av's row
					removeRow(av);
					removeRow(az);
					return;
				}
				
				var entryVar:CAbstractVariable = e.anyPivotableVariable();
				pivot(entryVar,av);
			}
			if (rowExpression(av) != null) throw new Error("[ASSERT] rowExpression must be null");
			
			removeColumn(av);
			removeRow(az);
		}
		
		
		
		
					
					
		// Same as addConstraint, except returns false if the constraint
		// resulted in an unsolvable system (instead of throwing an exception)
		public final function addConstraintNoException(cn:CConstraint):Boolean
		{
			try 
			{
				addConstraint(cn);
				return true;
			}
			catch (e:RequiredFailureError)
			{
				return false;
			}
			return false;
		}

		// Add an edit constraint for "v" with given strength
		public final function addEditVar(v:CVariable,aStrength:CStrength=null):CSimplexSolver
		{
			if (!aStrength) aStrength = CStrength.strong();
			
			try
			{
				var cnEdit:CEditConstraint = new CEditConstraint(v,aStrength);
				return addConstraint(cnEdit);
			}
			catch (e:RequiredFailureError)
			{
				throw new InternalError("Required failure when adding an edit variable");
			}
			return this;
		}
		
			
			// Remove the edit constraint previously added for variable v
			public final function removeEditVar(v:CVariable):CSimplexSolver
			{
				var cei:CEditInfo = edit_info_set.getInfoByVariable(v);
				var cn:CConstraint = cei.constraint;
				removeConstraint(cn);
				
				return this;
			}
				
				// beginEdit() should be called before sending
				// resolve() messages, after adding the appropriate edit variables
			
			public final function beginEdit():CSimplexSolver
			{
				if (edit_info_set.size < 1) throw new Error ("[ASSERT] EditInfo Set size should be > 0");
				
				_infeasibleRows.clear();
				resetStayConstants();
				_stkCedcns.push(edit_info_set.size);
				return this;
			}
			
				// endEdit should be called after editing has finished
				// for now, it just removes all edit variables
			public final function endEdit():CSimplexSolver
			{
				if (edit_info_set.size < 1) throw new Error ("[ASSERT] EditInfo Set size should be > 0");
				
				resolve();
				
				_stkCedcns.pop();
				
				var n:int = _stkCedcns[_stkCedcns.length-1];
				removeEditVarsTo(n);
				return this;
			}
			
			
				// removeAllEditVars() just eliminates all the edit constraints
				// that were added
			public final function removeAllEditVars():CSimplexSolver
			{
				return removeEditVarsTo(0);
			}

			// remove the last added edit vars to leave only n edit vars left
			public final function removeEditVarsTo(n:int):CSimplexSolver
			{
				var removeList:ArrayList /*[CVariable]*/ = edit_info_set.getTailVariables(n);
				var aVar:CVariable;
				
				var it:IIterator = removeList.getIterator();
				
				while (it.hasNext())
				{
					aVar = it.current() as CVariable;
					try
					{
						removeEditVar(aVar);
					}
					catch (e:ConstraintNotFoundError)
					{
						throw new InternalError("Constraint not found in removeEditVarsTo");
					}
					it.next();
				}
				it.dispose();
				it = null;
				return this;
			
			}
			
				// Add weak stays to the x and y parts of each point. These have
				// increasing weights so that the solver will try to satisfy the x
				// and y stays on the same point, rather than the x stay on one and
				// the y stay on another.
			
			public final function addPointStays(listOfPoints:Vector.<CPoint>):CSimplexSolver
			{
			 	var weight:Number = 1.0;
				var multiplier:Number = 2.0;
				
				for (var i:int = 0;i<listOfPoints.length;i++)
				{
					addPointStayFromPoint(listOfPoints[i],weight);
					weight *= multiplier;
				}
				
				return this;
			}
			
			public final function addPointStay(vx:CVariable,vy:CVariable,weight:Number = 1.0):CSimplexSolver
			{
				addStay(vx,CStrength.weak(),weight);
				addStay(vy,CStrength.weak(),weight);
				return this;
			}
			public final function addPointStayFromPoint(clp:CPoint,weight:Number = 1.0):CSimplexSolver
			{
				addStay(clp.xVar,CStrength.weak(),weight);
				addStay(clp.yVar,CStrength.weak(),weight);
				return this;
			}
			
			
			public final function addStay(v:CVariable,aStrength:CStrength = null,weight:Number = 1.0):CSimplexSolver
			{
				if (!aStrength) aStrength = CStrength.weak();
				var cn:CStayConstraint = new CStayConstraint(v,aStrength,weight);
				return addConstraint(cn);
			}
			
			public final function removeConstraint(cn:CConstraint):CSimplexSolver
			{
				_fNeedsSolving = true;
				resetStayConstants();
				var zRow:CLinearExpression = rowExpression(_objective);
				
				var eVars:HashSet /*[CSlackVariable]*/ = _errorVars.getValue(cn) as HashSet;
				
				var clv:CAbstractVariable;
				var expr:CLinearExpression;

				var it:IIterator;
				
				if (eVars != null)
				{
					it = eVars.getIterator();
					while (it.hasNext())
					{
						clv = it.current() as CAbstractVariable;
						expr = rowExpression(clv);
						if (expr == null)
						{
							zRow.addVariable(clv,-cn.weight*cn.strength.symbolicWeigth.asNumber(),_objective,this);
						}
						else
						{
							zRow.addExpression(expr,-cn.weight*cn.strength.symbolicWeigth.asNumber(),_objective,this);
						}
						it.next();
					}
					it.dispose();
					it = null;
				}//
				
				
				var marker:CAbstractVariable = 	_markerVars.removeByKey(cn) as CAbstractVariable;
			
				if (marker == null)
				{
					throw new ConstraintNotFoundError();
				}
				if (rowExpression(marker) == null) 
				{
					// not in the basis, so need to do some work
					var col:HashSet /*[CAbstractVariable]*/= _columns.getValue(marker) as HashSet;
					var exitVar:CAbstractVariable = null;
					var minRatio:Number = 0.0;
					var coeff:Number;
					var r:Number;
					
					it = col.getIterator();
					
					while (it.hasNext())
					{
						clv = it.current() as CAbstractVariable;
						r = 0.0;
						coeff = 0.0;
						if (clv.isRestricted())
						{
							expr = rowExpression(clv);
							coeff = expr.coefficientFor(marker);
							
							if (coeff < 0.0)
							{
								r = -expr.constant() / coeff;
								if (exitVar == null || r < minRatio)
								{
									minRatio = r;
									exitVar = clv
								}
							}
						}
						it.next();
					}//
					it.dispose();
					it = null;
					
					if (exitVar == null) 
					{
						it = col.getIterator();
						while (it.hasNext())
						{
							coeff = 0.0;
							r = 0.0;
							clv = it.current() as CAbstractVariable;
							if (clv.isRestricted())
							{
								expr = rowExpression(clv);
								coeff = expr.coefficientFor(marker);
								r = expr.constant()/coeff;
								if (exitVar == null || r<minRatio)
								{
									minRatio = r;
									exitVar = clv;
								}
							}
							it.next();
						}
						it.dispose();
						it = null;
					}
					
					
					if (exitVar == null)
					{
						if (col.size == 0)
						{
							removeColumn(marker);
						}
						else
						{
							exitVar = col.getIterator().current() as CAbstractVariable;
						}
					}
					if (exitVar != null) 
					{
						pivot(marker,exitVar);
					}
				}
				
				if (rowExpression(marker) != null)
				{
					expr = removeRow(marker);
					expr = null;
				}
				
				if (eVars != null)
				{
					it = eVars.getIterator();
					while(it.hasNext())
					{
						clv = it.current() as CAbstractVariable;
						if (clv != marker)
						{
							removeColumn(clv);
							clv = null;
						}
						it.next();
					}
				}
				
				if (cn.isStayConstraint())
				{
					if (eVars != null)
					{
						it = _stayPlusErrorVars.getIterator();
						while(it.hasNext())
						{
							eVars.remove(it.current());
							eVars.remove(_stayMinusErrorVars.getAt(int(it.key())));
							it.next();
						}
						it.dispose();
						it = null;
					}
				}
				else if (cn.isEditConstraint())
				{
					if (eVars == null) throw new Error("[ASSERT] eVars must not be null");
					
					var cnEdit:CEditConstraint = cn as CEditConstraint;
					var v:CVariable = cnEdit.variable;
					var cei:CEditInfo = edit_info_set.getInfoByVariable(v);
					var clvEditMinus:CSlackVariable = cei.ClvEditMinus;
					removeColumn(clvEditMinus);
					edit_info_set.removeVariable(v);
				}
				
				if (eVars != null)
				{
					_errorVars.removeByKey(cn);
				}
				marker = null;
				
				if (_fOptimizeAutomatically)
				{
					optimize(_objective);
					setExternalVariables();
				}
				
				return this;
				
			}
					
					
				// Re-initialize this solver from the original constraints, thus
				// getting rid of any accumulated numerical problems.  (Actually, we
				// haven't definitely observed any such problems yet)
			public final function reset():void
			{
				throw new InternalError("Reset not implemented");
			}
			
				// Re-solve the current collection of constraints for new values for
				// the constants of the edit variables.
				// DEPRECATED:  use suggestValue(...) then resolve()
				// If you must use this, be sure to not use it if you
				// remove an edit variable (or edit constraint) from the middle
				// of a list of edits and then try to resolve with this function
				// (you'll get the wrong answer, because the indices will be wrong
				// in the ClEditInfo objects)

			public final function resolve(newEditConstants:Vector.<CDouble>=null):void
			{
				if (newEditConstants == null)
				{
					resolveCurrent();
					return;
				}
				var new_constants_size:int = newEditConstants.length;
				var v:CVariable;
				for (var i:int = 0;i<edit_info_set.size;i++)
				{
					v = null;
					if (i<new_constants_size)
					{
						v = edit_info_set.getVariableAt(i);
						
						try
						{
							suggestValue(v,newEditConstants[i].value);
						}
						catch (e:Error)
						{
							throw new InternalError("Error during resolve");
						}
					}
				}
				resolveCurrent();
			}
			
			// Convenience function for resolve-s of two variables
			public final function resolveTwo(x:Number,y:Number):void
			{
				_resolvePair[0].value = x;
				_resolvePair[1].value = y;
				resolve(_resolvePair);
			}
			
			// Re-solve the cuurent collection of constraints, given the new
			// values for the edit variables that have already been
			// suggested (see suggestValue() method)
			
			public final function resolveCurrent():void
			{
				dualOptimize();
				setExternalVariables();
				_infeasibleRows.clear();
				resetStayConstants();
			}
				
				// Suggest a new value for an edit variable
				// the variable needs to be added as an edit variable
				// and beginEdit() needs to be called before this is called.
				// The tableau will not be solved completely until
				// after resolve() has been called
			public final function suggestValue(v:CVariable,x:Number):CSimplexSolver
			{
				var cei:CEditInfo = edit_info_set.getInfoByVariable(v);
				
				if (cei == null) throw new Error("Suggest value for variable "+v+"+ but var is not an edit variable \n");
				
				var clvEditPlus:CSlackVariable = cei.ClvEditPlus; 
				var clvEditMinus:CSlackVariable = cei.ClvEditMinus;
				
				var delta:Number = x-cei.prevEditConstant;
				cei.prevEditConstant = x;
				
				deltaEditConstant(delta,clvEditPlus,clvEditMinus);
				return this;
				
			}
				
				// Control whether optimization and setting of external variables
				// is done automatically or not.  By default it is done
				// automatically and solve() never needs to be explicitly
				// called by client code; if setAutosolve is put to false,
				// then solve() needs to be invoked explicitly before using
				// variables' values
				// (Turning off autosolve while adding lots and lots of
				// constraints [ala the addDel test in ClTests] saved
				// about 20% in runtime, from 68sec to 54sec for 900 constraints,
				// with 126 failed adds)
			public final function set autosolve(f:Boolean):void
			{
				_fOptimizeAutomatically = f;
			}
			public final function get autosolve():Boolean
			{
				return _fOptimizeAutomatically;
			}
			
			
				// If autosolving has been turned off, client code needs
				// to explicitly call solve() before accessing variables
				// values
			
			public final function solve():CSimplexSolver
			{
				if (_fNeedsSolving)
				{
					optimize(_objective);
					setExternalVariables();
				}
				return this;
			}
			
			public function setEditedValue(v:CVariable,n:Number):CSimplexSolver
			{
				if (!FContainsVariable(v))
				{
					v.change_value(n);
					return this;
				}
				
				if (!CUtils.approxNumbers(n,v.value))
				{
					addEditVar(v);
					beginEdit();
					
					try
					{
						suggestValue(v,n);
					}
					catch (e:Error)
					{
						// just added it above, so we shouldn't get an error
						throw new InternalError( "Error in setEditedValue" );
					}
					endEdit();
				}
				return this;
			}
				
			
			public final function FContainsVariable(v:CVariable):Boolean
			{
				return columnsHasKey(v) || (rowExpression(v) != null);
			}
			

			public function addVar(v:CVariable):CSimplexSolver
			{
				if (!FContainsVariable(v))
				{
					try
					{
						addStay(v);
					}
					catch (e:RequiredFailureError)
					{
						// cannot have a required failure, since we add w/ weak
						throw new InternalError("Error in addVar -- required failure is impossible" );
					}
					
				}
				return this;
				
			}
				// Originally from Michael Noth <noth@cs>
			override public function getInternalInfo():String
			{
				var result:String = "\n Solver info: \n";
				result += "Stay Error Variables: ";
				result += (_stayPlusErrorVars.size + _stayMinusErrorVars.size);
				result += " ("+_stayPlusErrorVars.size + " +, ";
				result += _stayMinusErrorVars.size + " -) \n";
				result += "Edit Variables: " + edit_info_set.size+"\n";
				return result;
			}
				
			public function getConstraintMap():HashMap
			{
				return _markerVars;
			}
			
			
				
				
				// We are trying to add the constraint expr=0 to the tableaux.  Try
				// to choose a subject (a variable to become basic) from among the
				// current variables in expr.  If expr contains any unrestricted
				// variables, then we must choose an unrestricted variable as the
				// subject.  Also, if the subject is new to the solver we won't have
				// to do any substitutions, so we prefer new variables to ones that
				// are currently noted as parametric.  If expr contains only
				// restricted variables, if there is a restricted variable with a
				// negative coefficient that is new to the solver we can make that
				// the subject.  Otherwise we can't find a subject, so return nil.
				// (In this last case we have to add an artificial variable and use
				// that variable as the subject -- this is done outside this method
				// though.)
				//
				// Note: in checking for variables that are new to the solver, we
				// ignore whether a variable occurs in the objective function, since
				// new slack variables are added to the objective function by
				// 'newExpression:', which is called before this method.
			
			protected final function chooseSubject(expr:CLinearExpression):CAbstractVariable
			{
				var subject:CAbstractVariable = null;
				var foundUnrestricted:Boolean = false;
				var foundNewRestricted:Boolean = false;
				
				var it:IIterator = expr.getTermsIterator();
				
				var c:Number;
				var v:CAbstractVariable;
				
				while (it.hasNext())
				{
					c = CDouble(it.current()).value;
					v = CAbstractVariable(it.key());
					
					if (foundUnrestricted)
					{
						if (!v.isRestricted())
						{
							if (!columnsHasKey(v)) return v;
						}
					}
					else
					{
						if (v.isRestricted())
						{
							if (!foundNewRestricted && !v.isDummy() && c<0.0)
							{
								var col:HashSet = _columns.getValue(v) as HashSet;
								if (col == null || (col.size == 1 && columnsHasKey(_objective)))
								{
									subject = v;
									foundNewRestricted = true;
								}
							}
						}
						else
						{
							subject = v;
							foundUnrestricted = true;
						}
					}
					
					it.next();
				}
				
				if (subject != null)
				{
					it.dispose();
					it = null;
					return subject;
				}
				
				var coeff:Number = 0.0;
				
				it.dispose();
				it = null;
				it = expr.getTermsIterator(); //quickfix .reset
				
				while (it.hasNext())
				{
					c = CDouble(it.current()).value;
					v = it.key() as CAbstractVariable;
						
					if (!v.isDummy())
					{
						it.dispose();
						it = null;
						return null;
					}
					if (!columnsHasKey(v))
					{
						subject = v;
						coeff = c;
					}
					
					it.next();
				}
				it.dispose();
				it = null;
				
				if (!CUtils.approxNumbers(expr.constant(),0.0))
				{
					throw new RequiredFailureError();
				}
				if (coeff > 0.0)
				{
					expr.multiplyMe(-1);
				}
				
				return subject;
			}
			
				// Each of the non-required edits will be represented by an equation
				// of the form
				//    v = c + eplus - eminus
				// where v is the variable with the edit, c is the previous edit
				// value, and eplus and eminus are slack variables that hold the
				// error in satisfying the edit constraint.  We are about to change
				// something, and we want to fix the constants in the equations
				// representing the edit constraints.  If one of eplus and eminus is
				// basic, the other must occur only in the expression for that basic
				// error variable.  (They can't both be basic.)  Fix the constant in
				// this expression.  Otherwise they are both nonbasic.  Find all of
				// the expressions in which they occur, and fix the constants in
				// those.  See the UIST paper for details.
				// (This comment was for resetEditConstants(), but that is now
				// gone since it was part of the screwey vector-based interface
				// to resolveing. --02/16/99 gjb)
			protected final function deltaEditConstant(delta:Number,
													   plusErrorVar:CAbstractVariable,
													   minusErrorVar:CAbstractVariable):void
			{
				var exprPlus:CLinearExpression = rowExpression(plusErrorVar);
				if (exprPlus != null)
				{
					exprPlus.incrementConstant(delta);
					if (exprPlus.constant() < 0.0)
					{
						_infeasibleRows.add(plusErrorVar);
					}
					return;
				}
				var exprMinus:CLinearExpression = rowExpression(minusErrorVar);
				
				if (exprMinus != null)
				{
					exprMinus.incrementConstant(-delta);
					
					if (exprMinus.constant() < 0.0)
					{
						_infeasibleRows.add(minusErrorVar);
					}
					return;
				}
				
				var columnVars:HashSet /*[CAbstractVariable]*/ = _columns.getValue(minusErrorVar) as HashSet;
				
				var basicVar:CAbstractVariable;
				var i:int;
				var expr:CLinearExpression;
				var c:Number;
				
				var it:IIterator = columnVars.getIterator();
				
				while (it.hasNext())
				{
					c = 0.0;
					basicVar = it.current() as CAbstractVariable;
					expr = rowExpression(basicVar);
					
					c = expr.coefficientFor(minusErrorVar);
					expr.incrementConstant(c*delta);
					
					if (basicVar.isRestricted() && expr.constant() < 0.0)
					{
						_infeasibleRows.add(basicVar);
					}
					it.next();
				}
				it.dispose();
				it = null;
			}
				
						
					
				// We have set new values for the constants in the edit constraints.
				// Re-optimize using the dual simplex algorithm.
			//!!!CHECK IF NEEDED - INOPTIMAL SOLUTION
			protected final function dualOptimize():void
			{
				var zRow:CLinearExpression = rowExpression(_objective);
				var exitVar:CAbstractVariable;
				var entryVar:CAbstractVariable;
				var expr:CLinearExpression;
				
				var infRows:Array = _infeasibleRows.getValues();
				
				
				for (var i:int = 0;i<infRows.length;i++)
				{
					exitVar = infRows[i] as CAbstractVariable;
					_infeasibleRows.remove(exitVar);
					entryVar = null;
					expr = rowExpression(exitVar);
					
					if (expr != null)
					{
						if (expr.constant() < 0.0)
						{
							var ratio:Number = Number.MAX_VALUE;
							var r:Number;
							
							var it:IIterator = expr.getTermsIterator();							
							var c:Number;
							var v:CAbstractVariable;
							
							while (it.hasNext())
							{
								v = it.key() as CAbstractVariable;
								c = CDouble(it.current()).value;
								
								if (c > 0.0 && v.isPivotable())
								{
									var zc:Number = zRow.coefficientFor(v);
									r = zc/c;
									if (r < ratio)
									{
										entryVar = v;
										ratio = r;
									}
								}
								
								it.next();
							}
							it.dispose();
							it = null;
							
							if (ratio == Number.MAX_VALUE)
							{
								throw new InternalError("ratio == nil (MAX_VALUE) in dualOptimize");
							}
							pivot(entryVar,exitVar);
							
						}
					}
				}
				
			}
				
				
				// Make a new linear expression representing the constraint cn,
				// replacing any basic variables with their defining expressions.
				// Normalize if necessary so that the constant is non-negative.  If
				// the constraint is non-required give its error variables an
				// appropriate weight in the objective function.
			protected final function newExpression(cn:CConstraint,eplus_eminus:ArrayList,prevEConstant:CDouble):CLinearExpression
			{
				var cnExpr:CLinearExpression = cn.expression;
				var expr:CLinearExpression = new CLinearExpression(cnExpr.constant());
				var slackVar:CSlackVariable = new CSlackVariable();
				var dummyVar:CDummyVariable = new CDummyVariable();
				var eminus:CSlackVariable = new CSlackVariable();
				var eplus:CSlackVariable = new CSlackVariable();
				
				
				var v:CAbstractVariable;
				var c:Number;
				var e:CLinearExpression;
				var zRow:CLinearExpression;
				var sw:CSymbolicWeight;
				
				var it:IIterator = cnExpr.getTermsIterator();
				
				while (it.hasNext())
				{
					v = CAbstractVariable(it.key()); 
					c = CDouble(it.current()).value;
					e = rowExpression(v);
					
					if (e == null)
					{
						expr.addVariable(v,c);
					}
					else
					{
						expr.addExpression(e,c); 
					}
					it.next();
				}
				it.dispose();
				it = null;
				
				if (cn.isInequality())
				{
					_slackCounter++;
					slackVar = new CSlackVariable(_slackCounter+"s");
					expr.setVariable(slackVar,-1);
					_markerVars.add(cn,slackVar);
					
					if (!cn.isRequired())
					{
						_slackCounter++;
						eminus = new CSlackVariable(_slackCounter+"em");
						expr.setVariable(eminus,1.0);
						zRow = rowExpression(_objective);
						sw = cn.strength.symbolicWeigth.times(cn.weight);
						zRow.setVariable(eminus,sw.asNumber());
						insertErrorVar(cn,eminus);
						noteAddedVariable(eminus,_objective);
					}
				}
				else
				{
					if (cn.isRequired())
					{
						_dummyCounter++;
						dummyVar = new CDummyVariable(_dummyCounter+"d");
						expr.setVariable(dummyVar,1.0);
						_markerVars.add(cn,dummyVar);
					}
					else
					{
						_slackCounter++;
						eplus = new CSlackVariable(_slackCounter+"ep");
						eminus = new CSlackVariable(_slackCounter+"em");
						expr.setVariable(eplus,-1.0);
						expr.setVariable(eminus,1.0);
						_markerVars.add(cn,eplus);
						zRow = rowExpression(_objective);
						sw = cn.strength.symbolicWeigth.times(cn.weight);
						
						var swCoeff:Number = sw.asNumber();
						
						
						zRow.setVariable(eplus,swCoeff);
						noteAddedVariable(eplus,_objective);
						zRow.setVariable(eminus,swCoeff);
						noteAddedVariable(eminus,_objective);
						insertErrorVar(cn,eminus);
						insertErrorVar(cn,eplus);
						
						if (cn.isStayConstraint())
						{
							_stayPlusErrorVars.add(eplus);
							_stayMinusErrorVars.add(eminus);
						}
						else if (cn.isEditConstraint())
						{
							eplus_eminus.add(eplus);
							eplus_eminus.add(eminus);
							prevEConstant.value = cnExpr.constant();
						}
					}
				}
			
				if (expr.constant() < 0)
				{
					expr.multiplyMe(-1);
				}
				return expr;
			}
				
								
					
				
				// Minimize the value of the objective.  (The tableau should already
				// be feasible.)
			protected final function optimize(zVar:CObjectiveVariable):void
			{
				
				var zRow:CLinearExpression = rowExpression(zVar);
				
				if (zRow == null) throw new Error("[ASSERT] zRow must not be null");

				var entryVar:CAbstractVariable = null;
				var exitVar:CAbstractVariable = null;
				
				var objectiveCoeff:Number;
				var v:CAbstractVariable;
				var c:Number;
				var it:IIterator;
				while (true)
				{
					objectiveCoeff = 0;	
					it = zRow.getTermsIterator();
					
					while (it.hasNext())
					{
						c = CDouble(it.current()).value;
						v = it.key() as CAbstractVariable;
						
						if (v.isPivotable() && c < objectiveCoeff)
						{
							objectiveCoeff = c;
							entryVar = v;
							//BEFORE: return;  escapingEach?
						}
						it.next();
					}
					it.dispose();
					it = null;
					
					if (objectiveCoeff >= -_epsilon || entryVar == null) return;
					
					var minRatio:Number = Number.MAX_VALUE;
					var columnVars:HashSet /*[CAbstractVariable]*/= _columns.getValue(entryVar) as HashSet;
					
					var r:Number = 0.0;
					var expr:CLinearExpression;
					var coeff:Number;
					
					it = columnVars.getIterator();
					
					while (it.hasNext())
					{
						v = it.current() as CAbstractVariable;

						if (v.isPivotable())
						{
							expr = rowExpression(v);
							coeff = expr.coefficientFor(entryVar);
							
							if (coeff < 0.0)
							{
								r = -expr.constant()/coeff;
								
								if (r<minRatio)
								{
									minRatio = r;
									exitVar = v;
								}
							}
						}
						it.next();
					}
					it.dispose();
					it = null;
				
					if (minRatio == Number.MAX_VALUE)
					{
						throw new InternalError("Objective function is unbounded in optimize");
						break;
					}
					pivot(entryVar,exitVar);
				}
			}
					
						
				// Do a pivot.  Move entryVar into the basis (i.e. make it a basic variable),
				// and move exitVar out of the basis (i.e., make it a parametric variable)
			protected function pivot(entryVar:CAbstractVariable,exitVar:CAbstractVariable):void
			{
				// the entryVar might be non-pivotable if we're doing a removeConstraint --
				// otherwise it should be a pivotable variable -- enforced at call sites,
				// hopefully
				
				var pexpr:CLinearExpression = removeRow(exitVar);
				pexpr.changeSubject(exitVar,entryVar);
				substituteOut(entryVar,pexpr);
				addRow(entryVar,pexpr);
			}
			
						
				// Each of the non-required stays will be represented by an equation
				// of the form
				//     v = c + eplus - eminus
				// where v is the variable with the stay, c is the previous value of
				// v, and eplus and eminus are slack variables that hold the error
				// in satisfying the stay constraint.  We are about to change
				// something, and we want to fix the constants in the equations
				// representing the stays.  If both eplus and eminus are nonbasic
				// they have value 0 in the current solution, meaning the previous
				// stay was exactly satisfied.  In this case nothing needs to be
				// changed.  Otherwise one of them is basic, and the other must
				// occur only in the expression for that basic error variable.
				// Reset the constant in this expression to 0.
			protected final function resetStayConstants():void
			{
				var expr:CLinearExpression;
				
				var it:IIterator = _stayPlusErrorVars.getIterator();
				var aVariable:CAbstractVariable;
				
				while (it.hasNext())
				{
					aVariable = (it.current() as CAbstractVariable);
					expr = rowExpression(aVariable);
					
					if (expr == null)
					{
						expr = rowExpression(_stayMinusErrorVars.getAt(int(it.key())) as CAbstractVariable);
					}
					if (expr != null)
					{
						expr.set_constant(0.0);
					}
					it.next();
				}
				it.dispose();
				it = null;
			}
				
				// Set the external variables known to this solver to their appropriate values.
				// Set each external basic variable to its value, and set each
				// external parametric variable to 0.  (It isn't clear that we will
				// ever have external parametric variables -- every external
				// variable should either have a stay on it, or have an equation
				// that defines it in terms of other external variables that do have
				// stays.  For the moment I'll put this in though.)  Variables that
				// are internal to the solver don't actually store values -- their
				// values are just implicit in the tableu -- so we don't need to set
				// them.

			protected final function setExternalVariables():void
			{
				var v:CVariable;
				var it:IIterator = _externalParametricVars.getIterator();
				
				
				while (it.hasNext())
				{
					v = it.current() as CVariable;
					
					if (rowExpression(v) != null)
					{
						it.next();
						continue;
					}
					v.change_value(0.0);
					it.next();
				}
				it.dispose();
				it = null;
				
				it = _externalRows.getIterator();
				var expr:CLinearExpression;
				
				while (it.hasNext())
				{
					v = it.current() as CVariable;
					expr = rowExpression(v);
					v.change_value(expr.constant());
					it.next();
				}
				it.dispose();
				it = null;
				_fNeedsSolving = false;
			}
			
					
				// Protected convenience function to insert an error variable into
				// the _errorVars set, creating the mapping with put as necessary
			protected final function insertErrorVar(cn:CConstraint,aVariable:CSlackVariable):void
			{
				var cnset:HashSet /*[CSlackVariable]*/= _errorVars.getValue(cn) as HashSet;
				if (cnset == null)
				{
					cnset = new HashSet();
					_errorVars.add(cn,cnset);
				}
				cnset.add(aVariable);
			}

			//// BEGIN PRIVATE INSTANCE FIELDS
				/*
				// the arrays of positive and negative error vars for the stay constraints
				1207.
				1208.
				private List<ClSlackVariable> _stayMinusErrorVars;
				1209.
				private List<ClSlackVariable> _stayPlusErrorVars;
				1210.
				
				1211.
				// give error variables for a non required constraint,
				1212.
				// maps to ClSlackVariable-s
				1213.
				private Map<ClConstraint, Set<ClSlackVariable>> _errorVars; // map ClConstraint to Set (of ClVariable)
				1214.
				// Return a lookup table giving the marker variable for each
				1215.
				// constraint (used when deleting a constraint).
				1216.
				private Map<ClConstraint, ClAbstractVariable> _markerVars; // map ClConstraint to ClVariable
				1217.
				private ClObjectiveVariable _objective;
				1218.
				
				1219.
				// Map edit variables to ClEditInfo-s.
				1220.
				// ClEditInfo instances contain all the information for an
				1221.
				// edit constraint (the edit plus/minus vars, the index [for old-style
				1222.
				// resolve(Vector...) interface], and the previous value.
				1223.
				// (ClEditInfo replaces the parallel vectors from the Smalltalk impl.)
				1224.
				//    private LinkedHashMap<ClVariable, ClEditInfo> _editVarMap; // map ClVariable to a ClEditInfo
				1225.
				private ClEditInfoSet edit_info_set;
				1226.
				private long _slackCounter;
				1227.
				private long _artificialCounter;
				1228.
				private long _dummyCounter;
				1229.
				private List<ClDouble> _resolve_pair;
				1230.
				private double _epsilon;
				1231.
				private boolean _fOptimizeAutomatically;
				1232.
				private boolean _fNeedsSolving;
				1233.
				private Deque<Integer> _stkCedcns;
				*/
	}
}