function(target, swf, js) {
	function $(id) {
		return document.getElementById(id);
	}
	function getSwf(sName) {
		if (navigator.appName.indexOf("Microsoft") != -1)
			return window[sName];
		else
			return document[sName];
	}
	var oTextArea;
	var oSwf;
	var jase = {
		init: function() {
			oTextArea = $(target) || document.getElementsByTagName("textarea")[0];
			oSwf = getSwf(swf);
			//隐藏textarea
			if(oTextArea) {
				oTextArea.style.visibility = "hidden";
				oTextArea.style.position = "absolute";
			}
			var code = oTextArea.textContent || oTextArea.innerText;
			//防止textarea里没有内容报错
			if(!code && oTextArea.firstChild) {
				code = oTextArea.firstChild.nodeValue || "";
			}
			return code;
		},
		submit: function(code) {
			oTextArea.value = code;
			var oParnetNode = oTextArea.parentNode;
			while(oParnetNode) {
				if(oParnetNode.tagName && oParnetNode.tagName.toLowerCase() == "form") {
					oParnetNode.submit();
					return;
				}
				oParnet = oParent.parentNode;
			}
		}
	}
	//注册window顶级变量，默认jase
	window[js] = jase;
}