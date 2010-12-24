package command {
	
	public interface ICommand {
		function redo(first:Boolean = false):void;
		function undo():void;
	}
	
}