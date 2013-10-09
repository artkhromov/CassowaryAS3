package tests.unit 
{
	import cassowaryAS3.errors.RequiredFailureError;
	
	import cassowaryAS3.constraints.CConstraint;
	import cassowaryAS3.constraints.CEditConstraint;
	import cassowaryAS3.constraints.CLinearEquation;
	import cassowaryAS3.constraints.CLinearExpression;
	import cassowaryAS3.constraints.CLinearInequality;
	
	import cassowaryAS3.core.CDouble;
	import cassowaryAS3.core.CSimplexSolver;
	import cassowaryAS3.core.CStrength;
	import cassowaryAS3.core.CUtils;
	import cassowaryAS3.core.Relation;
	
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	import cassowaryAS3.variables.CVariable;
	
	public class TestCase extends Sprite
	{
		protected var r:Vector.<Number>;
		protected var rIndex:int;
		
		public function TestCase()
		{
			super();
			/*
			testOne();
			justStay();
			addDelete1();
			addDelete2();
			casso1();
			inconsistent1();
			inconsistent2();
			multiedit();
			inconsistent3();
			*/
			//r = new Vector.<Number>;
			
			for (var i:int = 1;i<11;i++)
			{
				addDel(100,100*i,10);
				resetRand();
			}
			
		}
	 	public function testOne():Boolean
		{
			trace("\nTest \"1\" Start \n");
			var result:Boolean = true;
			var varX:CVariable = new CVariable("varX",167);
			var varY:CVariable = new CVariable("varY",10);
			
			var solver:CSimplexSolver = new CSimplexSolver();
			
			var eq:CLinearEquation = new CLinearEquation(varX,new CLinearExpression(varY));
			solver.addConstraint(eq);
			
			result = (varX.value == varY.value);
			
			trace("\nTest \"1\" End ");
			trace("x == "+varX.value);
			trace("y == "+varY.value);
			trace("Result: "+result);
			return result;
		}
		public function justStay():Boolean
		{
			trace("\nTest \"JustStay\" Start \n");
			var result:Boolean = true;
			var varX:CVariable = new CVariable("varX",5);
			var varY:CVariable = new CVariable("varY",10);
			
			var solver:CSimplexSolver = new CSimplexSolver();
			
			solver.addStay(varX);
			solver.addStay(varY);
			result = result && CUtils.approxNumbers(varX.value,5);
			result = result && CUtils.approxNumbers(varY.value,10);
			
			trace("\nTest \"JustStay\" End ");
			trace("x == "+varX.value);
			trace("y == "+varY.value);
			trace("Result: "+result);
			
			return result;
		}
		public function addDelete1():Boolean
		{

			trace("\nTest \"addDelete1\" Start \n");
			var result:Boolean = true;
			var varX:CVariable = new CVariable("x");
			
			var solver:CSimplexSolver = new CSimplexSolver();
			solver.addConstraint( new CLinearEquation( varX, 100, CStrength.weak() ) );
			var c10:CLinearInequality = new CLinearInequality(varX,Relation.LESS_OR_EQUAL,10.0);
			var c20:CLinearInequality = new CLinearInequality(varX,Relation.LESS_OR_EQUAL,20.0);
			
			solver.addConstraint(c10);
			solver.addConstraint(c20);
			
			result = result && CUtils.approxVariableAndNumber(varX,10.0);
			trace("x == "+varX.value);
			
			solver.removeConstraint(c10);
			
			result = result && CUtils.approxVariableAndNumber(varX,20.0);
			trace("x == "+varX.value);
			
			solver.removeConstraint(c20);
			
			result = result && CUtils.approxVariableAndNumber(varX,100.0);
			trace("x == "+varX.value);
			
			var c10again:CLinearInequality = new CLinearInequality(varX,Relation.LESS_OR_EQUAL,10.0);
			
			solver.addConstraint(c10).addConstraint(c10again);
			
			result = result && CUtils.approxVariableAndNumber(varX,10.0);
			trace("x == "+varX.value);
			
			solver.removeConstraint(c10);
			
			result = result && CUtils.approxVariableAndNumber(varX,10.0);
			trace("x == "+varX.value);
			
			solver.removeConstraint(c10again);
			
			result = result && CUtils.approxVariableAndNumber(varX,100.0);
			trace("x == "+varX.value);
			
			trace("\nTest \"addDelete1\" End ");
			trace("x == "+varX.value);
			trace("Result: "+result);
			
			return result;
			
		}
		
		public function addDelete2():Boolean
		{
			trace("\nTest \"addDelete2\" Start \n");
			var result:Boolean = true;
			var varX:CVariable = new CVariable("varX");
			var varY:CVariable = new CVariable("varY");
			
			var solver:CSimplexSolver = new CSimplexSolver();
			solver.addConstraint(new CLinearEquation(varX,100.0,CStrength.weak()));
			solver.addConstraint(new CLinearEquation(varY,120.0,CStrength.strong()));
			
			var c10:CLinearInequality = new CLinearInequality(varX,Relation.LESS_OR_EQUAL,10.0);
			var c20:CLinearInequality = new CLinearInequality(varX,Relation.LESS_OR_EQUAL,20.0);
			
			solver.addConstraint(c10).addConstraint(c20);
			
			result = result && CUtils.approxVariableAndNumber(varX,10.0) && CUtils.approxVariableAndNumber(varY,120.0);
			
			trace("x == "+varX.value+", y == "+varY.value);
			
			solver.removeConstraint(c10);
			
			trace("x == "+varX.value+", y == "+varY.value);
			
			var cxy:CLinearEquation = new CLinearEquation(CUtils.Times(2.0,varX),varY);
			solver.addConstraint(cxy);
			result = result && CUtils.approxVariableAndNumber(varX,20.0) && CUtils.approxVariableAndNumber(varY,40.0);
			trace("x == "+varX.value+", y == "+varY.value);
			
			solver.removeConstraint(c20);
			result = result && CUtils.approxVariableAndNumber(varX,60.0) && CUtils.approxVariableAndNumber(varY,120.0);
			trace("x == "+varX.value+", y == "+varY.value);
			
			solver.removeConstraint(cxy);
			result = result && CUtils.approxVariableAndNumber(varX,100.0) && CUtils.approxVariableAndNumber(varY,120.0);
			trace("x == "+varX.value+", y == "+varY.value);
			
			
			
			trace("\nTest \"addDelete2\" End ");
			trace("Result: "+result);
			return result;
			
		}
		
		public function casso1():Boolean
		{
			trace("\nTest \"casso1\" Start \n");
			var result:Boolean = true;
			var varX:CVariable = new CVariable("varX");
			var varY:CVariable = new CVariable("varY");
			
			var solver:CSimplexSolver = new CSimplexSolver();
			
			solver.addConstraint(new CLinearInequality(varX,Relation.LESS_OR_EQUAL,varY));
			solver.addConstraint(new CLinearEquation(varY,CUtils.Plus(varX,3.0)));
			solver.addConstraint(new CLinearEquation(varX,10.0,CStrength.weak()));
			solver.addConstraint(new CLinearEquation(varY,10.0,CStrength.weak()));
			
			result = result && 
				((CUtils.approxVariableAndNumber(varX,10.0) && CUtils.approxVariableAndNumber(varY,13.0))
					||(CUtils.approxVariableAndNumber(varX,7.0) && CUtils.approxVariableAndNumber(varY,10.0)));
			
			
			trace("\nTest \"casso1\" End ");
			trace("x == "+varX.value+", y == "+varY.value);
			trace("Result: "+result);
			return result;
			
		}
		
		public function inconsistent1():Boolean
		{
			trace("\nTest \"inconsistent1\" Start \n");
			try
			{
				var varX:CVariable = new CVariable("varX");
				var solver:CSimplexSolver = new CSimplexSolver();
				
				solver.addConstraint(new CLinearEquation(varX,10.0));
				solver.addConstraint(new CLinearEquation(varX,5.0));
				
			}
			catch(e:RequiredFailureError)
			{
				trace("\nTest \"inconststent1\" End ");
				trace("Result: true - got the exception");
				return true;
			}
			trace("\nTest \"inconststent1\" End ");
			trace("Result: false - no exception");
			return false;
		}
		
		public function inconsistent2():Boolean
		{
			trace("\nTest \"inconsistent2\" Start \n");
			try
			{
				var varX:CVariable = new CVariable("varX");
				var solver:CSimplexSolver = new CSimplexSolver();
				
				solver.addConstraint(new CLinearInequality(varX,Relation.GREATER_OR_EQUAL,10.0));
				solver.addConstraint(new CLinearInequality(varX,Relation.LESS_OR_EQUAL,5.0));
			}
			catch(e:RequiredFailureError)
			{
				trace("\nTest \"inconststent2\" End ");
				trace("Result: true - got the exception");
				return true;
			}
			trace("\nTest \"inconststent2\" End ");
			trace("Result: false - no exception");
			return false;
		}
		
		public function multiedit():Boolean
		{
			trace("\nTest \"multiedit\" Start \n");
			var result:Boolean = true;
			try
			{
				var varX:CVariable = new CVariable("x");
				var varY:CVariable = new CVariable("y");
				var varW:CVariable = new CVariable("w");
				var varH:CVariable = new CVariable("h");
				var solver:CSimplexSolver = new CSimplexSolver();
				
				solver.addStay(varX).addStay(varY).addStay(varW).addStay(varH);
				
				solver.addEditVar(varX).addEditVar(varY).beginEdit();
				
				solver.suggestValue(varX,10).suggestValue(varY,20).resolve();
				
				trace("x = "+varX.value + "; y = "+varY.value);
				trace("w = "+varW.value + "; h = "+varH.value);
				
				result = result && CUtils.approxVariableAndNumber(varX,10) 
					&& CUtils.approxVariableAndNumber(varY,20) 
					&& CUtils.approxVariableAndNumber(varW,0)
					&& CUtils.approxVariableAndNumber(varH,0);
				
				
				solver.addEditVar(varW).addEditVar(varH).beginEdit();
				
				solver.suggestValue(varW,30).suggestValue(varH,40).endEdit();
				
				trace("x = "+varX.value + "; y = "+varY.value);
				trace("w = "+varW.value + "; h = "+varH.value);
				
				result = result && CUtils.approxVariableAndNumber(varX,10) 
					&& CUtils.approxVariableAndNumber(varY,20) 
					&& CUtils.approxVariableAndNumber(varW,30)
					&& CUtils.approxVariableAndNumber(varH,40);
				
				
				solver.suggestValue(varX,50).suggestValue(varY,60).endEdit();
				
				trace("x = "+varX.value + "; y = "+varY.value);
				trace("w = "+varW.value + "; h = "+varH.value);
				
				result = result && CUtils.approxVariableAndNumber(varX,50) 
					&& CUtils.approxVariableAndNumber(varY,60) 
					&& CUtils.approxVariableAndNumber(varW,30)
					&& CUtils.approxVariableAndNumber(varH,40);
				
				
				
			}
			catch(e:RequiredFailureError)
			{
				trace("\nTest \"multiedit\" End ");
				trace("Result: "+result +" - success - got an exception");
				return true;
			}
			trace("\nTest \"multiedit\" End ");
			trace("Result: "+result);
			return result;
		}
		
		public function inconsistent3():Boolean
		{
			trace("\nTest \"inconsistent3\" Start \n");
			try
			{
				var varW:CVariable = new CVariable("w");
				var varX:CVariable = new CVariable("x");
				var varY:CVariable = new CVariable("y");
				var varZ:CVariable = new CVariable("z");
				var solver:CSimplexSolver = new CSimplexSolver();
				
				solver.addConstraint(new CLinearInequality(varW,Relation.GREATER_OR_EQUAL,10.0))
					.addConstraint(new CLinearInequality(varX,Relation.GREATER_OR_EQUAL,varW))
					.addConstraint(new CLinearInequality(varY,Relation.GREATER_OR_EQUAL,varX))
					.addConstraint(new CLinearInequality(varZ,Relation.GREATER_OR_EQUAL,varY))
					.addConstraint(new CLinearInequality(varZ,Relation.GREATER_OR_EQUAL,8.0))
					.addConstraint(new CLinearInequality(varZ,Relation.LESS_OR_EQUAL,4.0))
			}
			catch(e:RequiredFailureError)
			{
				trace("\nTest \"inconststent3\" End ");
				trace("Result: true - got the exception");
				return true;
			}
			trace("\nTest \"inconststent3\" End ");
			trace("Result: false - no exception");
			return false;
		
		}
		
		public function addDel(nConstraints:int,nVars:int,nResolves:int,verbose:Boolean = true):Boolean
		{
			
			
			var startTime:int;
			var time:int;
			
			var timeTaken:int;
			
			var ineqProb:Number = 0.12;
			var maxVars:int = 3;
			
			if (verbose)
			{
			trace("\nTest \"Timing test\" Start \n");
			trace("-- nConstraints: "+nConstraints+" - nVars: "+nVars+" - nResolves: "+nResolves+"\n");
			}
		
			
			
			startTime = time = getTimer();
			
			var solver:CSimplexSolver = new CSimplexSolver();
			solver.autosolve = false;
			
			var rgpclv:Vector.<CVariable> = new Vector.<CVariable>;
			for (var i:int = 0;i<nVars;i++)
			{
				rgpclv.push(new CVariable(i+"x"));
				solver.addStay(rgpclv[i]);
			}
			
			var nConstraintsMade:int = nConstraints*2;
			
			var rgpcns:Vector.<CConstraint> = new Vector.<CConstraint>;
			var rgpcnsAdded:Vector.<CConstraint> = new Vector.<CConstraint>;
			
			var nvs:int;
			var k:int;
			var j:int;
			
			var coeff:Number;
			var expr:CLinearExpression;
			var iclv:int;
			
			for (j = 0;j<nConstraintsMade;j++)
			{
				nvs = getRand(1,maxVars);
				expr = new CLinearExpression(getRand()*20.0 - 10.0);
				
				for (k=0;k<nvs;k++)
				{
					coeff = getRand()*10 - 5;
					iclv = getRand()*nVars;
					expr.addExpression(CUtils.Times(rgpclv[iclv],coeff));
				}
				
				if (getRand() < ineqProb)
				{
					rgpcns[j] = new CLinearInequality(expr);
				}
				else
				{
					rgpcns[j] = new CLinearEquation(expr);
				}
				
			}
			time = getTimer();
			timeTaken = time-startTime;
			if (verbose)
			{
				trace("- done building data structures : "+timeTaken+" ms"+"\n");
			}
			var cExceptions:int;
			var cCns:int;
			
			for (j = 0;j<nConstraintsMade;j++)
			{
				if (cCns >= nConstraints) break;
				
				try
				{
					solver.addConstraint(rgpcns[j]);
					rgpcnsAdded[cCns++] = rgpcns[j];
				}
				catch (e:RequiredFailureError)
				{
					cExceptions++;
					
					//trace("got exception when adding "+rgpcns[j]);
					rgpcns[j] = null
				}
			}
			solver.solve();
			time = getTimer();
			
			timeTaken = time-startTime;
			
			if (verbose)
			{
				trace("\n- done adding "+cCns+" constraints ["+j+" attempted, "+cExceptions+" exceptions]");
				trace("--time = "+timeTaken+" ms");
				timeTaken /= cCns;
				trace("--time per Add cn = "+timeTaken+"\n");
			}
			
			var e1Index:int = getRand()*nVars;
			var e2Index:int = getRand()*nVars;
			
			while (e1Index == e2Index)
			{
				if (verbose) trace("Edit constants have simular indices - "+e1Index+" - getting new rand");
				e2Index = getRand()*nVars;
			}
			
			if (verbose)
			{
				trace("Editing vars with indices "+e1Index+", "+e2Index);
			}
			
			var edit1:CEditConstraint = new CEditConstraint(rgpclv[e1Index],CStrength.strong());
			var edit2:CEditConstraint = new CEditConstraint(rgpclv[e2Index],CStrength.strong());
			
			if (verbose)
			{
			trace(" about to start resolves "+"\n");
			}
			
			time = getTimer();
			
			solver.addConstraint(edit1).addConstraint(edit2);
			
			var newEditConstants:Vector.<CDouble> = new Vector.<CDouble>;
			var ec:CDouble = new CDouble();
			var ec2:CDouble = new CDouble();
			newEditConstants.push(ec);
			newEditConstants.push(ec2);
			
			for (var m:int = 0;m<nResolves;m++)
			{
				newEditConstants[0].value = rgpclv[e1Index].value * 1.001;
				newEditConstants[1].value = rgpclv[e2Index].value * 1.001;
				solver.resolve(newEditConstants);
			}
			
			solver.removeConstraint(edit1).removeConstraint(edit2);
			
			timeTaken = time-startTime;
			
			if (verbose)
			{
				trace("--done resolves  -- now removing constraints");
				trace("time = "+timeTaken+" ms ");
				timeTaken /= nResolves;
				trace("time per resolve = "+timeTaken+" ms"+"\n");
			}
			
			time = getTimer();
			
			for (j=0;j<cCns;j++)
			{
				solver.removeConstraint(rgpcnsAdded[j]);
			}
			
			if (verbose)
			{
			timeTaken = time-startTime;
			trace("--done removing constraints");
			trace("-- time = "+timeTaken+"ms");
			timeTaken /= cCns;
			trace("-- time per remove constraint = "+timeTaken+"ms"+"\n");
			}
			
			time = getTimer();
			timeTaken = time-startTime;
			
			if (verbose)
			{
			trace("\nTest \"Timing test end\" End ");
			trace("TotalTime: "+timeTaken+" ms");
			}
			
			return true;
		}
		protected function getRand(start:int = -1,end:int = -1):Number
		{
			var result:Number;
			
			if (!r) 
			{
				r = new Vector.<Number>;
			}
			
			if (rIndex >= r.length)
			{
				r.push(Math.random());
			}
			
			if (start < 0 && end < 0) result = r[rIndex];
			else result = int(r[rIndex]*(end-start+1)+start);
			
			
			rIndex++;
			return result;
			
		}
		protected function resetRand():void
		{
			rIndex = 0;
		}
		protected function initRandoms(n:int,vec:Vector.<Number> = null):Vector.<Number>
		{
			if (!vec) vec = new Vector.<Number>;
			var value:Number;
			for (var i:int = 0;i<n;i++)
			{
				value = Math.random();
				vec.push(value);
			}
			return vec;
		}
		
		protected function uniformRandomsDiscretized():Number
		{
			return Math.random();
		}
		
		
	/*
  
   
    
    System.out.println("done removing constraints and addDel timing test");
    System.out.println("time = " + timer.ElapsedTime() + "\n");
    System.out.println("time per Remove cn = " + timer.ElapsedTime()/cCns);
    
    return true;
  }

  public final static void InitializeRandomsFromFile() {
    try {
      iRandom = 0;
      String s;
      FileReader in = new FileReader("randoms.txt");
      BufferedReader reader = new BufferedReader(in);
      vRandom = new Vector(20001);
      // skip over comment
      reader.readLine();
      // skip over number of randoms
      reader.readLine();
      Double f;
      while ((s = reader.readLine()) != null) {
        f = Double.valueOf(s);
        vRandom.add(f);
        ++cRandom;
      }
      System.err.println("Read in " + cRandom + " random numbers");
    } catch (java.io.IOException e) {
      // nothing
    }
  }
    
  public final static void InitializeRandoms() {
    // do nothing
  }


  public final static double UniformRandomDiscretized()
  {
    double n = Math.abs(RND.nextInt());
    return (n/Integer.MAX_VALUE);
  }

  public final static double UniformRandomDiscretizedFromFile()
  {
    if (iRandom >= cRandom) {
      // throw new Exception("Out of random numbers");
      return -1;
    }
    double f =  ((Double)vRandom.elementAt(iRandom++)).doubleValue();
    //    System.out.println("returning value = " + f);
    return f;
  }

  public final static double GrainedUniformRandom()
  {
    final double grain = 1.0e-4;
    double n = UniformRandomDiscretized();
    double answer =  ((int)(n/grain))*grain;
    return answer;
  }

  public final static int RandomInRange(int low, int high)
  {
    return (int) (UniformRandomDiscretized()*(high-low+1))+low;
  }
    

  public final static boolean addDelSolvers(int nCns, int nResolves, int nSolvers, int testNum)
       throws ExCLInternalError, ExCLRequiredFailure, 
	 ExCLNonlinearExpression, ExCLConstraintNotFound
  {
    Timer timer = new Timer();

    double tmAdd, tmEdit, tmResolve, tmEndEdit;
    // FIXGJB: from where did .12 come?
    final double ineqProb = 0.12;
    final int maxVars = 3;
    final int nVars = nCns;
    InitializeRandoms();

    System.err.println("starting timing test. nCns = " + nCns +
                       ", nSolvers = " + nSolvers + ", nResolves = " + nResolves);
    
    timer.Start();

    ClSimplexSolver[] rgsolvers = new ClSimplexSolver[nSolvers+1];

    for (int is = 0; is < nSolvers+1; ++is) {
      rgsolvers[is] = new ClSimplexSolver();
      rgsolvers[is].setAutosolve(false);
    }

    ClVariable[] rgpclv = new ClVariable[nVars];
    for (int i = 0; i < nVars; i++) {
      rgpclv[i] = new ClVariable(i,"x");
      for (int is = 0; is < nSolvers+1; ++is) {
        rgsolvers[is].addStay(rgpclv[i]);
      }
    }

    int nCnsMade = nCns*5;

    ClConstraint[] rgpcns = new ClConstraint[nCnsMade];
    ClConstraint[] rgpcnsAdded = new ClConstraint[nCns];
    int nvs = 0;
    int k;
    int j;
    double coeff;
    for (j = 0; j < nCnsMade; ++j) {
      // number of variables in this constraint
      nvs = RandomInRange(1,maxVars);
      if (fTraceOn) traceprint("Using nvs = " + nvs);
      ClLinearExpression expr = new ClLinearExpression(GrainedUniformRandom() * 20.0 - 10.0);
      for (k = 0; k < nvs; k++) {
        coeff = GrainedUniformRandom()*10 - 5;
        int iclv = (int) (UniformRandomDiscretized()*nVars);
        expr.addExpression(CL.Times(rgpclv[iclv], coeff));
      }
      if (UniformRandomDiscretized() < ineqProb) {
        rgpcns[j] = new ClLinearInequality(expr);
      } else {  
        rgpcns[j] = new ClLinearEquation(expr);
      }
      if (fTraceOn) traceprint("Constraint " + j + " is " + rgpcns[j]);
    }

    timer.Stop();
    System.err.println("done building data structures");


    for (int is = 0; is < nSolvers; ++is) {
      int cCns = 0;
      int cExceptions = 0;
      ClSimplexSolver solver = rgsolvers[nSolvers];
      cExceptions = 0;
      for (j = 0; j < nCnsMade && cCns < nCns; j++) {
        try
          {
            if (null != rgpcns[j]) {
              solver.addConstraint(rgpcns[j]);
              //              System.out.println("Added " + j + " = " + rgpcns[j]);
              ++cCns;
            }
          }
        catch (ExCLRequiredFailure err)
          {
            cExceptions++;
            rgpcns[j] = null;
          }
      }
    }


    timer.Reset();
    timer.Start();
    for (int is = 0; is < nSolvers; ++is) {
      int cCns = 0;
      int cExceptions = 0;
      ClSimplexSolver solver = rgsolvers[is];
      cExceptions = 0;
      for (j = 0; j < nCnsMade && cCns < nCns; j++) {
        // add the constraint -- if it's incompatible, just ignore it
        try
          {
            if (null != rgpcns[j]) {
              solver.addConstraint(rgpcns[j]);
              //              System.out.println("Added " + j + " = " + rgpcns[j]);
              ++cCns;
            }
          }
        catch (ExCLRequiredFailure err)
          {
            cExceptions++;
            rgpcns[j] = null;
          }
      }
      System.err.println("done adding " + cCns + " constraints [" 
                         + j + " attempted, " 
                         + cExceptions + " exceptions]");
      solver.solve();
    }
    timer.Stop();


    tmAdd = timer.ElapsedTime();
    
    int e1Index = (int) (UniformRandomDiscretized()*nVars);
    int e2Index = (int) (UniformRandomDiscretized()*nVars);
    
    System.err.println("Editing vars with indices " + e1Index + ", " + e2Index);
    
    ClEditConstraint edit1 = new ClEditConstraint(rgpclv[e1Index],ClStrength.strong);
    ClEditConstraint edit2 = new ClEditConstraint(rgpclv[e2Index],ClStrength.strong);
    
    //   CL.fDebugOn = CL.fTraceOn = true;
    System.err.println("about to start resolves");
    
    timer.Reset();
    timer.Start();

    for (int is = 0; is < nSolvers; ++is) {
      rgsolvers[is]
        .addConstraint(edit1)
        .addConstraint(edit2);
    }      
    timer.Stop();
    tmEdit = timer.ElapsedTime();


    timer.Reset();
    timer.Start();
    for (int is = 0; is < nSolvers; ++is) {
      ClSimplexSolver solver = rgsolvers[is];

      for (int m = 0; m < nResolves; m++)
        {
          solver.resolve(rgpclv[e1Index].value() * 1.001,
                         rgpclv[e2Index].value() * 1.001);
        }
    }
    timer.Stop();
    tmResolve = timer.ElapsedTime();


    System.err.println("done resolves -- now ending edits");

    timer.Reset();
    timer.Start();
    for (int is = 0; is < nSolvers; ++is) {
      rgsolvers[is]
        .removeConstraint(edit1)
        .removeConstraint(edit2);
    }
    timer.Stop();

    tmEndEdit = timer.ElapsedTime();

    final int mspersec = 1000;
    System.out.println(nCns + "," + nSolvers + "," + nResolves + "," + testNum + "," +
                       tmAdd*mspersec + "," + tmEdit*mspersec + "," + tmResolve*mspersec + "," + tmEndEdit*mspersec + "," +
                       tmAdd/nCns/nSolvers*mspersec + "," +
                       tmEdit/nSolvers/2*mspersec + "," + 
                       tmResolve/nResolves/nSolvers*mspersec + "," +
                       tmEndEdit/nSolvers/2*mspersec);
    return true;
  }



  public final static void main( String[] args )
       throws ExCLInternalError, ExCLNonlinearExpression,
	 ExCLRequiredFailure, ExCLConstraintNotFound, ExCLError
  {
    try 
    {
      ClTests clt = new ClTests();

      boolean fAllOkResult = true;
      boolean fResult;

      if (true) {
        System.out.println("\n\n\nsimple1:");
        fResult = simple1(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
        
        System.out.println("\n\n\njustStay1:");
        fResult = justStay1(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
	
        System.out.println("\n\n\naddDelete1:");
        fResult = addDelete1(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
        
        System.out.println("\n\n\naddDelete2:");
        fResult = addDelete2(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
        
        System.out.println("\n\n\ncasso1:");
        fResult = casso1(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
    
        System.out.println("\n\n\ninconsistent1:");
        fResult = inconsistent1(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
        
        System.out.println("\n\n\ninconsistent2:");
        fResult = inconsistent2(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
        
        System.out.println("\n\n\ninconsistent3:");
        fResult = inconsistent3(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );

        System.out.println("\n\n\nmultiedit:");
        fResult = multiedit(); fAllOkResult &= fResult;
        if (!fResult) System.out.println("Failed!");
        if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );

      }
      
      System.out.println("\n\n\naddDel:");
      int testNum = 1, cns = 900, resolves = 100, solvers = 10;
        

        if (args.length > 0)
          testNum = Integer.parseInt(args[0]);

        if (args.length > 1)
          cns = Integer.parseInt(args[1]);
        
        if (args.length > 2)
          solvers = Integer.parseInt(args[2]);
        
        if (args.length > 3)
          resolves = Integer.parseInt(args[3]);

        if (false) {
          fResult = addDel(cns,cns,resolves);
          // fResult = addDel(300,300,1000);
          // fResult = addDel(30,30,100);
          // fResult = addDel(10,10,30);
          // fResult = addDel(5,5,10);
          fAllOkResult &= fResult;
          if (!fResult) System.out.println("Failed!");
          if (CL.fGC) System.out.println("Num vars = " + ClAbstractVariable.numCreated() );
        }
        
        addDelSolvers(cns,resolves,solvers,testNum);
    } 
    catch (Exception err)
      {
        ExCLError myerr = (ExCLError) err;
        if (null != myerr) {
          System.err.println("Exception: " + myerr + ": " + myerr.description());
        } else {
          System.err.println("Exception: " + err);
        }
      }
  }
*/
	
	}
}