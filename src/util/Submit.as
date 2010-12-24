package util {
	import flash.events.*;
	import flash.net.*;
	import flash.external.*;
	import edit.*;
	import ui.msg.*;
	
	public class Submit {
		private var editor:Editor;
		private var msgBox:MsgBox;
		private var url:String;
		
		public function Submit(editor:Editor, msgBox:MsgBox, url:String) {
			this.editor = editor;
			this.msgBox = msgBox;
			this.url = url;
		}
		
		public function submit():void {
			var s:String = editor.getContent();
			//如果指定了提交url的地址，则使用urlLoader，否则尝试js提交方式
			if (url.length) {
				msgBox.showMsg("提交中……");
				var urlRequest:URLRequest = new URLRequest(url);
				var urlVariables:URLVariables = new URLVariables();
				urlVariables.data = s;
				urlRequest.data = urlVariables;
				urlRequest.method = URLRequestMethod.POST;
				var urlLoader:URLLoader = new URLLoader();
				urlLoader.addEventListener(Event.COMPLETE, function() {
					msgBox.showMsg("提交成功。");
				});
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function() {
					msgBox.showAlert("提交失败。");
				});
				urlLoader.load(urlRequest);
			}
			else if (ExternalInterface.available) {
				//注意external接口要转义双引号和转义号
				ExternalInterface.call("jase.submit", s.replace(/\"/g, '\\"').replace(/\\/g, "\\\\"));
			}
		}
	}

}