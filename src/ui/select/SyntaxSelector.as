package ui.select {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.filters.*;
	import edit.*;
	import util.*;
	
	public class SyntaxSelector extends Sprite {
		private var main:Main;
		private var tf:TextField;
		private var syntaxContainer:Sprite;
		private var loading:Loading;
		
		public function SyntaxSelector(main:Main, editor:Editor, w:int, h:int, syntax:String, prefix:String, version:String):void {
			this.main = main;
			tf = getChildAt(0) as TextField;
			tf.filters = [new DropShadowFilter(2, 45, 0, 0.5, 4, 4)];
			
			syntaxContainer = new Sprite();
			syntaxContainer.addChild(new Syntax(this, "Txt", [0x777777, 0]));
			syntaxContainer.addChild(new Syntax(this, "As", [0xb55469, 0x5c050d]));
			syntaxContainer.addChild(new Syntax(this, "Js", [0xc53d8d, 0x6f1048]));
			syntaxContainer.addChild(new Syntax(this, "Html", [0x494bbe, 0x09055c], 12));
			syntaxContainer.addChild(new Syntax(this, "Css", [0xe00064, 0x89003d]));
			syntaxContainer.addChild(new Syntax(this, "Xml", [0x3479b5, 0x052e5c], 12));
			syntaxContainer.addChild(new Syntax(this, "Java", [0x8d44b5, 0x42055c], 12));
			addChild(syntaxContainer);
			
			//前缀url未以路径结尾
			if (prefix && prefix.length && prefix.charAt(prefix.length - 1) != "/") {
				prefix += "/";
			}
			
			loading = new Loading(this, editor, prefix, version);
			addChild(loading);
			reLayout(w, h);
			
			//默认指定了语法
			if (syntax && syntax.length) {
				load(syntax);
			}
		}
		
		public function reLayout(w:int, h:int):void {
			//不可见情况下无需重定位
			if (!visible) {
				return;
			}
			//背景和文本高宽
			tf.width = w;
			initBg(w, h);
			//存在且可见时才重定位
			if (syntaxContainer && syntaxContainer.visible) {
				var left:int = Main.PADDING, top:int = Main.PADDING, max:int = 0;
				//从左到右从上倒下依次排序
				for (var i:int = 0; i < syntaxContainer.numChildren; i++) {
					var item:Syntax = syntaxContainer.getChildAt(i) as Syntax;
					if (left + item.width > w - Main.PADDING) {
						item.x = Main.PADDING;
						left = item.width + Main.PADDING * 2;
						top += item.height + Main.PADDING;
					}
					else {
						item.x = left;
						left += item.width + Main.PADDING;
					}
					item.y = top;
					max = Math.max(max, left);
				}
				//排序好所有宽高
				top += item.height;
				max = (w - max) / 2;
				top = (h - top) / 2;
				tf.y = top - tf.height - Main.PADDING;
				//依次增加偏移值
				for (i = 0; i < syntaxContainer.numChildren; i++) {
					item = syntaxContainer.getChildAt(i) as Syntax;
					item.x += max;
					item.y += top;
				}
			}
			else if (loading && loading.visible) {
				tf.y = int(h * 0.5) - 10;
			}
			loading.reLayout(w, tf.y + tf.height + 10);
		}
		public function load(url:String):void {
			tf.text = "正在读取……";
			syntaxContainer.visible = false;
			loading.visible = true;
			loading.load(url);
		}
		public function hide():void {
			visible = false;
			main.removeChild(this);
		}
		public function error():void {
			tf.text = "加载失败，请确认解析器插件是否存在。";
			tf.textColor = 0xFF0000;
			loading.visible = false;
			var timer:Timer = new Timer(2000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function() {
				tf.text = "请重新选择编辑器的语言种类:";
				tf.textColor = 0xFF9933;
				syntaxContainer.visible = true;
				timer = null;
			});
			timer.start();
		}
		public function init():void {
			tf.text = "正在初始化编辑器……";
			tf.textColor = 0x3399FF;
		}
		
		private function initBg(w:int, h:int):void {
			graphics.clear();
			graphics.beginFill(0xFFFFFF, 0.8);
			graphics.drawRect(0, 0, w, h);
			graphics.endFill();
		}
	}

}