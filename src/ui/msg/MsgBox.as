package ui.msg {
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.utils.*;
	
	public class MsgBox extends Sprite {
		private var tf:TextField;
		private var border:Sprite;
		private var timer:Timer;
		
		public function MsgBox(h:int):void {
			x = 1;
			
			tf = getChildAt(0) as TextField;
			tf.x = 1;
			tf.y = tf.height;
			tf.background = true;
			tf.filters = [new ColorMatrixFilter()];
			
			border = new Sprite();
			addChild(border);
			
			reLayout(h);
		}
		
		public function reLayout(h:int):void {
			y = h - tf.height;
		}
		public function showMsg(s:String):void {
			setMsg(s);
			tf.textColor = 0;
			initBg(0x55AAFF);
		}
		public function showAlert(s:String):void {
			setMsg(s);
			tf.textColor = 0xFFFFFF;
			initBg();
		}
		
		private function setMsg(s:String):void {
			tf.y = tf.height;
			border.alpha = tf.alpha = 0;
			tf.htmlText = s;
			tf.width = tf.textWidth + 30;
			
			removeEventListener(Event.ENTER_FRAME, onShowHandler);
			if (timer) {
				timer.stop();
			}
			removeEventListener(Event.ENTER_FRAME, onHideHandler);
			addEventListener(Event.ENTER_FRAME, onShowHandler);
		}
		private function onShowHandler(event:Event):void {
			border.y = tf.y -= 1;
			border.alpha = tf.alpha += 0.05;
			if (tf.y == -1) {
				removeEventListener(Event.ENTER_FRAME, onShowHandler);
				timer = new Timer(2000, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function() {
					addEventListener(Event.ENTER_FRAME, onHideHandler);
				});
				timer.start();
			}
		}
		private function onHideHandler(event:Event):void {
			border.y = tf.y += 1;
			border.alpha = tf.alpha -= 0.05;
			if (tf.y == tf.height) {
				removeEventListener(Event.ENTER_FRAME, onHideHandler);
				timer = null;
			}
		}
		private function initBg(color:uint = 0xFF2233):void {
			tf.backgroundColor = color;
			
			border.graphics.clear();
			border.graphics.lineStyle(1, color);
			border.graphics.moveTo(1, 0);
			border.graphics.lineTo(tf.width, 0);
			border.graphics.moveTo(tf.width + 1, 1);
			border.graphics.lineTo(tf.width + 1, tf.height - 1);
			border.graphics.moveTo(0, 1);
			border.graphics.lineTo(0, tf.height);
			border.graphics.endFill();
		}
	}

}