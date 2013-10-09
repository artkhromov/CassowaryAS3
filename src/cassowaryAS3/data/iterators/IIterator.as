package cassowaryAS3.data.iterators
{
	public interface IIterator
	{
		function next():Object;
		function hasNext():Boolean;
		function current():Object;
		function reset():void;
		function key():Object;
		function dispose():void;
		function forEach(f:Function):void;
	}
}