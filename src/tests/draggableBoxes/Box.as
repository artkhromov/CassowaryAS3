package tests.draggableBoxes
{
		import cassowaryAS3.core.CPoint;
		
		import flash.display.Sprite;
		
		import cassowaryAS3.variables.CVariable;
		
		public class Box extends Sprite
		{
			private var _width:int;
			private var _height:int;
			private var _center:CPoint;
			
			public function Box(i:int,x:int,y:int,width:int,height:int):void
			{
				super();
				
				_width = width;
				_height = height;
				
				_center = new CPoint(x,y,i);
				draw();
			}
			protected function draw():void
			{
				graphics.beginFill(0x333333,1);
				graphics.lineStyle(1,0xFF0000);
				graphics.drawRect(0,0,_width,_height);
				graphics.endFill();
			}
			protected function cvt():void
			{
				
			}
			public function setCenter(x:int,y:int):void
			{
				_center.setXY(x,y);
			}
			public function get centerX():int
			{
				return _center.x;
			}
			public function get centerY():int
			{
				return _center.y;
			}
			public function get centerXVar():CVariable
			{
				return _center.xVar;
			}
			public function get centerYVar():CVariable
			{
				return _center.yVar;
			}
			public function get centerPoint():CPoint
			{
				return _center;
			}
			
		}
	}