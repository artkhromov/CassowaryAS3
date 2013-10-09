package tests.draggableBoxes
{
	import cassowaryAS3.constraints.CLinearEquation;
	import cassowaryAS3.constraints.CLinearExpression;
	import cassowaryAS3.constraints.CLinearInequality;
	
	import cassowaryAS3.core.CPoint;
	import cassowaryAS3.core.CSimplexSolver;
	import cassowaryAS3.core.CStrength;
	import cassowaryAS3.core.CUtils;
	import cassowaryAS3.core.Relation;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	public class DraggableBoxTest extends Sprite
	{
		protected var _boxes:Vector.<Box>;
		protected var _midpoints:Vector.<Box>;
		protected var _width:int;
		protected var _height:int;
		protected var _solver:CSimplexSolver;
		
		protected var _dragging:Box;
		
		
		
		public function DraggableBoxTest():void
		{
			_width = 400;
			_height = 400;
			
			_solver = new CSimplexSolver();
			//_solver.autosolve = false;
			
			_boxes = new Vector.<Box>;
			//_midpoints = new Vector.<Box>;
			
			var i:int;
			var box:Box;
			for (i = 0;i<8;i++)
			{
				box = new Box(i,10+i,10+i,50,50);
				_boxes.push(box);
				addChild(box);
				box.mouseEnabled = true;
				box.addEventListener(MouseEvent.MOUSE_DOWN,mouseDownHandler);
				box.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
				box.addEventListener(MouseEvent.MOUSE_UP,mouseReleaseHandler);
				
				
			}
			paint();
			
			
			
			_boxes[0].setCenter(60,60);
			_boxes[1].setCenter(60,200);
			_boxes[2].setCenter(200,200);
			_boxes[3].setCenter(200,60);
			/*
			_boxes[4].setCenter(300,300);
			_boxes[5].setCenter(300,300);
			_boxes[6].setCenter(300,300);
			_boxes[7].setCenter(300,300);
			
			*/
			/*
			var _stays:Vector.<Point> = new Vector.<Point>;
			_stays.push(_boxes[0].centerPoint);
			_stays.push(_boxes[1].centerPoint);
			_stays.push(_boxes[2].centerPoint);
			_stays.push(_boxes[3].centerPoint);
			*/
			//_solver.addPointStays(_stays);
			
			
			
			var expr:CLinearExpression;
			var eq:CLinearEquation;
			
			_solver.addPointStayFromPoint(_boxes[0].centerPoint,1.0);
			_solver.addPointStayFromPoint(_boxes[1].centerPoint,2.0);
			_solver.addPointStayFromPoint(_boxes[2].centerPoint,4.0);
			_solver.addPointStayFromPoint(_boxes[3].centerPoint,8.0);
			
			
			
			
			
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[0].centerXVar),_boxes[1].centerXVar).divide(2);
			eq = new CLinearEquation(_boxes[4].centerXVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding left x: "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[0].centerYVar),_boxes[1].centerYVar).divide(2);
			eq = new CLinearEquation(_boxes[4].centerYVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding left y: "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[1].centerXVar),_boxes[2].centerXVar).divide(2);
			eq = new CLinearEquation(_boxes[5].centerXVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding bottom x: "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[1].centerYVar),_boxes[2].centerYVar).divide(2);
			eq = new CLinearEquation(_boxes[5].centerYVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding bottom y: "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[2].centerXVar),_boxes[3].centerXVar).divide(2);
			eq = new CLinearEquation(_boxes[6].centerXVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding right x: "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[2].centerYVar),_boxes[3].centerYVar).divide(2);
			eq = new CLinearEquation(_boxes[6].centerYVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding right y: "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[3].centerXVar),_boxes[0].centerXVar).divide(2);
			eq = new CLinearEquation(_boxes[7].centerXVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding top x: "+eq); 
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[3].centerYVar),_boxes[0].centerYVar).divide(2);
			eq = new CLinearEquation(_boxes[7].centerYVar,expr);
			_solver.addConstraint(eq);
			
			//trace("Adding top y: "+eq);
			//_solver.solve();
			
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[0].centerXVar),10);
			
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL,_boxes[2].centerXVar));
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL,_boxes[3].centerXVar));
			
			//trace("Adding : "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[1].centerXVar),10);
			
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL,_boxes[2].centerXVar));
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL,_boxes[3].centerXVar));
			
			//trace("Adding : "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[0].centerYVar),10);
			
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL, _boxes[1].centerYVar));
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL, _boxes[2].centerYVar));
			
			//trace("Adding : "+eq);
			
			expr = CUtils.Plus(new CLinearExpression(_boxes[3].centerYVar),10);
			
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL,_boxes[1].centerYVar));
			_solver.addConstraint(new CLinearInequality(expr,Relation.LESS_OR_EQUAL,_boxes[2].centerYVar));
			
			//trace("Adding : "+eq);
			
			//Add constraints to keep points inside window
			
			_solver.addConstraint(new CLinearInequality(_boxes[0].centerXVar,Relation.GREATER_OR_EQUAL,5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[0].centerYVar,Relation.GREATER_OR_EQUAL,5.0));
			
			//trace("Adding : "+eq);
			
			_solver.addConstraint(new CLinearInequality(_boxes[1].centerXVar,Relation.GREATER_OR_EQUAL,5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[1].centerYVar,Relation.GREATER_OR_EQUAL,5.0));
			
			//trace("Adding : "+eq);
			
			_solver.addConstraint(new CLinearInequality(_boxes[2].centerXVar,Relation.GREATER_OR_EQUAL,5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[2].centerYVar,Relation.GREATER_OR_EQUAL,5.0));
			
			//trace("Adding : "+eq);
			
			_solver.addConstraint(new CLinearInequality(_boxes[3].centerXVar,Relation.GREATER_OR_EQUAL,5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[3].centerYVar,Relation.GREATER_OR_EQUAL,5.0));
			
			//trace("Adding : "+eq);
			
			_solver.addConstraint(new CLinearInequality(_boxes[0].centerXVar,Relation.LESS_OR_EQUAL,_width - 5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[0].centerYVar,Relation.LESS_OR_EQUAL,_height - 5.0));
			
			//trace("Adding : "+eq);
			
			_solver.addConstraint(new CLinearInequality(_boxes[1].centerXVar,Relation.LESS_OR_EQUAL,_width - 5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[1].centerYVar,Relation.LESS_OR_EQUAL,_height - 5.0));
			
			//trace("Adding : "+eq);
			
			_solver.addConstraint(new CLinearInequality(_boxes[2].centerXVar,Relation.LESS_OR_EQUAL,_width - 5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[2].centerYVar,Relation.LESS_OR_EQUAL,_height - 5.0));
			
			//trace("Adding : "+eq);
			
			_solver.addConstraint(new CLinearInequality(_boxes[3].centerXVar,Relation.LESS_OR_EQUAL,_width - 5.0));
			_solver.addConstraint(new CLinearInequality(_boxes[3].centerYVar,Relation.LESS_OR_EQUAL,_height - 5.0));
			
			//trace("Adding : "+eq);
			
			paint();
			stage.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP,mouseReleaseHandler);
			
		}//constructor
		protected function paint():void
		{
			var b:Box;
			for (var i:int = 0;i<_boxes.length;i++)
			{
				b = _boxes[i];
				b.x = b.centerXVar.value-(b.width/2);
				b.y = b.centerYVar.value-(b.height/2);
				//trace("Box: "+i+" at "+b.x+":"+b.y);
			}
			graphics.clear();
			graphics.lineStyle(1);
			
			connect(_boxes[0],_boxes[1]);
			connect(_boxes[1],_boxes[2]);
			connect(_boxes[2],_boxes[3]);
			connect(_boxes[3],_boxes[0]);
			graphics.lineStyle(1,0xff0000);
			connect(_boxes[4],_boxes[5]);
			connect(_boxes[5],_boxes[6]);
			connect(_boxes[6],_boxes[7]);
			connect(_boxes[7],_boxes[4]);
			
			
			function connect(b1:Box,b2:Box):void
			{
				graphics.moveTo(b1.centerPoint.x,b1.centerPoint.y);
				graphics.lineTo(b2.centerPoint.x,b2.centerPoint.y);
			}
		}
		
		protected function mouseDownHandler(e:MouseEvent):void
		{
			paint();
			try
			{
				if (e.target is Box)
				{
					
					_dragging = e.target as Box;
					
					//trace("Dragging vars: "+_dragging.centerXVar+" : "+_dragging.centerYVar);
					_solver.addEditVar(_dragging.centerXVar);
					_solver.addEditVar(_dragging.centerYVar);
					_solver.beginEdit();
				}
			}
			catch(err:Error)
			{
				throw err;
				//trace(err+" "+err.message);	
			}
		}
		protected function mouseMoveHandler(e:MouseEvent):void
		{
			if (_dragging != null)
			{
				_solver.suggestValue(_dragging.centerXVar,e.stageX).suggestValue(_dragging.centerYVar,e.stageY).resolve();
			}
			//paint();	
		}
		protected function enterFrameHandler(e:Event):void
		{
			paint();
		}
		protected function mouseReleaseHandler(e:MouseEvent):void
		{
			paint();
			if (_dragging)
			{
				_solver.endEdit();
				_dragging = null;
			}
		}
		
		
	}//class
}//package