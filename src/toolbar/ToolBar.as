package toolbar {
	import flash.display.*;
	import flash.events.*;
	import toolbar.other.*;
	import toolbar.system.*;
	import toolbar.record.*;
	import toolbar.operate.*;
	import toolbar.feature.*;
	import toolbar.core.*;
	
	public class ToolBar extends Sprite {
		
		public function ToolBar(w:int):void {
			init();
			reLayout(w);
		}
		
		private function init():void {			
			var systemGroup:ButtonGroup = new ButtonGroup();
			systemGroup.addButton(new New());
			systemGroup.addButton(new Open());
			systemGroup.addButton(new Save());
			addChild(systemGroup);
			
			var recordGroup:ButtonGroup = new ButtonGroup();
			recordGroup.addButton(new Undo());
			recordGroup.addButton(new Redo());
			addChild(recordGroup);
			
			var operateGroup:ButtonGroup = new ButtonGroup();
			operateGroup.addButton(new Select());
			operateGroup.addButton(new Cut());
			operateGroup.addButton(new Copy());
			operateGroup.addButton(new Paste());
			addChild(operateGroup);
			
			var fetureGroup:ButtonGroup = new ButtonGroup();
			fetureGroup.addButton(new Format());
			fetureGroup.addButton(new Check());
			addChild(fetureGroup);
			
			var coreGroup:ButtonGroup = new ButtonGroup();
			coreGroup.addButton(new Submit());
			addChild(coreGroup);
			
			var otherGroup:ButtonGroup = new ButtonGroup();
			otherGroup.addButton(new Home());
			otherGroup.addButton(new About());
			addChild(otherGroup);
		}
		
		public function reLayout(w:int):void {
			var left:int = Main.PADDING, top:int = Main.PADDING;
			for (var i:int = 0; i < numChildren - 1; i++) {
				var group:ButtonGroup = getChildAt(i) as ButtonGroup;
				//每行第一个按钮组
				if (left == Main.PADDING) {
					group.x = left;
					group.y = top;
					left += group.width + 1;
				}
				//超过宽度换行
				else if (left + group.width > w - Main.PADDING) {
					top += group.height;
					group.x = Main.PADDING;
					group.y = top;
					left = group.width + 1;
				}
				else {
					group.x = left;
					group.y = top;
					left += group.width + 1;
				}
			}
			//关于信息等右对齐
			var otherGroup:ButtonGroup = getChildAt(numChildren - 1) as ButtonGroup;
			if (left + otherGroup.width > w - Main.PADDING) {
				top += otherGroup.height;
				otherGroup.x = Main.PADDING;
			}
			else {
				otherGroup.x = w - Main.PADDING - otherGroup.width;
			}
			otherGroup.y = top;
		}
	}

}