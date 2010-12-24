package ui.intro {
	import flash.display.*;
	
	public class Angle extends MovieClip {
		
		public function Angle():void {
			stop();
		}
		
		public function show(width, left:Boolean = true):void {
			visible = true;
			graphics.clear();
			graphics.lineStyle(1, 0xe1cb65);
			//补全
			if (left) {
				x = 0;
				gotoAndStop(1);
				graphics.moveTo(width - 2, 4);
				graphics.lineTo(width + 2, 4);
				graphics.endFill();
			}
			else {
				x = width - this.width;
				gotoAndStop(2);
				graphics.moveTo(6 - width, 4);
				graphics.lineTo(10 - width, 4);
				graphics.endFill();
			}
		}
		public function hide():void {
			visible = false;
		}
	}

}