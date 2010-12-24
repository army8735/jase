package js {

	public class CallJs {
		
		public static const INIT:String = 'function(E,G,C){function B($){return document.getElementById($)}function _($){if(navigator.appName.indexOf("Microsoft")!=-1)return window[$];else return document[$]}function H(){if($)$.resize(A.clientWidth,A.clientHeight)}var F,A,$,D={init:function(){F=B(E)||document.getElementsByTagName("textarea")[0];$=_(G);var A,D;if(F){if(!A){A=F.clientWidth;D=F.clientHeight}F.style.visibility="hidden";F.style.position="absolute"}var C=F.textContent||F.innerText;if(!C&&F.firstChild)C=F.firstChild.nodeValue||"";return C},submit:function(_){F.value=_;var $=F.parentNode;while($){if($.tagName&&$.tagName.toLowerCase()=="form"){$.submit();return}oParnet=oParent.parentNode}}};window[C]=D}';
		
	}

}