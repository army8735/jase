package command {
	import flash.text.*;
	import lexer.*;
	
	public class ReplaceCommand implements ICommand {
		private var tf:TextField;
		private var index:int;
		private var end:int;
		private var source:String;
		private var text:String;
		private var parser:IParser;
		
		public function ReplaceCommand(tf:TextField, parser:IParser, index:int, end:int, source:String, text:String):void {
			this.tf = tf;
			this.index = index;
			this.end = end;
			this.source = source;
			this.text = text;
			this.parser = parser;
			redo();
		}
		
		public function redo(first:Boolean = false):void {
			tf.replaceText(index, end, text.replace(/\r/g, "\n"));
			tf.setSelection(index + text.length, index + text.length);
			parser.replace(tf, index, source, text);
		}
		public function undo():void {
			tf.replaceText(index, index + text.length, source.replace(/\r/g, "\n"));
			tf.setSelection(index, end);
			parser.replace(tf, index, text, source);
		}
	}
}