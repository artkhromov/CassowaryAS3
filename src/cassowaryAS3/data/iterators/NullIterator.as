package cassowaryAS3.data.iterators
{
	public class NullIterator implements IIterator
	{
		public function NullIterator()
		{
		}
		
		public function next():Object
		{
			return null;
		}
		
		public function hasNext():Boolean
		{
			return false;
		}
		
		public function current():Object
		{
			return null;
		}
		
		public function reset():void
		{
		}
		
		public function key():Object
		{
			return null;
		}
		
		public function dispose():void
		{
		}
		
		public function forEach(f:Function):void
		{
		}
	}
}