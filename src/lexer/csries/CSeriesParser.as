package lexer.csries {
	import flash.text.*;
	import lexer.*;
	import state.*;
	import util.*;
	
	public class CSeriesParser extends AbstractParser {
		
		public function CSeriesParser(keyWords:Array):void {
			super(keyWords);
		}
		
		protected function dealSingleComment():void {
			//确定结尾位置，存入下一行状态，调整索引
			var start:int = index - 2;
			index = code.indexOf("\r", index);
			if (index == -1) {
				index = code.length;
			}
			lineState.addBlock(currentLine, start - offset, index - offset, SINGLE_COMMENT_COLOR);
			nextLineState = LineState.NORMAL;
			readChar();
		}
		protected function dealMultiComment():void {
			nextLineState = LineState.MULTI_COMMENT;
			//先计算结尾位置
			var start:int = index - 2,
				end:int = code.indexOf("*/", index);
			if (end == -1) {
				end = code.length;
			}
			else {
				end += 2;
				nextLineState = LineState.NORMAL;
			}
			//遍历中间代码，处理换行
			while (index < end) {
				readChar();
				//如果是换行符，增加此行字符串block，存入下一行状态，调整偏移值
				if (cc == Character.ENTER) {
					lineState.addBlock(currentLine++, start - offset, index - offset - 1, MULTI_COMMENT_COLOR);
					lineState.addLineState(currentLine, LineState.MULTI_COMMENT);
					lineState.addLineBlocks(currentLine);
					lineState.setLineRender(currentLine);
					offset = start = index;
				}
			}
			//存入结尾部分，回归下行状态
			lineState.addBlock(currentLine, start - offset, index - offset, MULTI_COMMENT_COLOR);
			readChar();
		}
	}

}