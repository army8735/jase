package lexer.csries.ecma {
	import flash.text.*;
	import lexer.csries.*;
	import state.*;
	import util.*;
	import edit.*;
	
	public class EcmaScriptParser extends CSeriesParser {
		protected var PERL_REG_COLOR:uint;
		
		protected var isPerlReg:Boolean; //是否perl风格正则表达式
		protected var lineRegs:LineRegs; //存放每行perl风格状态
		
		public function EcmaScriptParser(keyWords:Array):void {
			super(keyWords);
			//记录每行正则状态
			isPerlReg = true;
			lineRegs = new LineRegs();
		}
		
		public override function add(tf:TextField, begin:int, text:String):void {
			super.add(tf, begin, text);
			isPerlReg = lineRegs.getLineReg(currentLine);
			//分析、修复后面的行、重绘
			scan(tf);
			repairNextLines(tf);
			update(tf);
		}
		public override function del(tf:TextField, begin:int, text:String):void {
			super.del(tf, begin, text);
			//统计删除文本中的换行数，删除行正则状态
			lineRegs.del(currentLine + 1, count(text, "\r"));
			isPerlReg = lineRegs.getLineReg(currentLine);
			scan(tf);
			repairNextLines(tf);
			//调用更新重绘
			update(tf);
		}
		public override function replace(tf:TextField, begin:int, source:String, text:String):void {
			super.del(tf, begin, source);
			lineRegs.del(currentLine + 1, count(text, "\r"));
			add(tf, begin, text);
		}
		
		protected function scan(tf:TextField):void {
			//第一行的状态不是normal时要预处理
			switch (lineState.getLineState(currentLine)) {
				case LineState.STRING:
					isPerlReg = true;
					dealString();
				break;
				case LineState.CHAR:
					isPerlReg = true;
					dealChar();
				break;
				case LineState.MULTI_COMMENT:
					dealMultiComment();
				break;
				case LineState.PERL_REG:
					isPerlReg = true;
					dealPerlReg();
				break;
				default:
					readChar();
				break;
			}
			//遍历后面的代码，修复状态
			while (index <= code.length) {
				//斜线检查注释或者除号或者正则
				if (cc == Character.SLASH) {
					readChar();
					//星号为多行注释
					if (cc == Character.STAR) {
						dealMultiComment();
					}
					//双斜线单行注释
					else if (cc == Character.SLASH) {
						dealSingleComment();
					}
					//perl风格的注释
					else if (isPerlReg) {
						dealPerlReg();
					}
				}
				//双引号
				else if (cc == Character.DOUBLE_QUOTE) {
					isPerlReg = true;
					dealString();
				}
				//单引号
				else if (cc == Character.SINGLE_QUOTE) {
					isPerlReg = true;
					dealChar();
				}
				//数字
				else if (Character.isDigit(cc)) {
					isPerlReg = false;
					dealNumber();
				}
				//标识符
				else if (Character.isLetter(cc) || cc == Character.DOLLAR || cc == Character.UNDER_LINE) {
					isPerlReg = false;
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
					else if (cc == Character.RIGHT_PARENTHESE) {
						isPerlReg = false;
					}
					else if (!Character.isBlank(cc)) {
						isPerlReg = true;
					}
					readChar();
				}
			}
		}
		protected function repairNextLines(tf:TextField):void {
			//修改范围块代码的结束状态是否与已存下行状态相符，不等则继续向下分析直到相等位置
			while (lineState.size() > ++currentLine) {
				if (lineState.getLineState(currentLine) != nextLineState) {
					//初始化分析代码为本行代码，设置各项索引
					offset = tf.getLineOffset(currentLine);
					var start:int = tf.text.indexOf("\r", offset);
					if (start == -1) {
						start = tf.text.length;
					}
					code = tf.text.slice(offset, start);
					offset = index = 0;
					lineState.setLineState(currentLine, nextLineState);
					lineState.setLineRender(currentLine);
					lineState.setLineBlocks(currentLine);
					scan(tf);
				}
				else {
					break;
				}
			}
		}
		protected function dealString():void {
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
		protected function dealChar():void {
			var start:int = index - 1;
			nextLineState = LineState.CHAR;
			//dfa解析
			while (index <= code.length) {
				readChar();
				//转义符继续读入下一个
				if (cc == Character.BACK_SLASH) {
					readChar();
					//如果是换行符，增加此行字符串block，存入下一行状态，调整偏移值
					if (cc == Character.ENTER) {
						lineState.addBlock(currentLine++, start - offset, index - offset - 1, CHAR_COLOR);
						lineState.addLineState(currentLine, nextLineState);
						lineState.addLineBlocks(currentLine);
						lineState.setLineRender(currentLine);
						lineRegs.addLineReg(currentLine, isPerlReg);
						offset = start = index;
					}
					//或者到了末尾
					else if (index > code.length) {
						lineState.addBlock(currentLine, start - offset, index - offset - 1, CHAR_COLOR);
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
				else if (cc == Character.SINGLE_QUOTE) {
					nextLineState = LineState.NORMAL;
					lineState.addBlock(currentLine, start - offset, index - offset, CHAR_COLOR);
					readChar();
					break;
				}
			}
			nextLineState = LineState.NORMAL;
		}
		protected function dealNumber():void {
			var start:int = index - 1;
			//以0开头需判断16进制或者8进制
			if (cc == Character.ZERO) {
				readChar();
				//后面是x进入16进制状态
				if (Character.isX(cc)) {
					readChar();
					//寻找第一个不是16进制的字符位置跳出
					while (index < code.length) {
						if (!Character.isDigit16(cc)) {
							break;
						}
						readChar();
					}
					//小数点继续，其它退出
					if (!cc == Character.DECIMAL) {
						lineState.addBlock(currentLine, start - offset, index - offset - 1, NUMBER_COLOR);
						return;
					}
				}
				//后面是数字进入8进制状态
				else if (Character.isDigit(cc)) {
					readChar();
					//寻找第一个不是数字的字符跳出
					while (index < code.length) {
						if (!Character.isDigit(cc)) {
							break;
						}
						readChar();
					}
					//小数点继续，其它退出
					if (!cc == Character.DECIMAL) {
						lineState.addBlock(currentLine, start - offset, index - offset - 1, NUMBER_COLOR);
						return;
					}
				}
				//不是小数点跳出
				else if (cc != Character.DECIMAL) {
					lineState.addBlock(currentLine, start - offset, index - offset - 1, NUMBER_COLOR);
					return;
				}
			}
			//先处理整数部分
			else {
				do {
					readChar();
				}
				while (Character.isDigit(cc));
			}
			//是小数点则处理小数
			if (cc == Character.DECIMAL) {
				do {
					readChar();
				}
				while (Character.isDigit(cc));
			}
			//指数部分
			if (Character.isExponent(cc)) {
				readChar();
				//+-号
				if (cc == Character.ADD || cc == Character.MINUS) {
					readChar();
				}
				//指数数字
				while (Character.isDigit(cc)) {
					readChar();
				}
			}
			lineState.addBlock(currentLine, start - offset, index - offset - 1, NUMBER_COLOR);
		}
		protected function dealWorld():void {
			var start:int = index - 1;
			//直到不是字母数字下划线美元符号为止
			while (index <= code.length) {
				readChar();
				if (Character.isLetterOrDigit(cc) || cc == Character.UNDER_LINE || cc == Character.DOLLAR) {
					//
				}
				else {
					break;
				}
			}
			//是关键字才高亮
			if (keyWordMap.hasKey(code.slice(start, index - 1))) {
				lineState.addBlock(currentLine, start - offset, index - offset - 1, KEYWORD_COLOR);
			}
		}
		protected function dealPerlReg():void {
			var start:int = Math.max(0, index - 2);
			nextLineState = LineState.PERL_REG;
			outer:
			while (index <= code.length) {
				//转义符多读入下一个字符
				if (cc == Character.BACK_SLASH) {
					readChar();
					//正则跨行
					if (cc == Character.ENTER) {
						lineState.addBlock(currentLine++, start - offset, index - offset - 1, PERL_REG_COLOR);
						lineState.addLineState(currentLine, nextLineState);
						lineState.addLineBlocks(currentLine);
						lineState.setLineRender(currentLine);
						lineRegs.addLineReg(currentLine, isPerlReg);
						offset = start = index;
					}
					//或者到了末尾
					else if (index > code.length) {
						lineState.addBlock(currentLine, start - offset, index - offset - 1, PERL_REG_COLOR);
						return;
					}
				}
				//[符号进入字符集处理
				else if (cc == Character.LEFT_BRACKET) {
					while (index <= code.length) {
						readChar();
						//转义符多读入下一个字符
						if (cc == Character.BACK_SLASH) {
							readChar();
							//正则跨行
							if (cc == Character.ENTER) {
								lineState.addBlock(currentLine++, start - offset, index - offset - 1, PERL_REG_COLOR);
								lineState.addLineState(currentLine, nextLineState);
								lineState.addLineBlocks(currentLine);
								lineState.setLineRender(currentLine);
								lineRegs.addLineReg(currentLine, isPerlReg);
								offset = start = index;
								readChar();
								break;
							}
							//或者到了末尾
							else if (index > code.length) {
								lineState.addBlock(currentLine, start - offset, index - offset - 1, PERL_REG_COLOR);
								return;
							}
						}
						//]符号字符集结束
						else if (cc == Character.RIGHT_BRACKET) {
							readChar();
							continue outer;
						}
						//行末尾，不正确的换行
						else if (cc == Character.ENTER) {
							nextLineState = LineState.NORMAL;
							lineState.addLineState(++currentLine, nextLineState);
							lineState.addLineBlocks(currentLine);
							lineState.setLineRender(currentLine);
							lineRegs.addLineReg(currentLine, isPerlReg);
							offset = index;
							readChar();
							return;
						}
					}
				}
				//行末尾，不正确的换行
				else if (cc == Character.ENTER) {
					nextLineState = LineState.NORMAL;
					lineState.addLineState(++currentLine, nextLineState);
					lineState.addLineBlocks(currentLine);
					lineState.setLineRender(currentLine);
					lineRegs.addLineReg(currentLine, isPerlReg);
					offset = index;
					readChar();
					return;
				}
				//正则表达式结束
				else if (cc == Character.SLASH) {
					while (index <= code.length) {
						readChar();
						//flag是字母则继续，否则跳出
						if(!Character.isLetter(cc)) {
							break;
						}
					}
					nextLineState = LineState.NORMAL;
					lineState.addBlock(currentLine, start - offset, index - offset - 1, PERL_REG_COLOR);
					readChar();
					return;
				}
				readChar();
			}
			nextLineState = LineState.NORMAL;
			lineState.addBlock(currentLine, start - offset, index - offset - 1, PERL_REG_COLOR);
		}
		protected override function dealMultiComment():void {
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
					lineState.addBlock(currentLine++, start - offset, index - offset, MULTI_COMMENT_COLOR);
					lineState.addLineState(currentLine, LineState.MULTI_COMMENT);
					lineState.addLineBlocks(currentLine);
					lineState.setLineRender(currentLine);
					lineRegs.addLineReg(currentLine, isPerlReg);
					offset = start = index;
				}
			}
			//存入结尾部分，回归下行状态
			lineState.addBlock(currentLine, start - offset, index - offset, MULTI_COMMENT_COLOR);
			readChar();
		}

	}

}