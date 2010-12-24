package toolbar {
	import flash.display.Sprite;
	
	public class ButtonGroup extends Sprite {
		private var index:int;
		
		public function ButtonGroup():void {
			index = 0;
			addChild(new Split());
		}
		public function addButton(button:Button):void {
			button.x = index++ * Button.W + 10;
			addChild(button);
		}
	}

}