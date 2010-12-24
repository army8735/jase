package lexer.csries.ecma {
	
	public class ActionscriptParser extends EcmaScriptParser {
		
		public function ActionscriptParser():void {
			var keyWords:Array = "as class const delete extends finally to true false continue \
in instanceof interface internal is native new null package Boolean uint Infinity return \
private protected public super this throw import include Date Error RegExp NaN void int \
try typeof use var with each get set namespace implements function XML Object static break \
dynamic final native override trace String Number Array XMLLIST if else do while for swtich case".split(" ");
			super(keyWords);
			
			STRING_COLOR = CHAR_COLOR = 0xA31515;
			SINGLE_COMMENT_COLOR = MULTI_COMMENT_COLOR = 0x339933;
			KEYWORD_COLOR = 0x3333FF;
			NUMBER_COLOR = 0x3399CC;
			PERL_REG_COLOR = 0xFF00FF;
		}
	}

}