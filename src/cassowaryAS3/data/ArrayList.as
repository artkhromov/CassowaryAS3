package cassowaryAS3.data
{
	import cassowaryAS3.data.iterators.ArrayIterator;
	import cassowaryAS3.data.iterators.IIterable;
	import cassowaryAS3.data.iterators.IIterator;
	
	public class ArrayList implements IIterable
	{
		private var _content:Array;
		
		public function ArrayList():void
		{
			_content = [];
		}
		public function add(element:Object):void
		{
			_content.push(element);
		}
		public function addAt(index:int,element:Object):void
		{
			_content.splice(index,0,element);
		}
		public function replace(element1:Object,element2:Object):void
		{
			var index1:int = indexOf(element1);
			var index2:int = indexOf(element2);
			if (index1 == index2 || index1 == -1 || index2 == -1) return;
			replaceAt(index1,index2);
		}
		public function replaceAt(index1:int,index2:int):void
		{
			if (validateRange(index1) && validateRange(index2))
			{
				var temp:* = _content[index1];
				_content[index1] = _content[index2];
				_content[index2] = temp;
				temp = null;
			}
		}
		public function remove(element:Object):Object
		{
			var toRemove:Object;
			var it:IIterator = getIterator();
			do
			{
				if (it.current() == element) 
				{
					toRemove = it.current();
					removeAt(int(it.key()));
				}
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
			if (toRemove == null) throw new Error("ArrayList: Element to remove was not found at "+element);
			return toRemove;
		}
		public function removeAt(index:int):Object
		{
			if (validateRange(index)) return _content.splice(index,1);
			else 
			{
				throw new Error("ArrayList: Element to remove was not found at "+index);
				return null;
			}
		}
		public function getAt(index:int):Object
		{
			if (validateRange(index)) return _content[index];
			else return null;
		}
		
		public function contains(element:Object):Boolean
		{
			var it:IIterator = getIterator();
			do
			{
				if (it.current() == element) 
				{
					it.dispose();
					return true;
				}
				
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
			return false;
		}
		public function indexOf(element:Object):int
		{
			var it:IIterator = getIterator();
			var result:int;
			do 
			{
				if (it.current() == element)
				{
					result = int(it.key());
					it.dispose();
					it = null;
					return result;
				}
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
			return -1;
		}
		public function lastIndexOf(element:Object):int
		{
			var it:IIterator = getIterator();
			var result:int = -1;
			do 
			{
				if (it.current() == element)
				{
					result = int(it.key());
				}
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
			return result;
		}
		
		public function forEach(f:Function):void
		{
			var it:IIterator = getIterator();
			do
			{
				f.call(null,it.key(),it.current());
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
		}
		public function isEmpty():Boolean
		{
			return _content.length<1;
		}
		public function get size():int
		{
			return _content.length;
		}
		public function dispose():void
		{
			_content = null;
		}
		public function toArray():Array
		{
			return _content;
		}
		public function clear():void
		{
			_content = [];
		}
		public function getIterator():IIterator
		{
			//trace("Providing iterator for arrayList: ");
			//trace(toString());
			return new ArrayIterator(_content);
		}
		public function toString():String
		{
			var result:String = "[ArrayList. Size: "+size+"]\n";
			for (var i:int = 0;i<_content.length;i++)
			{
				result += "["+i+" : "+_content[i]+"]\n";
			}
			return result;
		}
		private function validateRange(value:int):Boolean
		{
			return (value >= 0) && (value < size);
		}
	}
}