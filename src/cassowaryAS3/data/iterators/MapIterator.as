package cassowaryAS3.data.iterators
{
	import cassowaryAS3.data.HashMap;

	public class MapIterator implements IIterator
	{
		private var _target:HashMap;
		private var _iterator:IIterator;
		
		public function MapIterator(target:HashMap):void
		{
			_target = target;
			reset();
		}
		
		public function current():Object
		{
			return _target.getElement(_iterator.current());
		}
		
		public function dispose():void
		{
			_iterator.dispose();
			_iterator = null;
			_target = null;
		}
		
	
		
		public function forEach(f:Function):void
		{
			_iterator.reset();
			while (_iterator.hasNext())
			{
				f.call(null,_iterator.key(),_target.getElement(_iterator.key()));
				_iterator.next();
			}
		}
		
		public function hasNext():Boolean
		{
			return _iterator.hasNext();
		}
		
		public function key():Object
		{
			return _iterator.current();
		}
		
		public function next():Object
		{
			return _iterator.next();
		}
		
		public function reset():void
		{
			if (_iterator) _iterator.dispose();
			_iterator = createIterator();
		}
		private function createIterator():IIterator
		{
			if (_target.isEmpty()) return new NullIterator();
			else return new ArrayIterator(_target.getKeys());
		}
		
		
	}
}

