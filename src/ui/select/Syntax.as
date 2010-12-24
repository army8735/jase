package ui.select {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.text.*;
	
	public class Syntax extends Sprite {
		static const W:int = 32, H:int = 24;
		
		public function Syntax(ss:SyntaxSelector, url:String, colors:Array, size:int = 14):void {
			alpha = 0.8;
			
			initView(url, size);
			initBg(colors);
			initBorder();
			
			addEventListener(MouseEvent.ROLL_OVER, function() {
				alpha = 1;
			});
			addEventListener(MouseEvent.ROLL_OUT, function() {
				alpha = 0.8;
			});
			addEventListener(MouseEvent.CLICK, function() {
				ss.load(url);
			});
		}
		
		private function initBg(colors:Array):void {
			var bg:Sprite = new Sprite();
			bg.graphics.beginGradientFill(GradientType.RADIAL, colors, [1, 1], [0, 255]);
			bg.graphics.drawRect(0, 0, 100, 100);
			bg.graphics.endFill();
			bg.width = W;
			bg.height = H;
			bg.x = bg.y = 1;
			addChildAt(bg, 0);
		}
		private function initBorder(color:uint = 0):void {
			graphics.lineStyle(1, color);
			graphics.moveTo(1, 0);
			graphics.lineTo(W, 0);
			graphics.lineTo(W + 1, 1);
			graphics.lineTo(W + 1, H + 1);
			graphics.moveTo(W + 1, H + 1);
			graphics.lineTo(1, H + 1);
			graphics.lineTo(0, H);
			graphics.lineTo(0, 1);
		}
		private function initView(s:String, size:int):void {
			var tf:TextField = getChildAt(0) as TextField;
			tf.filters = [new DropShadowFilter(1, 45, 0, 1, 0, 0), new DropShadowFilter(1, 45, 0xFFFFFF, 1, 3, 3)];
			tf.text = s;
			var format:TextFormat = tf.getTextFormat(0, 1);
			format.size = size;
			tf.setTextFormat(format, 0, s.length);
			tf.height = tf.textHeight;
			tf.y = (H - tf.height) * 0.5 - 1;
		}
	}

}