package cassowaryAS3.errors
{
	public class RequiredFailureError extends Error
	{
		public function RequiredFailureError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}