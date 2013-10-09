package cassowaryAS3.data
{
	import cassowaryAS3.data.iterators.IIterator;
	import cassowaryAS3.data.iterators.MapIterator;
	
	import flash.utils.Dictionary;

	public class HashMap
	{
		private var _content:Dictionary;
		private var _size:int = 0;
		
		public function HashMap():void
		{
			_content = new Dictionary();
			_size = 0;
		}
		public function add(key:Object,value:Object):void
		{
			//trace("HMap : adding value for "+key+" value = "+value);
			//trace("----hasKey "+hasKey(key));
			if (!key) throw new Error("HASHMAP: unable to add "+value+" for null key");
			if(!hasKey(key)) _size++;
			_content[key] = value;
		}
		
		public function setValueForKey(key:Object,value:Object):void
		{
			add(key,value);
		}
		public function getValue(key:Object):Object
		{
			//trace("HMap : getting value for "+key);
			//trace("----hasKey "+hasKey(key));
			if (hasKey(key)) return _content[key];
			else return null;
		}
		public function forEach(scope:*,f:Function):void
		{
			for (var k:Object in _content)
			{
				f.call(scope,k,_content[k]);		
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
		public function getKeys():Array
		{
			var result:Array = [];
			for (var k:Object in _content)
			{
				result.push(k);
			}
			return result;
		}
		
		public function getValues():Array
		{
			var result:Array = [];
			for (var k:Object in _content)
			{
				result.push(_content[k]);
			}
			return result;
		}
		public function removeByKey(key:Object):Object
		{
			var t:Object;
			if (hasKey(key)) 
			{
				t = _content[key];
				delete _content[key];
				_size--;
			}
			else throw new Error("HashMap: Key to remove was not found "+key);
			return t;
		}
		public function remove(element:Object):Object
		{
			var it:IIterator = getIterator();
			var result:Object;
			do
			{
				if (it.current() == element) 
				{
					removeByKey(it.key());
					result = element;
					break;
				}
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
			throw new Error("HashMap: Element to remove was not found "+element);
			return null;
		}
		public function clone():HashMap
		{
			var h:HashMap = new HashMap();
			for (var k:Object in _content)
			{
				h.add(k,_content[k]);
			}
			return h;
		}
		public function get size():int
		{
			return _size;
		}
		public function toString():String
		{
			var result:String = "[HashTable. Size: "+_size+"] \n";
			for (var k:Object in _content)
			{
				result += ("["+k+" : "+_content[k]+"] \n");
			}
			return result;
		}
		public function getKey(element:Object):Object
		{
			var it:IIterator = getIterator();
			var keyToReturn:Object;
			do
			{
				if (it.current() == element) 
				{
					keyToReturn = it.key();
					break;
					
				}
				it.next();
			}
			while (it.hasNext());
			it.dispose();
			it = null;
			return keyToReturn;
		}
		public function getElement(key:Object):Object
		{
			if (hasKey(key))
			{
				return _content[key];
			}
			else return null;
		}
		
		public function hasKey(key:Object):Boolean
		{
			if (size < 1) return false;
			else
			{
				return key in _content;
			}
			/*
			var it:IIterator = getIterator();
			var result:Boolean;
			while (it.hasNext())
			{
				if (it.key() == key) 
				{
					result = true;
					break;
				}
				it.next();
			}
			
			it.dispose();
			it = null;
			return result;
			}
			*/
			//
		}
		
		public function hasElement(element:Object):Boolean
		{
			var it:IIterator = getIterator();
			var result:Boolean;
			do
			{
				if (it.current() == element) 
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
		}
		public function hasKeyElementPair(key:Object,element:Object):Boolean
		{
			if (hasKey(key) && _content[key] === element) return true;
			else return false;
		}
		/*
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
		
		public function getKeys():Array
		{
			var result:Array = [];
			for (var key:Object in _content)
			{
				result.push(key);
			}
			return result;
		}
		*/
		public function getElements():Array
		{
			var result:Array = [];
			for (var key:Object in _content)
			{
				result.push(_content[key]);
			}
			return result;
		}
		public function dispose():void
		{
			_content = null;
			_size = 0;
		}
		
		public function getIterator():IIterator
		{
			//trace("Provide iterator for map: ");
			//trace(toString());
			return new MapIterator(this);
		}
		public function isEmpty():Boolean
		{
			return _size < 1;
		}
		
	}
}
