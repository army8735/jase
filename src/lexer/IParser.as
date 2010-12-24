package lexer {
	import flash.text.*;

	public interface IParser {
		function update(tf:TextField):void;
		function add(tf:TextField, begin:int, text:String):void;
		function del(tf:TextField, begin:int, text:String):void;
		function replace(tf:TextField, begin:int, source:String, text:String):void;
		function format(tf:TextField):void;
		function check(tf:TextField):void;
	}

}