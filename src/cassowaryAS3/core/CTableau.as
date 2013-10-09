package cassowaryAS3.core
{
	import cassowaryAS3.constraints.CLinearExpression;
	
	import cassowaryAS3.data.HashMap;
	import cassowaryAS3.data.HashSet;
	import cassowaryAS3.data.iterators.IIterator;
	
	
	import cassowaryAS3.variables.CAbstractVariable;

	public class CTableau
	{
		
		/**
		 * HashMap [AbstractVariable -- LinearExpression].
		 * 
		 * <p> A dictionary with keys CAbstractVariable 
		 * and values CLinearExpression. 
		 * This holds the tableau. 
		 * Note that the keys can be either restricted 
		 * or unrestricted variables, i.e., 
		 * both CU and CS are actually merged into one tableau.
		 * This simplified the code considerably, since 
		 * many operations are applied to both 
		 * restricted and unrestricted rows.</p>
		 */ 
		protected var _rows:HashMap;
		
		/**
		 * HashMap [AbstractVariable -- HashSet[AbstractVariable]]
		 * 
		 * <p>A dictionary with keys CAbstractVariable 
		 * and values Set of CAbstractVariable. 
		 * These are the column cross-indices. 
		 * Each parametric variable p should be a key in 
		 * this dictionary. 
		 * The corresponding set should include exactly those 
		 * basic variables whose linear expression includes 
		 * p (p will of course have a non-zero coefficient). 
		 * The keys can be either unrestricted or restricted variables.</p>
		 */ 
		protected var _columns:HashMap;
		
		
		
		/**
		 * HashSet [AbstractVariable]
		 * 
		 * <p>Set of basic variables that have infeasible rows.
		 *  (This is used when re-optimizing with the dual simplex method.</p>
		 */ 
		protected var _infeasibleRows:HashSet;
		
		/**
		 * HashSet [Variable]
		 */
		protected var _externalRows:HashSet;
		
		/**
		 * HashSet [Variable]
		 */ 
		protected var _externalParametricVars:HashSet;
		
		public function CTableau():void
		{
			_columns = new HashMap(); 
			_rows = new HashMap();
			_infeasibleRows = new HashSet();
			_externalRows = new HashSet();
			_externalParametricVars = new HashSet();
		}
		
		/**
		 * Variable var has been added to the linear 
		 * expression for subject. 
		 * Update the column cross indices.
		 */ 
		public final function noteAddedVariable(v:CAbstractVariable,subject:CAbstractVariable = null):void
		{
			if (subject != null)
			{
				insertColVar(v,subject);
			}
		}
		
			/**
			 *  Variable v has been removed from an expression.  If the
			 * expression is in a tableau the corresponding basic variable is
			 * subject (or if subject is nil then it's in the objective function).
			 * Update the column cross-indices.
			 */ 
		public final function noteRemovedVariable(v:CAbstractVariable,subject:CAbstractVariable=null):void
		{
			var col:HashSet = _columns.getValue(v) as HashSet;
			if (subject != null)//&& col)
			{
				col.remove(subject);
			}
		}
			
		
			
		public function getInternalInfo():String
		{
			var result:String = "Tableau Information: \n";
			result += "Rows: "+_rows.size+"\n";
			result += "(= "+(_rows.size-1)+" constraints) \n";
			result += "Columns: "+_columns.size+"\n";
			result += "Infeasible Rows: "+_infeasibleRows.size+"\n";
			result += "External basic variables: "+_externalRows.size+"\n";
			result += "External parametric variables: "+_externalParametricVars.size+"\n";
			return result;
		}
			
		public function toString():String
		{
			var result:String = "Tableau: \n";
			result += "Rows: \n";
			_rows.forEach(null,iterateRows);//fix!!!
			
			
			function iterateRows(key:Object,value:Object):void
			{
				result += (key as CAbstractVariable).toString();
				result += " <==> ";
				result += (value as CLinearExpression).toString();
				result += "\n";
			}
			
			result += "Columns: \n";
			result += _columns.toString();
			result += "\n";
			result += "InfeasibleRows: " + _infeasibleRows.toString();
			result += "\n";
			result += "External basic variables: ";
			result += "\n";
			result += _externalRows.toString();
			result += "External parametric variables: ";
			result += "\n";
			result += _externalParametricVars.toString();
			return result;
		}
		
			
			/**
			 * Convenience function to insert a variable into
			 * the set of rows stored at _columns[param_var],
			 * creating a new set if needed
			 */ 
		private final function insertColVar(param_var:CAbstractVariable,rowvar:CAbstractVariable):void
		{
			var rowSet:HashSet /*[CAbstractVariable]*/ = _columns.getValue(param_var) as HashSet;
			if (rowSet == null)
			{
				rowSet = new HashSet();
				rowSet.add(rowvar);
				_columns.add(param_var,rowSet);
			}
			else 
			{
				rowSet.add(rowvar);
			}
		}

			/**
			 * Add v=expr to the tableau, update column cross indices
			 * v becomes a basic variable
			 * Expr is now owned by ClTableau class,
			 * and ClTableauis responsible for deleting it.
			 */ 
		protected final function addRow(v:CAbstractVariable,expr:CLinearExpression):void
		{
			// for each variable in expr, add var to the set of rows which
			// have that variable in their expression
			_rows.add(v,expr);
			var it:IIterator = expr.getTermsIterator(); /*Key : CAbstractVariable - value : CDouble */
			var rowVar:CAbstractVariable;
			
			while (it.hasNext())
			{
				rowVar = it.key() as CAbstractVariable;
				insertColVar(rowVar,v); //BEFORE : insertColVar(v,rowVar);
				if (rowVar.isExternal())
				{
					_externalParametricVars.add(rowVar);
				}
				if (v.isExternal())
				{
					_externalRows.add(v);
				}
				it.next();
			}
			it.dispose();
			it = null;
		}
		
		
		/**
		 * Remove parametric variable v from the 
		 * tableau -- remove the column cross indices for v
		 * and remove v from every expression in rows in which v occurs.
		 */ 
		protected final function removeColumn(v:CAbstractVariable):void
		{
			// remove the rows with the variables in varset
			var rows:HashSet /* HashSet [CAbstractVariable]*/ = _columns.getValue(v) as HashSet;
			
			if (rows != null)
			{
				_columns.removeByKey(v); 
				
				var av:CAbstractVariable;
				var exp:CLinearExpression;
				var tm:HashMap;
				
				var it:IIterator = rows.getIterator();
				
				while (it.hasNext())
				{
					av = it.current() as CAbstractVariable;
					exp = _rows.getValue(av) as CLinearExpression;
					
					tm = exp.getTermsMap();
					tm.removeByKey(v);
										
					it.next();
				}
				it.dispose();
				it = null;
			}
			
			if (v.isExternal())
			{
				_externalRows.remove(v);
				_externalParametricVars.remove(v);
			}
			
			
		}
			
			/**
			 * Remove the basic variable var from the tableau. 
			 * Since var is basic, there should be a row var=expr. 
			 * Remove this row, and also update the column cross indices.
			 */ 
		protected final function removeRow(v:CAbstractVariable):CLinearExpression
		{
			var exp:CLinearExpression = _rows.getValue(v) as CLinearExpression;
			
			if (exp == null) throw new Error("[ASSERT] Tableau: RemoveRow: unable to find expression");
			
				var av:CAbstractVariable;
				var termsIterator:IIterator = exp.getTermsIterator();
				
				var varset:HashSet; /*HashSet [CAbstractVariable]*/
				
				while(termsIterator.hasNext())
				{
					av = termsIterator.key() as CAbstractVariable;
					varset = _columns.getValue(av) as HashSet;
					if (varset != null)
					{
						varset.remove(v);
					}
					termsIterator.next();
				}
				termsIterator.dispose();
				termsIterator = null;
				
				if (_infeasibleRows.contains(v)) _infeasibleRows.remove(v);
				if (v.isExternal())
				{
					_externalRows.remove(v);
				}
				_rows.removeByKey(v);
				
			
			return exp;
		}
			
			/**
			 *  Replace all occurrences of oldVar with expr, 
			 * and update column cross indices.
			 * oldVar should now be a basic variable
			 */ 
		protected final function substituteOut(oldVar:CAbstractVariable,expr:CLinearExpression):void
		{
			var varset:HashSet /*HashSet [CAbstractVariable]*/ = _columns.getValue(oldVar) as HashSet;
			
			var it:IIterator = varset.getIterator();
			var v:CAbstractVariable;
			var rowExp:CLinearExpression;
			
			while (it.hasNext())
			{
				v = it.current() as CAbstractVariable;
				rowExp = _rows.getValue(v) as CLinearExpression;
				rowExp.substituteOut(oldVar,expr,v,this);
				if (v.isRestricted() && rowExp.constant() < 0.0)
				{
					_infeasibleRows.add(v);
				}
				it.next();
			}
			it.dispose();
			it = null;
			
			if (oldVar.isExternal())
			{
				_externalRows.add(oldVar);
				_externalParametricVars.remove(oldVar);
			}
			_columns.removeByKey(oldVar);
		}
			
		
		protected final function columnsHasKey(subject:CAbstractVariable):Boolean
		{
			return _columns.hasKey(subject);
		}
		protected final function rowExpression(v:CAbstractVariable):CLinearExpression
		{
			return _rows.getValue(v) as CLinearExpression;
		}
		
	}
}