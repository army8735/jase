package state {

	public class BlockState {
		private var start:int, end:int;
		private var color:uint;
		
		public function BlockState(start:int, end:int, color:uint):void {
			this.start = Math.max(0, start);
			this.end = end;
			this.color = color;
		}
		
		public function getStart():int {
			return start;
		}
		public function getEnd():int {
			return end;
		}
		public function getColor():uint {
			return color;
		}
	}

}