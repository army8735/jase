package state {

	public class LineState {
		public static const NULL:int = 0;
		public static const NORMAL:int = 1;
		public static const BLANK:int = 2;
		public static const STRING:int = 3;
		public static const CHAR:int = 4;
		public static const SINGLE_COMMENT:int = 5;
		public static const MULTI_COMMENT:int = 6;
		public static const KEYWORD:int = 7;
		public static const NUMBER:int = 8;
		public static const PERL_REG:int = 9;
		
		private var states:Vector.<int>; //每行起始状态
		private var renders:Vector.<Boolean>; //每行是否已经被渲染
		private var depths:Vector.<int>; //每行起始深度
		private var blocks:Vector.<Vector.<BlockState>>; //每行里面的块数组
		
		public function LineState():void {
			states = new Vector.<int>();
			states.push(NORMAL);
			
			renders = new Vector.<Boolean>();
			
			depths = new Vector.<int>();
			depths.push(0);
			
			blocks = new Vector.<Vector.<BlockState>>();
		}
		
		public function getLineState(index:int):int {
			//超出长度返回空
			if (index >= states.length) {
				return NORMAL;
			}
			return states[index];
		}
		public function setLineState(index:int, value:int):void {
			states[index] = value;
		}
		public function addLineState(index:int, value:int):void {
			//已存在的情况下为插入
			if (index < states.length) {
				states.splice(index, 0, value);
			}
			else {
				states.push(value);
			}
		}
		public function getLineRender(index:int):Boolean {
			if (index >= renders.length) {
				return false;
			}
			return renders[index];
		}
		public function setLineRender(index:int, value:Boolean = false):void {
			renders[index] =  value;
		}
		public function getLineBlocks(index:int):Vector.<BlockState> {
			if (index >= blocks.length) {
				return new Vector.<BlockState>();
			}
			return blocks[index];
		}
		public function setLineBlocks(index:int):void {
			blocks[index] = new Vector.<BlockState>();
		}
		public function addLineBlocks(index:int):void {
			//已存在的情况下为插入
			if (index < blocks.length) {
				blocks.splice(index, 0, new Vector.<BlockState>());
			}
			else {
				blocks.push(new Vector.<BlockState>());
			}
		}
		public function addBlock(index:int, start:int, end:int, color:uint):void {
			if (end > 0) {
				blocks[index].push(new BlockState(start, end, color));
			}
		}
		public function del(index:int, length:int):void {
			if (index > 0 && length > 0) {
				states.splice(index, length);
				blocks.splice(index, length);
				renders.splice(index, length);
			}
		}
		public function size():int {
			return states.length;
		}
	}

}