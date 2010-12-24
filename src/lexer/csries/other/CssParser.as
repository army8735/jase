package lexer.csries.other {
	import flash.text.*;
	import lexer.csries.*;
	import state.*;
	import util.*;
	
	public class CssParser extends CSeriesParser {
		private var values:HashMap;
		private var defaultDepth:int; //默认初始化深度，单独分析时为0，作为内嵌解析器时用作参考对象
		
		public function CssParser():void {
			var keywords:Array = "ascent azimuth background-attachment background-color background-image background-position \
background-repeat background baseline bbox border-collapse border-color border-spacing border-style border-top \
border-right border-bottom border-left border-top-color border-right-color border-bottom-color border-left-color \
border-top-style border-right-style border-bottom-style border-left-style border-top-width border-right-width \
border-bottom-width border-left-width border-width border bottom cap-height caption-side centerline clear clip color \
content counter-increment counter-reset cue-after cue-before cue cursor definition-src descent direction display \
elevation empty-cells float font-size-adjust font-family font-size font-stretch font-style font-variant font-weight font \
height left letter-spacing line-height list-style-image list-style-position list-style-type list-style margin-top \
margin-right margin-bottom margin-left margin marker-offset marks mathline max-height max-width min-height min-width orphans \
outline-color outline-style outline-width outline overflow padding-top padding-right padding-bottom padding-left padding page \
page-break-after page-break-before page-break-inside pause pause-after pause-before pitch pitch-range play-during position \
quotes right richness size slope src speak-header speak-numeral speak-punctuation speak speech-rate stemh stemv stress \
table-layout text-align top text-decoration text-indent text-shadow text-transform unicode-bidi unicode-range units-per-em \
vertical-align visibility voice-family volume white-space widows width widths word-spacing x-height z-index".split(" ");
			super(keywords);
			
			keywords = "above absolute all always aqua armenian attr aural auto avoid baseline behind below bidi-override black blink block blue bold bolder \
both bottom braille capitalize caption center center-left center-right circle close-quote code collapse compact condensed \
continuous counter counters crop cross crosshair cursive dashed decimal decimal-leading-zero default digits disc dotted double \
embed embossed e-resize expanded extra-condensed extra-expanded fantasy far-left far-right fast faster fixed format fuchsia \
gray green groove handheld hebrew help hidden hide high higher icon inline-table inline inset inside invert italic \
justify landscape large larger left-side left leftwards level lighter lime line-through list-item local loud lower-alpha \
lowercase lower-greek lower-latin lower-roman lower low ltr marker maroon medium message-box middle mix move narrower \
navy ne-resize no-close-quote none no-open-quote no-repeat normal nowrap n-resize nw-resize oblique olive once open-quote outset \
outside overline pointer portrait pre print projection purple red relative repeat repeat-x repeat-y rgb ridge right right-side \
rightwards rtl run-in screen scroll semi-condensed semi-expanded separate se-resize show silent silver slower slow \
small small-caps small-caption smaller soft solid speech spell-out square s-resize static status-bar sub super sw-resize \
table-caption table-cell table-column table-column-group table-footer-group table-header-group table-row table-row-group teal \
text-bottom text-top thick thin top transparent tty tv ultra-condensed ultra-expanded underline upper-alpha uppercase upper-latin \
upper-roman url visible wait white wider w-resize x-fast x-high x-large x-loud x-low x-slow x-small x-soft xx-large xx-small yellow".split(" ");
			values = new HashMap(keywords);
			defaultDepth = 0;
		}
		
		public override function add(tf:TextField, begin:int, text:String):void {
			super.add(tf, begin, text);
			//分析、修复后面的行、重绘
			scan(tf);
			repairNextLines(tf);
			update(tf);
		}
		
		private function scan(tf:TextField):void {
			//第一行的状态不是normal时要预处理
			switch (lineState.getLineState(currentLine)) {
				case LineState.STRING:
					dealString();
				break;
				case LineState.CHAR:
					dealChar();
				break;
				case LineState.MULTI_COMMENT:
					dealMultiComment();
				break;
				case LineState.PERL_REG:
					dealPerlReg();
				break;
				default:
					readChar();
				break;
			}
			//遍历后面的代码，修复状态
			while (index <= code.length) {
				//斜线星号为多行注释
				if (cc == Character.SLASH && code.charCodeAt(index) == Character.STAR) {
					dealMultiComment();
				}
				//双引号
				else if (cc == Character.DOUBLE_QUOTE) {
					dealString();
				}
				//单引号
				else if (cc == Character.SINGLE_QUOTE) {
					dealChar();
				}
				//数字
				else if (Character.isDigit(cc)) {
					dealNumber();
				}
				//标识符
				else if (Character.isLetter(cc) || cc == Character.DOLLAR || cc == Character.UNDER_LINE) {
					dealWorld();
				}
				//其它
				else {
					if (cc == Character.ENTER) {
						lineState.setLineRender(++currentLine);
						lineState.addLineState(currentLine, nextLineState);
						lineState.addLineBlocks(currentLine);
						lineRegs.addLineReg(currentLine, isPerlReg);
						offset = index;
					}
					readChar();
				}
			}
		}
		private function dealString():void {
			var start:int = index - 1;
			nextLineState = LineState.STRING;
			//dfa解析
			while (index <= code.length) {
				readChar();
				//转义符继续读入下一个
				if (cc == Character.BACK_SLASH) {
					readChar();
					//如果是换行符，增加此行字符串block，存入下一行状态，调整偏移值
					if (cc == Character.ENTER) {
						lineState.addBlock(currentLine++, start - offset, index - offset - 1, STRING_COLOR);
						lineState.addLineState(currentLine, nextLineState);
						lineState.addLineBlocks(currentLine);
						lineState.setLineRender(currentLine);
						lineRegs.addLineReg(currentLine, isPerlReg);
						offset = start = index;
					}
					//或者到了末尾
					else if (index > code.length) {
						lineState.addBlock(currentLine, start - offset, index - offset - 1, STRING_COLOR);
						return;
					}
				}
				//不正确的行结束
				else if (cc == Character.ENTER) {
					nextLineState = LineState.NORMAL;
					lineState.addLineState(++currentLine, nextLineState);
					lineState.addLineBlocks(currentLine);
					lineState.setLineRender(currentLine);
					lineRegs.addLineReg(currentLine, isPerlReg);
					readChar();
					offset = index;
					break;
				}
				//结束调整索引
				else if (cc == Character.DOUBLE_QUOTE) {
					nextLineState = LineState.NORMAL;
					lineState.addBlock(currentLine, start - offset, index - offset, STRING_COLOR);
					readChar();
					break;
				}
			}
			nextLineState = LineState.NORMAL;
		}
	}
}