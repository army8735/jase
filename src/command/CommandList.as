package command {
	import flash.text.*;
	import edit.*;
	
	public class CommandList {
		private var undoList:Vector.<ICommand>, redoList:Vector.<ICommand>;
		
		public function CommandList():void {
			clear();
		}
		
		public function addCommand(cmd:ICommand):void {
			//超过最大命令链长度需先出队列一个
			if (undoList.length > Editor.UNDO_SIZE) {
				undoList.shift();
			}
			//每添加一次命令，清空redoList
			if(redoList.length) {
				redoList = new Vector.<ICommand>();
			}
			undoList.push(cmd);
		}
		public function undo():Boolean {
			//undoList中有命令则执行，并将相应命令出栈存入redoList中
			if(undoList.length) {
				var cmd:ICommand = undoList.pop() as ICommand;
				cmd.undo();
				redoList.push(cmd);
				return true;
			}
			//为空返回false
			else {
				return false;
			}
		}
		public function redo():Boolean {
			//redoList中有命令则执行，并将相应命令出栈存入undoList中
			if (redoList.length) {
				var cmd:ICommand = redoList.pop() as ICommand;
				cmd.redo();
				undoList.push(cmd);
				return true;
			}
			//为空返回false
			else {
				return false;
			}
		}
		public function clear():void {
			undoList = new Vector.<ICommand>();
			redoList = new Vector.<ICommand>();
		}
	}

}