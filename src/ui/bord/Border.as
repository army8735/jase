package ui.bord {
	import flash.display.Sprite;
	
	public class Border extends Sprite {
		
		public function Border(w:int, h:int):void {
			reLayout(w, h);
		}
		
		public function reLayout(w:int, h:int):void {
			graphics.clear();
			graphics.lineStyle(1, 0x333333);
			graphics.moveTo(1, 0);
			graphics.lineTo(w - 2, 0);
			graphics.lineTo(w - 1, 1);
			graphics.lineTo(w - 1, h - 1);
			graphics.moveTo(w - 1, h - 1);
			graphics.lineTo(1, h - 1);
			graphics.lineTo(0, h - 2);
			graphics.lineTo(0, 1);
			graphics.endFill();
		}
	}

}