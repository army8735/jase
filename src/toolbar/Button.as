package toolbar {
	import flash.display.*;
	import flash.events.*;
	import util.*;
	
	public class Button extends Sprite {
		public static const W:int = 20;
		public static const H:int = 20;
		
		public static const OVER_INTRO:String = "over";
		public static const MOVE_INTRO:String = "move";
		public static const OUT_INTRO:String = "out";
		
		public static const BUTTON_FORMAT:String = "代码格式化";
		public static const BUTTON_CHECK:String = "语法检查";
		public static const BUTTON_SUBMIT:String = "提交";
		public static const BUTTON_SELECT:String = "全选";
		public static const BUTTON_CUT:String = "剪切";
		public static const BUTTON_COPY:String = "复制";
		public static const BUTTON_PASTE:String = "粘贴";
		public static const BUTTON_HOME:String = "项目主页";
		public static const BUTTON_ABOUT:String = "关于";
		public static const BUTTON_UNDO:String = "撤销";
		public static const BUTTON_REDO:String = "重做";
		public static const BUTTON_NEW:String = "新建";
		public static const BUTTON_OPEN:String = "打开";
		public static const BUTTON_SAVE:String = "保存";
		
		public function Button(intro:String):void	{
			buttonMode = true;
			
			var border:Sprite = new Sprite();
			border.graphics.lineStyle(1, 0xFF3333);
			border.graphics.moveTo(1, 0);
			border.graphics.lineTo(W - 2, 0);
			border.graphics.lineTo(W - 1, 1);
			border.graphics.lineTo(W - 1, H - 1);
			border.graphics.moveTo(W - 1, H - 1);
			border.graphics.lineTo(1, H - 1);
			border.graphics.lineTo(0, H - 2);
			border.graphics.lineTo(0, 1);
			border.graphics.endFill();
			border.visible = false;
			addChild(border);
			
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0xFF3300, 0.3);
			bg.graphics.drawRect(0, 1, W - 1, H - 2);
			bg.graphics.endFill();
			bg.visible = false;
			addChildAt(bg, 0);
			
			addEventListener(MouseEvent.ROLL_OVER, function(event:MouseEvent):void {
				border.visible = true;
				EventAssigner.dispatchOver(intro, event.stageX, event.stageY);
			});
			addEventListener(MouseEvent.ROLL_OUT, function(event:MouseEvent):void {
				border.visible = false;
				bg.visible = false;
				EventAssigner.dispatchOut();
			});
			addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
				EventAssigner.dispatchMove(event.stageX, event.stageY);
			});
			addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
				bg.visible = true;
			});
			addEventListener(MouseEvent.MOUSE_UP, function() {
				bg.visible = false;
				EventAssigner.dispatch(intro);
			});
		}
	}

}