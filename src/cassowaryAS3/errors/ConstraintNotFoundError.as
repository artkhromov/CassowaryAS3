package cassowaryAS3.errors
{
	public class ConstraintNotFoundError extends Error
	{
		public function ConstraintNotFoundError(message:*="", id:*=0)
		{
			super(message, id);
		}
	}
}