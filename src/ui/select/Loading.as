package ui.select {
	import flash.display.*;
	import flash.text.*;
	import flash.net.*;
	import flash.events.*;
	import edit.*;
	import lexer.*;
	
	public class Loading extends Sprite {
		private var percent:Sprite;
		private var myMask:Sprite;
		private var tf:TextField;
		
		private var ss:SyntaxSelector;
		private var editor:Editor;
		
		private var prefix:String;
		private var version:String;
		
		public function Loading(ss:SyntaxSelector, editor:Editor, prefix:String, version:String):void {
			visible = false;
			this.ss = ss;
			this.editor = editor;
			this.prefix = prefix;
			this.version = version;
			
			tf = getChildAt(0) as TextField;
			
			initBorder();
			initPercent();
			initMask();
		}
		
		private function initBorder():void {
			graphics.lineStyle(1);
			graphics.moveTo(1, 0);
			graphics.lineTo(300, 0);
			graphics.lineTo(301, 1);
			graphics.lineTo(301, 11);
			graphics.moveTo(301, 11);
			graphics.lineTo(1, 11);
			graphics.lineTo(0, 10);
			graphics.lineTo(0, 1);
		}
		private function initPercent():void {
			percent = new Sprite();
			percent.graphics.beginGradientFill(GradientType.LINEAR, [0x368aee, 0x2c3cff], [1, 1], [127, 255]);
			percent.graphics.drawRect(0, 1, 100, 10);
			percent.graphics.endFill();
			percent.x = 1;
			percent.width = 300;
			addChild(percent);
		}
		private function initMask():void {
			myMask = new Sprite();
			myMask.graphics.beginFill(0);
			myMask.graphics.drawRect(0, 0, 300, 10);
			myMask.graphics.endFill();
			myMask.x = myMask.y = 1;
			myMask.scaleX = 0;
			percent.mask = myMask;
			addChild(myMask);
		}
		
		public function reLayout(w:int, y:int):void {
			x = int(w * 0.5) - 160;
			this.y = y;
		}
		public function load(url:String):void {
			var loader:Loader = new Loader();
			var p:Number;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function() {
				myMask.scaleX = 1;
				tf.text = "100%";
				ss.init();
				//编辑器初始化完毕后才能设置解析器
				addEventListener(Event.ENTER_FRAME, function(event:Event):void {
					if (editor.hasInit()) {
						editor.setParser(loader.content as IParser);
						ss.hide();
						loader = null;
						removeEventListener(Event.ENTER_FRAME, arguments.callee);
					}
				});
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function() {
				ss.error();
			});
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
				p = event.bytesLoaded / event.bytesTotal;
				myMask.scaleX = p;
				tf.text = int(p * 100) + "%";
			});
			//加载，注意前缀和版本号
			var s:String = prefix + url.toLocaleLowerCase() + ".swf";
			if (version && version.length) {
				s += "?version=" + version;
			}
			loader.load(new URLRequest(s));
		}
	}

}