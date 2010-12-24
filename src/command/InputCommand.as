package command {
	import flash.text.*;
	import lexer.*;
	
	public class InputCommand implements ICommand {
		private var tf:TextField;
		private var index:int;
		private var text:String;
		private var parser:IParser;
		
		public function InputCommand(tf:TextField, parser:IParser, index:int, text:String):void {
			this.tf = tf;
			this.index = index;
			this.text = text;
			this.parser = parser;
			redo();
		}
		
		public function redo(first:Boolean = false):void {
			tf.replaceText(index, index, text.replace(/\r/g, "\n"));
			tf.setSelection(index + text.length, index + text.length);
			parser.add(tf, index, text);
		}
		public function undo():void {
			tf.replaceText(index, index + text.length, "");
			tf.setSelection(index, index);
			parser.del(tf, index, text);
		}
	}
}