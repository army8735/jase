package util {

	public class HashMap {
		private var hash:Object;
		private var index:int;
		
		public function HashMap(datas:Array = null):void {
			hash = new Object();
			index = 0;
			
			if (datas != null) {
				for (var i:int = 0; i < datas.length; i++) {
					put(datas[i]);
				}
			}
		}
		
		public function put(key:String):void {
			hash[key] = true;
			index++;
		}
		public function hasKey(key:String):Boolean {
			return hash[key] == true;
		}
		public function size():int {
			return index;
		}
	}

}