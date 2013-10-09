package cassowaryAS3.data
{
	import cassowaryAS3.data.iterators.ArrayIterator;
	import cassowaryAS3.data.iterators.IIterator;
	
	import flash.utils.Dictionary;

	public class HashSet
	{
		private var _content:Dictionary;
		private var _size:int = 0;
		
		public function HashSet():void
		{
			_content = new Dictionary();
			_size = 0;
		}
	
		public function add(value:Object):void
		{
			if(!contains(value))
			{
				_size++;
				_content[value] = true;
			}	
		}
		
		public function contains(value:Object):Boolean
		{
			if (_size < 1) return false;
			else
			{
				return value in _content;
			}
			/*
			var it:IIterator = getIterator();
			var result:Boolean;
			do
			{
				if (it.current() === value) 
				{
					result = true;
					break;
				}
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
			return result;
			*/
			//return value in _content;
		}
		
		public function forEach(f:Function):void
		{
			for (var k:Object in _content)
			{
				f.call(null,k);		
			}
		}
		public function clear():void
		{
			for (var k:Object in _content)
			{
				delete _content[k];
			}
			_content = new Dictionary();
			_size = 0;
		}
		public function dispose():void
		{
			for (var k:Object in _content)
			{
				delete _content[k];
			}
			_content = null;
			_size = 0;
		}
		
		public function getValues():Array
		{
			var result:Array = [];
			for (var k:Object in _content)
			{
				result.push(k);
			}
			return result;
		}
		public function remove(value:Object):Object
		{
			if (contains(value)) 
			{
				delete _content[value];
				_size--;
				return value;
			}
			throw new Error("HashSet: Element to remove was not found "+value);
			return null;
		}
		public function clone():HashSet
		{
			var h:HashSet = new HashSet();
			for (var v:Object in _content)
			{
				h.add(v);
			}
			return h;
		}
		public function get size():int
		{
			return _size;
		}
		public function toString():String
		{
			var result:String = "[HashSet. Size: "+_size+"] \n";
			for (var k:Object in _content)
			{
				result += ("["+k+"] \n");
			}
			return result;
		}
		public function getIterator():IIterator
		{

			return new ArrayIterator(getValues());
		}
			
	}
}
