var everAlarm = function() {

	var openAlarm = function(alarmName, message){

		$(".ui-pnotify."+alarmName).html('');

		var alarmCloseFunction = "everAlarm.alarmClick('"+alarmName+"');";
		message = '<span class="alarmMessage" onclick="'+alarmCloseFunction+'">'+message+'</span>';

		$(document.body).append($('<span id="alarmMessage">'+message.replace(/\n/gi, '<br/>')+'</span>'));

		var typeVal = '';
		switch (alarmName) {
			case 'approvalRequestAlarm'	: typeVal = '#67A5D8'; break;
			case 'noticeAlarm'			: typeVal = '#00DE62'; break;
			case 'approvedRFQAlarm'		: typeVal = '#FAAB4E';	break;
			case 'letterAlarm'			: typeVal = '#00FF62'; break;
		}

		var time = 1000 * 60 * 24; // 24시간
		var pnotify = new PNotify({
			title: "알림",
			text: message,
			sticker: false,
			icon: 'ui-icon ui-icon-mail-closed',
			before_close: function(pnotify) {
				pnotify.remove(0);
			},
			/*addclass: alarmName,*/
			width: ($('#alarmMessage').width()+50)+'px',
			delay: time
		});

		$('#alarmMessage').remove(0);

		$('.ui-pnotify').click(function() {
			pnotify.remove(0);
		});
	};

	var isMyMessage = function(userType, receiverList){
		var clientUser = null;
		if(userType == 'USER'){ clientUser = everAlarm.clientUserId; }
		if (userType == 'COMPANY'){ clientUser = everAlarm.clientCompanyCode; }

		switch(userType){
			case 'ALL': return true;
			case 'BUYER': return everAlarm.clientUserType === 'B';
			case 'SUPPLIER': return everAlarm.clientUserType === 'S';
			case 'USER':
			case 'COMPANY':
				for(var x in receiverList){
					if(receiverList[x] === clientUser) {
						return true;
					}
				}
				return false;
			default: throw ('unknown type ' + userType);
		}
	};
	return {
		init : function(userType, clientUserId, clientCompanyCode){
			everAlarm.clientUserId = clientUserId;
			// var everAlarmclientCompanyCode = clientCompanyCode;
		},
		alarmCallBack : function(alarmName, userType, dataString, message, receiverListString) {

			//console.log('alarmName: ' + alarmName);
			//console.log('userType:' + userType);
			//console.log('dataString:' + dataString);
			//console.log('message:' + message);
			//console.log('receiverListString:' + receiverListString);

			var data = JSON.parse(dataString);
			var receiverList = JSON.parse(receiverListString);

			if(isMyMessage(userType, receiverList) === false){
				return;
			}

			switch (alarmName) {
				case 'approvalRequestAlarm': openAlarm(alarmName, message); break;
				case 'noticeAlarm': everAlarm.noticeParam=data; openAlarm(alarmName, message); break;
				case 'approvedRFQAlarm': openAlarm(alarmName, message); break;
				case 'letterAlarm': openAlarm(alarmName, message); break;
				default:throw ('unknown Alarm' + alarmName);
			}
		}, alarmClick : function(alarmName, data) {
			everAlarm.closeAlarm(alarmName);

			switch (alarmName) {
				case 'noticeAlarm':
					var param = {
						NOTICE_NUM : everAlarm.noticeParam.NOTICE_NUM
						,POPUPFLAG   : "Y"
						,READONLY    : "Y"
					};

					everPopup.openPopupByScreenId('BBON_010', 950, 580, param);
					break;
				case 'approvedRFQAlarm': break;
				case 'letterAlarm': break;
				default: throw ('un known Alarm' + alarmName);
			}
		}
		, closeAlarm : function(alarmName) {
			$(".ui-pnotify."+alarmName).html('');
		}
	};
}();
