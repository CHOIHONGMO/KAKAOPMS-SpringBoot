var data = new function() {};

data.ajax = function (url, param, callBack ) {

	var req = new XMLHttpRequest();

	req.open("post", url);
	req.setRequestHeader("Content-type","application/x-www-form-urlencoded");
	req.onload = function() {
		if ( req.status == "200" ) {
			callBack(jQuery.parseJSON(req.response));
		} else {
			popup.message("오류가 발생하였습니다.");
		}
	};

	req.send(param);
};

/**
 * parameter를 JSON형식으로도 받을 수 있는 Ajax 함수
 * @param url
 * @param param
 * @param callBack
 */
data.ajaxJson = function (url, param, callBack ) {
	$.post( url, param, callBack, "json" );
};

data.ajaxIE = function (url, param, callBack ) {
	$.ajax({
		url: url,
		type: "GET",
		dataType: "json",
		data:param,
		success:callBack
	});
};

data.getJSONtoRequestParam = function (JSONdata) {
	var paramUrl = new StringBuilder("");
	for (var id in JSONdata) {
		if ( id == "" || !id ) continue;
		paramUrl.append("&" + id + "=" + JSONdata[id]);
	}
	return paramUrl.toString();
};