package command {
	import edit.*;
	import flash.text.*;
	import lexer.*;
	
	public class MultiInputCommand implements ICommand {
		private var tf:TextField;
		private var left:int, right:int;
		private var startLine:int, endLine:int;
		private var parser:IParser;
		
		public function MultiInputCommand(tf:TextField, parser:IParser, left:int, right:int, startLine:int, endLine:int):void {
			this.tf = tf;
			this.left = left;
			this.right = right;
			this.startLine = startLine;
			this.endLine = endLine;
			this.parser = parser;
			redo();
		}
		
		public function redo(first:Boolean = false):void {
			var index:int;
			for (var i:int = startLine; i <= endLine; i++) {
				index = tf.getLineOffset(i);
				tf.replaceText(index, index, Editor.TAB);
				parser.add(tf, index, Editor.TAB);
			}
			tf.setSelection(left + Editor.TAB.length, right + Editor.TAB.length * (endLine - startLine + 1));
		}
		public function undo():void {
			var index:int;
			for (var i:int = startLine; i <= endLine; i++) {
				index = tf.getLineOffset(i);
				tf.replaceText(index, index + 2, "");
				parser.del(tf, index, Editor.TAB);
			}
			tf.setSelection(left, right);
		}
	}
}