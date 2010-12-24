package lexer {
	import flash.display.*;
	import flash.text.*;
	import flash.external.*;
	import state.*;
	import util.*;
	
	public class AbstractParser extends Sprite implements IParser {
		protected var NORMAL_COLOR:uint = 0;
		protected var STRING_COLOR:uint;
		protected var CHAR_COLOR:uint;
		protected var SINGLE_COMMENT_COLOR:uint;
		protected var MULTI_COMMENT_COLOR:uint;
		protected var KEYWORD_COLOR:uint;
		protected var NUMBER_COLOR:uint;
		
		protected var keyWordMap:HashMap; //关键字map
		protected var formatter:TextFormat; //渲染format统一保存变量
		
		protected var code:String; //当前处理的代码
		protected var cc:int; //向前看字符码
		protected var index:int; //向前看索引
		protected var depth:int; //当前行深度s
		
		public var lineState:LineState; //行状态，包含每行起始状态和每行是否被渲染过
		protected var currentLine:int; //当前行索引
		protected var offset:int; //修改行第一个字符相对于code第一个字符的偏移索引
		protected var nextLineState:int //修改行范围之后的下一行状态
		
		public function AbstractParser(keyWords:Array):void {
			keyWordMap = new HashMap(keyWords);
			lineState = new LineState();
			depth = 0;
		}

		protected function readChar():void {
			cc = code.charCodeAt(index++);
		}
		
		public function update(tf:TextField):void {
			if (formatter == null) {
				formatter = tf.getTextFormat(0, 1);
			}
			//遍历渲染当前可视行
			for (var i:int = tf.scrollV - 1; i < tf.bottomScrollV; i++) {
				renderLine(tf, i);
				lineState.setLineRender(i, true);
			}
		}
		public function add(tf:TextField, begin:int, text:String):void {
			//初始化
			index = offset = 0;
			code = text;
			currentLine = tf.getLineIndexOfChar(begin);
			//将当前行重新格式化
			lineState.setLineRender(currentLine, false);
			lineState.setLineBlocks(currentLine);
			nextLineState = lineState.getLineState(currentLine);
			//将修改起始索引与修改所在行起始字符索引之间可能的文本加到code前面
			var start:int = tf.getLineOffset(currentLine);
			if (start < begin) {
				code = tf.text.slice(start, begin) + code; 
			}
			//同理，如果有末尾代码则增加到code后面
			if (begin + text.length < tf.text.length) {
				var end:int = tf.text.indexOf("\r", begin + text.length);
				if (end != -1) {
					code += tf.text.slice(begin + text.length, end);
				}
				else {
					code += tf.text.slice(begin + text.length);
				}
			}
		}
		public function del(tf:TextField, begin:int, text:String):void {;
			//初始化
			index = 0;
			currentLine = tf.getLineIndexOfChar(begin);
			var lines:int = count(text, "\r");
			//为-1时，可能删除的是最后一行唯一的字符，也可能是选区末尾是代码末尾
			if (currentLine == -1) {
				currentLine = lineState.size() - lines - 1;
			}
			lineState.setLineRender(currentLine);
			lineState.setLineBlocks(currentLine);
			nextLineState = lineState.getLineState(currentLine);
			//统计删除文本中的换行数，删除行状b态
			lineState.del(currentLine + 1, lines);
			//生成偏移量索引和本行代码，解析本行
			offset = tf.getLineOffset(currentLine);
			begin = tf.text.indexOf("\r", offset);
			if (begin == -1) {
				begin = tf.text.length;
			}
			code = tf.text.slice(offset, begin);
			//初始化索引为0，相对这段输入代码而言
			offset = 0;
		}
		public function replace(tf:TextField, begin:int, source:String, text:String):void {
			del(tf, begin, source);
			add(tf, begin, text);
		}
		public function format(tf:TextField):void {
			
		}
		public function check(tf:TextField):void {
			
		}
		
		protected function count(text:String, char:String):int {
			var count:int = 0, index:int = -1;
			while ((index = text.indexOf(char, ++index)) != -1) {
				count++;
			}
			return count;
		}
		protected function renderLine(tf:TextField, line:int):void {
			//计算此行首尾索引
			var start:int = tf.getLineOffset(line),
				end:int = tf.text.indexOf("\r", start);
			if (end == -1) {
				end = tf.text.length;
			}
			//需要渲染时才计算代码
			if (lineState.getLineRender(line) == false) {
				//本行全部重新默认高亮
				if (start < end) {
					formatter.color = 0;
					tf.setTextFormat(formatter, start, end);
				}
				//根据偏移量计算block
				var vector:Vector.<BlockState> = lineState.getLineBlocks(line);
				for (var i:int = 0; i < vector.length; i++) {
					formatter.color = vector[i].getColor();
					tf.setTextFormat(formatter, start + vector[i].getStart(), start + vector[i].getEnd());
				}
			}
		}
		
		protected function debug(s:String, ...paras):void {
			s = '<span style="color:#c33;">' + s.replace(/"/g, '\\"').replace(/\\/g, "\\\\") + "</span>";
			for (var i:int = 0; i < paras.length; i++) {
				s += ", " + paras[i];
			}
			ExternalInterface.call("debug", s);
		}
	}

}