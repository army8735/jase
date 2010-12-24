package command {
	import flash.text.*;
	import lexer.*;
	
	public class BackSpaceCommand implements ICommand {
		private var tf:TextField;
		private var index:int;
		private var text:String;
		private var parser:IParser;
		
		public function BackSpaceCommand(tf:TextField, parser:IParser, index:int, text:String):void {
			this.tf = tf;
			this.index = index;
			this.text = text;
			this.parser = parser;
			redo();
		}
		
		public function redo(first:Boolean = false):void {
			tf.replaceText(index - 1, index, "");
			tf.setSelection(index - 1, index - 1);
			parser.del(tf, index - 1, text);
		}
		public function undo():void {
			tf.replaceText(index - 1, index - 1, text);
			tf.setSelection(index, index);
			parser.add(tf, index - 1, text.replace(/\r/g, "\n"));
		}
	}
}