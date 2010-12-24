package edit {
	import flash.display.*;
	import flash.net.*;
	import flash.text.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.external.*;
	import fl.controls.*;
	import fl.events.*;
	import ui.msg.*;
	import util.*;
	import command.*;
	import lexer.*;
	
	public class Editor extends Sprite {
		public static const TAB:String = "\u3000\u3000";
		public static const UNDO_SIZE:int = 255;
		
		private var lineNum:TextField;
		private var tf:TextField;
		private var vScrollBar:UIScrollBar;
		private var hScrollBar:UIScrollBar;
		private var msgBox:MsgBox;
		
		private var commandList:CommandList; //命令链
		private var left:int, right:int; //当前选区索引
		private var so:SharedObject; //保存代码至本地
		
		private var parser:IParser; //动态高亮解析器
		private var init:Boolean; //是否加载完初始化代码
		
		public function Editor(w:int, h:int, th:int, msgBox:MsgBox, code:String):void {
			this.msgBox = msgBox;
			left = right = 0;
			
			so = SharedObject.getLocal("jase");
			init = false;
			
			initView(w, h - th);
			initCode(code);
			reLayout(w, h, th);
			
			tf.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
			tf.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			
			//全局侦听tag键，改变默认行为
			addEventListener(Event.ADDED_TO_STAGE, function() {
				stage.addEventListener(KeyboardEvent.KEY_UP, function(event:KeyboardEvent):void {
					if (event.keyCode == Keyboard.TAB) {
						focus();
					}
				});
			});
		}
		
		private function initView(w:int, h:int):void {
			lineNum = getChildAt(0) as TextField;
			lineNum.textColor = 0x999999;
			lineNum.width = lineNum.textWidth + 4;
			
			tf = getChildAt(1) as TextField;
			tf.x = lineNum.width;
			tf.borderColor = 0x999999;
			
			vScrollBar = getChildAt(2) as UIScrollBar;
			vScrollBar.scrollTarget = tf;
			vScrollBar.addEventListener(ScrollEvent.SCROLL, function() {
				parser.update(tf);
				updateLineNum();
			});
			
			hScrollBar = getChildAt(3) as UIScrollBar;
			hScrollBar.scrollTarget = tf;
			hScrollBar.direction = ScrollBarDirection.HORIZONTAL;
		}
		private function initCode(code:String):void {
			//去除\r，使得所有浏览器换行表现统一（防止ie为\r\n，所有浏览器均为\n，但textfield会自动将\n转回\r）
			if (code.indexOf("\r") > -1) {
				code = code.replace(/\r/g, "");
			}
			if (code.indexOf("\t") > -1) {
				code = code.replace(/\t/g, TAB);
			}
			//初始化内容，防止代码过长造成假死，分段append
			if (code.length > 0) {
				var index:int = 0;
				addEventListener(Event.ENTER_FRAME, function(event:Event):void {
					tf.appendText(code.slice(index, index + 1000));
					index += 1000;
					if (index > code.length) {
						init = true;
						updateLineNum();
						removeEventListener(Event.ENTER_FRAME, arguments.callee);
					}
				});
			}

		}
		private function updateLineNum():void {
			var w:int = lineNum.width;
			//设置行号
			lineNum.text = "";
			for (var i:int = tf.scrollV; i <= tf.bottomScrollV; i++) {
				lineNum.appendText(i + "\n");
			}
			lineNum.width = lineNum.textWidth + 4;
			//更新宽度
			if (lineNum.width != w) {
				tf.x = lineNum.width;
				tf.width -= lineNum.width - w;
				vScrollBar.x = tf.x + tf.width;
				hScrollBar.x = tf.x;
				hScrollBar.width = tf.width;
			}
			hScrollBar.update();
			vScrollBar.update();
		}
		
		public function reLayout(w:int, h:int, th:int):void {
			x = Main.PADDING;
			y = th + Main.PADDING * 2;
			
			lineNum.height = h - th - 1 - hScrollBar.height - Main.PADDING * 3;
			
			tf.width = w - 1 - vScrollBar.width - Main.PADDING * 2 - tf.x;
			tf.height = lineNum.height;
			
			vScrollBar.x = tf.x + tf.width;
			vScrollBar.y = tf.y;
			vScrollBar.height = tf.height + 1;
			vScrollBar.update();
			
			hScrollBar.x = tf.x;
			hScrollBar.y = tf.height;
			hScrollBar.width = tf.width;
			hScrollBar.update();
		}
		public function hasInit():Boolean {
			return init;
		}
		
		private function focus():void {
			stage.focus = tf;
		}
		private function saveDelete():void {
			//光标处于文本最后按del是无效的
			if (left >= tf.text.length) {
				return;
			}
			//存入删除命令链，max取最大值确保非选择区域删除时至少删除1个字符
			var text:String = tf.text.slice(left, Math.max(left + 1, right));
			commandList.addCommand(new DeleteCommand(tf, parser, left, right, text));
			//分析器进行分析高亮，再在选区末尾增加一个空格符，让内建的删除事件发生去删除它以防止删除出错
			tf.replaceText(left, left, " ");
			updateLineNum();
		}
		private function saveBackspace():void {
			//光标处于文本开头按backspace是无效的
			if (right <= 0) {
				return;
			}
			//存入删除命令链，max取最大值确保非选择区域删除时至少删除1个字符
			var text:String = tf.text.slice(Math.min(left, right - 1), right);
			//率先模拟删除功能，为分析器提供结果代码高亮的可能
			if (left == right) {
				commandList.addCommand(new BackSpaceCommand(tf, parser, left, text));
			}
			else {
				commandList.addCommand(new DeleteCommand(tf, parser, left, right, text));
			}
			//在选区末尾增加一个空格符，让内建的删除事件发生去删除它以防止删除出错
			tf.replaceText(left - 1, left - 1, " ");
			tf.setSelection(left, left);
			updateLineNum();
		}
		//始终将索引小值赋给left，防止鼠标从后向前选择
		private function getSelection():void {
			if (tf.selectionBeginIndex > tf.selectionEndIndex) {
				left = tf.selectionEndIndex;
				right = tf.selectionBeginIndex;
			}
			else if (tf.selectionBeginIndex < tf.selectionEndIndex) {
				left = tf.selectionBeginIndex;
				right = tf.selectionEndIndex;
			}
			else {
				left = right = tf.selectionBeginIndex;
			}
		}
		private function copyToClipboard(s:String):void {
			System.setClipboard(s.replace(/\r/g, "\n"));
		}
		
		private function textInputHandler(event:TextEvent):void {
			getSelection();
			event.text = event.text.replace(/\r/g, "").replace(/\n/g, "\r").replace(/\t/g, TAB);
			//索引不同为选择区域后输入替换
			if (left != right) {
				var source:String = tf.text.slice(left, right);
				commandList.addCommand(new ReplaceCommand(tf, parser, left, right, source, event.text));
			}
			else {
				commandList.addCommand(new InputCommand(tf, parser, left, event.text));
			}
			event.preventDefault();
			updateLineNum();
		}
		private function keyDownHandler(event:KeyboardEvent):void {
			getSelection();
			//tab键改写默认行为
			if (event.keyCode == Keyboard.TAB) {
				//如果鼠标为选择区域，为每行开头增加缩进
				if (left != right) {
					var startLine:int = tf.getLineIndexOfChar(left), endLine:int = tf.getLineIndexOfChar(right);
					commandList.addCommand(new MultiInputCommand(tf, parser, left, right, startLine, endLine));
				}
				//增加2个全角空格，增加输入命令链
				else {
					commandList.addCommand(new InputCommand(tf, parser, left, TAB));
				}
				focus();
			}
			//delete和backspace，截取默认行为并模拟改写
			else if (event.keyCode == Keyboard.DELETE) {
				saveDelete();
			}
			else if(event.keyCode == Keyboard.BACKSPACE) {
				saveBackspace();
			}
		}
		
		public function actionNew():void {
			//有内容时清空并保存命令链
			if (tf.text.length) {
				commandList.addCommand(new DeleteCommand(tf, parser, 0, tf.text.length, tf.text));
				msgBox.showMsg("已新建空白文件。");
			}
			else {
				msgBox.showAlert("当前文本为空，无需新建。");
			}
			focus();
		}
		public function actionOpen():void {
			if (so.data.code !== undefined) {
				//已有内容时要先保存删除命令
				if (tf.text.length) {
					commandList.addCommand(new DeleteCommand(tf, parser, 0, tf.text.length, tf.text));
				}
				commandList.addCommand(new InputCommand(tf, parser, 0, so.data.code));
				msgBox.showMsg("已读取内容。");
				vScrollBar.update();
				hScrollBar.update();
			}
			else {
				msgBox.showAlert("尚未保存，无法打开。");
			}
			focus();
		}
		public function actionSave():void {
			var res:String;
			so.data.code = tf.text;
			try {
				res = so.flush(tf.text.length * 2);
			}
			catch (error:Error) {
				msgBox.showAlert("请设置允许JAse向磁盘中写入内容，否则无法保存代码。");
				focus();
				return;
			}
			if (res == SharedObjectFlushStatus.PENDING) {
				msgBox.showAlert("请设置增大Flash Player读写本地的容量。");
			}
			else if (res == SharedObjectFlushStatus.FLUSHED) {
				msgBox.showMsg("保存成功。");
			}
			else {
				msgBox.showAlert("保存错误，请检查安全设置。");
			}
			focus();
		}
		public function actionUndo():void {
			//是否成功，显示相应信息
			if (commandList.undo()) {
				msgBox.showMsg("已撤销。");
				vScrollBar.update();
				hScrollBar.update();
			}
			else {
				msgBox.showAlert("已到达第一步，无法撤消。可保存最大步骤数目为 <b>" + UNDO_SIZE + "</b> 。");
			}
			focus();
		}
		public function actionRedo():void {
			//是否成功，显示相应信息
			if (commandList.redo()) {
				msgBox.showMsg("已重做。");
				vScrollBar.update();
				hScrollBar.update();
			}
			else {
				msgBox.showAlert("已到达最后一步，无法重做。可保存最大步骤数目为 <b>" + UNDO_SIZE + "</b> 。");
			}
			focus();
		}
		public function actionSelect():void {
			if (tf.text.length) {
				tf.setSelection(0, tf.text.length);
				msgBox.showMsg("已选择全部文字。");
			}
			else {
				msgBox.showAlert("没有内容。");
			}
			focus();
		}
		public function actionCut():void {
			getSelection();
			//有选区内容时才能剪切
			if (left != right) {
				var s:String = tf.text.slice(left, right);
				copyToClipboard(s);
				commandList.addCommand(new DeleteCommand(tf, parser, left, right, s));
				msgBox.showMsg("已剪切选区内容。");
				vScrollBar.update();
				hScrollBar.update();
			}
			else {
				msgBox.showAlert("请先选取要剪切的文本。");
			}
			focus();
		}
		public function actionCopy():void {
			getSelection();
			//有选区内容时才能复制
			if (left != right) {
				copyToClipboard(tf.text.slice(left, right));
				msgBox.showMsg("已复制选区内容。");
			}
			else {
				msgBox.showAlert("请先选取要复制的文本。");
			}
			focus();
		}
		public function actionPaste():void {
			msgBox.showAlert("因安全限制，无法读取系统剪贴板内容，请使用鼠标右键或者快捷键粘帖。");
			focus();
		}
		public function actionFormat():void {
			msgBox.showAlert("暂不支持。");
			focus();
		}
		public function actionCheck():void {
			msgBox.showAlert("暂不支持。");
			focus();
		}
		
		public function getContent():String {
			return tf.text;
		}
		public function setParser(parser:IParser):void {
			this.parser = parser;
			commandList = new CommandList();
			//加载完成后如果默认有内容，更新
			if (tf.text.length > 0) {
				parser.add(tf, 0, tf.text);
			}
			msgBox.showMsg("初始化完毕，欢迎使用 <b>JAse</b> 编辑器。");
			vScrollBar.update();
			hScrollBar.update();
		}
	}

}