package cassowaryAS3.core
{
	import cassowaryAS3.constraints.CConstraint;
	
	
	import cassowaryAS3.variables.CVariable;

	public interface ISolver
	{
		/**
		 * Incrementally add the linear constraint
		 * cn to the tableau.
		 */ 
		function addConstraint(cn:CConstraint):CSimplexSolver;
		
		/**
		 * Remove the constraint cn from the tableau.
		 * Also remove any error variables associated
		 * with cn from the objective function.
		 */ 
		function removeConstraint(cn:CConstraint):CSimplexSolver;
		/**
		 * Add an edit constraint of strength s on  
		 * variable v to the tableau so that
		 * suggestValue() can be used on that variable
		 * after a beginEdit().
		 */ 
		function addEditVar(v:CVariable,s:CStrength = null):CSimplexSolver;
		/**
		 * Remove the previously added edit constraint
		 * on variable v. endEdit() call automatically
		 * removes all the edit variables as part of
		 * terminating an edit manipulation.
		 */ 
		function removeEditVar(v:CVariable):CSimplexSolver;
		/**
		 * Prepare the tableau for new values to be
		 * given to the currently-edited variables.
		 * addEditVar() function should be called
		 * before calling beginEdit(), and suggestValue(),
		 * and resolve() should be used only after beginEdit()
		 * has been called, but before the required matching
		 * endEdit().
		 */ 
		function beginEdit():CSimplexSolver;
		/**
		 * Specify a new desired value n for the variable
		 * v. Before this call, v needs to have been added
		 * as a variable of an edit constraint. (either by
		 * addConstraint() of a hand-built EditConstraint
		 * object or more simply using addEditVar()
		 */ 
		function suggestValue(v:CVariable,n:Number):CSimplexSolver;
		/**
		 * Denote the end of an edit manipulation,thus
		 * removing all edit constraints from the tableau.
		 * Each beginEdit() call must be matched with
		 * a corrensondint endEdit()
		 */ 
		function endEdit():CSimplexSolver;
		/**
		 * Try to re-solve the tableau given newly specified
		 * desired values. Call to resolve() should be
		 * sandwiched between a beginEdit() and endEdit(),
		 * and should occur after new values for edit
		 * variables are set using suggestValue().
		 * 
		 * @param newEditConstant : Vector.<CDouble> = null.
		 * Convenience argument - equals to preceeding calls
		 * to suggestValue().
		 */
		function resolve(newEditConstants:Vector.<CDouble>=null):void;
		/**
		 * Addresses the desire to satisfy the stays on both
		 * the x and y components of a given point rather
		 * than on the x component of one point and the
		 * y component of another. listOfPoints - array of
		 * points, whose x and y components are constrainable
		 * variables.
		 * <p> This method adds a weak stay constraint to
		 * the x and y variables of each point. The weights
		 * for x and y components of a given point are the same.
		 * However, the weights for successive points are each 
		 * smaller than those for the previous point 
		 * (1/2 of the previous weight). 
		 * The effect of this is to encourage the solver 
		 * to satisfy the stays on both the x and y of a 
		 * given point rather than the x stay on one point 
		 * and the y stay on another. </p>
		 */ 
		function addPointStays(listOfPoints:Vector.<CPoint>):CSimplexSolver;
		
		/**
		 * Choose whether the solver should automatically 
		 * optimize and set external variable values after
		 *  each addConstraint or removeConstraint. 
		 * By default, auto-solving is on, but passing 
		 * false to this method will turn it off 
		 * (until later turned back on by passing true 
		 * to this method). 
		 * <p>When auto-solving is off, solve 
		 * or resolve must be invoked to see changes 
		 * to the CVariables contained in the tableau.</p>
		 */ 
		function set autosolve(v:Boolean):void;
		function get autosolve():Boolean;
		
		/**
		 * Optimize the tableau and set the external 
		 * CVariables contained in the tableau to 
		 * their new values. 
		 * This method need only be invoked if 
		 * auto-solving has been turned off. 
		 * It never needs to be called after a resolve 
		 * method invocation.
		 */ 
		function solve():CSimplexSolver;
			
	}
}