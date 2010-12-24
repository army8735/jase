package util {
	
	public class Character {
		
		public static const UNDER_LINE:int = 95;
		public static const SLASH:int = 47;
		public static const BACK_SLASH:int = 92;
		public static const STAR:int = 42;
		public static const SINGLE_QUOTE:int = 39;
		public static const DOUBLE_QUOTE:int = 34;
		public static const SPACE:int = 32;
		public static const TAB:int = 9;
		public static const ENTER:int = 13;
		public static const LINE:int = 10;
		public static const DOLLAR:int = 36;
		public static const EXCLAMATION:int = 33;
		public static const COLON:int = 58;
		public static const SEMICOLON:int = 59;
		public static const DECIMAL:int = 46;
		public static const SHARP:int = 35;
		public static const QUESTION:int = 63;
		public static const PERCENT:int = 37;
		public static const AT:int = 64;
		public static const ZERO:int = 48;
		public static const ADD:int = 43;
		public static const MINUS:int = 45;
		public static const LEFT_PARENTHESE:int = 40;
		public static const RIGHT_PARENTHESE:int = 41;
		public static const LEFT_BRACKET:int = 91;
		public static const RIGHT_BRACKET:int = 93;
		public static const LEFT_BRACE:int = 123;
		public static const RIGHT_BRACE:int = 125;
		public static const LEFT_ANGLE_BRACKET:int = 60;
		public static const RIGHT_ANGLE_BRACKET:int = 62;
		
		public static function isDigit(charCode:int):Boolean {
			return charCode > 47 && charCode < 58;
		}
		public static function isDigit16(charCode:int):Boolean {
			return isDigit(charCode) || (charCode > 96 && charCode < 103) || (charCode > 64 && charCode < 71);
		}
		public static function isLetter(charCode:int):Boolean {
			return (charCode > 96 && charCode < 123) || (charCode > 64 && charCode < 91);
		}
		public static function isLetterOrDigit(charCode:int):Boolean {
			return isLetter(charCode) || isDigit(charCode);
		}
		public static function isLong(charCode:int):Boolean {
			return charCode == 76 || charCode == 108;
		}
		public static function isFloat(charCode:int):Boolean {
			return charCode == 100 || charCode == 68 || charCode == 102 || charCode == 70;
		}
		public static function isX(charCode:int):Boolean {
			return charCode == 120 || charCode == 88;
		}
		public static function isB(charCode:int):Boolean {
			return charCode == 98 || charCode == 66;
		}
		public static function isBlank(charCode:int):Boolean {
			return charCode == SPACE || charCode == TAB || charCode == 12288;
		}
		public static function isExponent(charCode:int):Boolean {
			return charCode == 69 || charCode == 101;
		}
		public static function isLEFT_BRACE(charCode:int):Boolean {
			return charCode == LEFT_BRACE;
		}
		
	}
	
}