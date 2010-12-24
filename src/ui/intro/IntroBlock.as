package ui.intro {
	import flash.display.Sprite;
	import flash.text.TextField;
	
	public class IntroBlock extends Sprite {
		private var tf:TextField;
		private var angle:Angle;
		private var w:int;
		
		public function IntroBlock(w:int):void {
			visible = false;
			this.w = w;
			
			angle = new Angle();
			addChild(angle);
			
			initView();
		}
		
		private function initView():void {
			tf = getChildAt(0) as TextField;
			tf.x = 1;
			tf.y = 5;
			tf.borderColor = 0xfff996;
			tf.background = true;
			tf.backgroundColor = 0xfcf9c4;
		}
		
		public function show(s:String, x:int, y:int):void {
			tf.text = s;
			tf.width = tf.textWidth + 4;
			
			graphics.clear();
			graphics.lineStyle(1, 0xe1cb65);
			graphics.moveTo(5, tf.y - 1);
			graphics.lineTo(tf.width - 2, tf.y - 1);
			graphics.moveTo(tf.width + 2, tf.y);
			graphics.lineTo(tf.width + 2, tf.y + tf.height);
			graphics.lineTo(tf.width + 2, tf.y + tf.height + 1);
			graphics.lineTo(1, tf.y + tf.height + 1);
			graphics.lineTo(0, tf.y + tf.height);
			graphics.lineTo(0, 5);
			graphics.endFill();
			
			move(x, y);
			angle.visible = true;
		}
		public function move(x:int, y:int):void {
			this.x = x + 15;
			angle.show(tf.width);
			//靠右时
			if (this.x + tf.width + 2 > w) {
				this.x = x - width - 10;
				angle.show(width, false);
			}
			this.y = y + 12;
			visible = true;
		}
		public function hide():void {
			visible = false;
			angle.visible = false;
		}
		public function setContainerWidth(w:int):void {
			this.w = w;
		}
	}

}