package lexer.csries.ecma {
	
	public class JavascriptParser extends EcmaScriptParser {
		
		public function JavascriptParser():void {
			var keyWords:Array = "if else for break case continue function true \
switch default do while int float double long short char null public super in \
abstract boolean byte class const debugger delete static void synchronized this \
enum export extends final finally goto implements protected throw throws transient \
instanceof interface native new package private import try typeof var volatile \
with document window false return".split(" ");
			super(keyWords);
			
			STRING_COLOR = CHAR_COLOR = 0xA31515;
			SINGLE_COMMENT_COLOR = MULTI_COMMENT_COLOR = 0x339933;
			KEYWORD_COLOR = 0x3333FF;
			NUMBER_COLOR = 0x3399CC;
			PERL_REG_COLOR = 0xFF00FF;
		}
	}

}