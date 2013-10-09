package cassowaryAS3.data.iterators
{
	import flash.errors.IllegalOperationError;

	public class ArrayIterator implements IIterator
	{
		private var _target:Array;
		private var _counter:int;
		
		public function ArrayIterator(target:Array):void
		{
			_target = target;
			_counter = 0;
		}
		
		public function next():Object
		{
			_counter++;
			return current();
		}
		public function hasNext():Boolean
		{
			return _counter < _target.length;
		}
		public function key():Object
		{
			return _counter;
		}
		
		public function current():Object
		{
			if (validateRange(_counter))
			{
				//trace("ArrayIterator: getting current "+_target[_counter].toString()+" at "+_counter);
				return _target[_counter];
			}
			else 
			{
				//throw new Error("ArrayIterator: current: "+_counter+" index is out of bounds: "+_target.length); 
				//trace("Itterator counter is out of range");
				return null;
			}
		}
		
		public function reset():void
		{
			_counter = 0;
		}
		
		public function forEach(f:Function):void
		{
			for (var i:int = 0;i<_target.length;i++)
			{
				f.call(null,i,_target[i]);
			}
		}
		
		public function dispose():void
		{
			_target = null;
		}
		private function validateRange(value:int):Boolean
		{
			return (value >= 0) && (value < _target.length);
		}
	}
}