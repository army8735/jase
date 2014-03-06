package {
	/**
	 * ...
	 * @author army8735
	 * @version 1.0 alpha
	 * @link http://code.google.com/p/jase/
	 * @email army8735@gmail.com
	 * @date 2010-06-21
	 */
//test
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import js.*;
	import toolbar.*;
	import edit.*;
	import ui.msg.*;
	import ui.bord.*;
	import ui.intro.*;
	import ui.select.*;
	import util.*;
	
	public class Main extends Sprite {
		public static const PADDING:int = 5;
		
		private var toolBar:ToolBar;
		private var editor:Editor;
		private var introBlock:IntroBlock;
		private var msgBox:MsgBox;
		private var border:Border;
		private var submit:Submit;
		private var eventAssigner:EventAssigner;
		
		public function Main():void {
			//舞台不缩放，左上角对齐并禁用右键菜单
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			//获取参数
			var params:Object = root.loaderInfo.parameters;
			addEventListener(Event.ADDED_TO_STAGE, function() {
				init(params.target || "", params.swf || "jase1", params.js || "jase", params.url || "", params.syntax || null, params.prefix || "", params.version || "");
			});
		}
		
		private function init(target:String, swf:String, js:String, url:String, syntax:String, prefix:String, version:String):void {
			var syntaxSelector:SyntaxSelector;
			
			if (ExternalInterface.available) {
				//调用js方法默认js注册变量名"jase"
				ExternalInterface.call(CallJs.INIT, target, swf, js);
				var code:String = ExternalInterface.call(js + ".init");
				
				//宽高限制
				var w:int = getLimitWidth(stage.stageWidth);
				var h:int = getLimitHeight(stage.stageHeight);
				
				toolBar = new ToolBar(w);
				msgBox = new MsgBox(h);
				editor = new Editor(w, h, toolBar.height, msgBox, code || "");
				introBlock = new IntroBlock(w);
				border = new Border(w, h);
				syntaxSelector = new SyntaxSelector(this, editor, w, h, syntax, prefix, version);
				submit = new Submit(editor, msgBox, url);
				eventAssigner = new EventAssigner(editor, introBlock, submit);
				
				addChild(toolBar);
				addChild(editor);
				addChild(introBlock);
				addChild(msgBox);
				addChild(border);
				addChild(syntaxSelector);
				
				//注册侦听窗口改变大小
				stage.addEventListener(Event.RESIZE, function():void {
					w = getLimitWidth(stage.stageWidth);
					h = getLimitHeight(stage.stageHeight);
					//通知全部重定位
					toolBar.reLayout(w);
					editor.reLayout(w, h, toolBar.height);
					introBlock.setContainerWidth(w);
					msgBox.reLayout(h);
					border.reLayout(w, h);
					//防止syntaxSelector被移除后多余计算
					if (syntaxSelector && syntaxSelector.visible) {
						syntaxSelector.reLayout(w, h);
					}
				});
			}
		}
		private function getLimitWidth(w:int):int {
			return Math.max(w, 400);
		}
		private function getLimitHeight(h:int):int {
			return Math.max(h, 300);
		}
	}
	
}