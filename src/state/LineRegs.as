package state {

	public class LineRegs {
		private var regs:Vector.<Boolean>;
		
		public function LineRegs():void {
			regs = new Vector.<Boolean>();
			regs.push(true);
		}
		
		public function getLineReg(index:int):Boolean {
			return regs[index];
		}
		public function setLineReg(index:int, value:Boolean):void {
			regs[index] = value;
		}
		public function addLineReg(index:int, value:Boolean):void {
			if (index < regs.length) {
				regs.splice(index, 0, value);
			}
			else {
				regs.push(value);
			}
		}
		public function del(index:int, length:int):void {
			while (length-- > 0) {
				if (index < regs.length) {
					regs.splice(index, 1);
				}
				else {
					break;
				}
			}
		}
	}

}