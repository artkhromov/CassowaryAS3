package cassowaryAS3.errors
{
	public class InternalError extends Error
	{
		public function InternalError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}