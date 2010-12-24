package util {
	import flash.events.*;
	import flash.net.*;
	import flash.external.*;
	import edit.*;
	import ui.intro.*;
	import toolbar.*;

	public class EventAssigner {
		static const dispatcher:EventDispatcher = new EventDispatcher();

		private var editor:Editor;
		private var introBlock:IntroBlock;
		private var submit:Submit;

		static var intro:String;
		static var mx:int, my:int;

		public function EventAssigner(editor:Editor, introBlock:IntroBlock, submit:Submit):void {
			this.editor = editor;
			this.introBlock = introBlock;
			this.submit = submit;

			initListener();
		}

		private function initListener():void {
			dispatcher.addEventListener(Button.OVER_INTRO, onOverHandler);
			dispatcher.addEventListener(Button.MOVE_INTRO, onMoveHandler);
			dispatcher.addEventListener(Button.OUT_INTRO, onOutHandler);

			dispatcher.addEventListener(Button.BUTTON_NEW, onNewHandler);
			dispatcher.addEventListener(Button.BUTTON_OPEN, onOpenHandler);
			dispatcher.addEventListener(Button.BUTTON_SAVE, onSaveHandler);
			dispatcher.addEventListener(Button.BUTTON_UNDO, onUndoHandler);
			dispatcher.addEventListener(Button.BUTTON_REDO, onRedoHandler);
			dispatcher.addEventListener(Button.BUTTON_SELECT, onSelectHandler);
			dispatcher.addEventListener(Button.BUTTON_CUT, onCutHandler);
			dispatcher.addEventListener(Button.BUTTON_COPY, onCopyHandler);
			dispatcher.addEventListener(Button.BUTTON_PASTE, onPasteHandler);
			dispatcher.addEventListener(Button.BUTTON_FORMAT, onFormatHandler);
			dispatcher.addEventListener(Button.BUTTON_CHECK, onCheckHandler);
			dispatcher.addEventListener(Button.BUTTON_SUBMIT, onSubmitHandler);
			dispatcher.addEventListener(Button.BUTTON_HOME, onHomeHandler);
			dispatcher.addEventListener(Button.BUTTON_ABOUT, onAboutHandler);
		}
		private function onOverHandler(event:Event):void {
			introBlock.show(intro, mx, my);
		}
		private function onMoveHandler(event:Event):void {
			introBlock.move(mx, my);
		}
		private function onOutHandler(event:Event):void {
			introBlock.hide();
		}
		private function onNewHandler(event:Event):void {
			editor.actionNew();
		}
		private function onOpenHandler(event:Event):void {
			editor.actionOpen();
		}
		private function onSaveHandler(event:Event):void {
			editor.actionSave();
		}
		private function onUndoHandler(event:Event):void {
			editor.actionUndo();
		}
		private function onRedoHandler(event:Event):void {
			editor.actionRedo();
		}
		private function onSelectHandler(event:Event):void {
			editor.actionSelect();
		}
		private function onCutHandler(event:Event):void {
			editor.actionCut();
		}
		private function onCopyHandler(event:Event):void {
			editor.actionCopy();
		}
		private function onPasteHandler(event:Event):void {
			editor.actionPaste();
		}
		private function onFormatHandler(event:Event):void {
			editor.actionFormat();
		}
		private function onCheckHandler(event:Event):void {
			editor.actionCheck();
		}
		private function onSubmitHandler(event:Event):void {
			submit.submit();
		}
		private function onHomeHandler(event:Event):void {
			navigateToURL(new URLRequest("http://code.google.com/p/jase/"), "_blank");
		}
		private function onAboutHandler(event:Event):void {
			if (ExternalInterface.available) {
				ExternalInterface.call("alert", "Project: JAse\uff08\u7532\u8272\uff09 ver 1.0 preview\\nAuthor: army8735\\nEmail: army8735@gmail.com\\nLicense: GNU Lesser General Public License");
			}
		}

		//按钮介绍
		public static function dispatchOver(s:String, x:int, y:int):void {
			intro = s;
			mx = x;
			my = y;
			dispatcher.dispatchEvent(new Event(Button.OVER_INTRO));
		}
		public static function dispatchMove(x:int, y:int):void {
			mx = x;
			my = y;
			dispatcher.dispatchEvent(new Event(Button.MOVE_INTRO));
		}
		public static function dispatchOut():void {
			dispatcher.dispatchEvent(new Event(Button.OUT_INTRO));
		}
		public static function dispatch(type:String):void {
			dispatcher.dispatchEvent(new Event(type));
		}
	}

}