<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">

	<script>

    var baseUrl = "/eversrm/basic/message/";
    var gridMsg;
    var gridSms;

    var cRow;
    var currentUserId = '';
    var tagObj = {};

    function init() {
        gridSms = EVF.C("gridSms");
        gridMsg = EVF.C("gridMsg");

        gridSms.setProperty("shrinkToFit", true);        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
        gridMsg.setProperty("shrinkToFit", true);        // 컬럼의 너비를 그리드의 너비만큼 비율적으로 늘려서 맞춘다. [true/false]
		
        gridSms.addRowEvent(function () {
        	gridSms.addRow();
		});
        
        gridSms.delRowEvent(function () {
        	gridSms.delRow();
		});
		
        gridMsg.addRowEvent(function () {
        	gridMsg.addRow();
		});
        
        gridMsg.delRowEvent(function () {
        	gridMsg.delRow();
		});

		if('${param.usrList}' !='' && '${param.usrList}' !='null') {
			var userList = JSON.parse('${param.usrList}');

			userList.forEach(
				function(data,idex){
		            var addParam = [{"RECV_USER_ID": data.USER_ID, "RECV_USER_NM": data.USER_NM, "RECV_TEL_NUM": data.CELL_NUM,"RECV_EMAIL": data.EMAIL, "VENDOR_CD": data.COMPANY_CD }];
		            gridMsg.addRow(addParam);
		            gridSms.addRow(addParam);
				}
			);

		}
    }

    $(document.body).ready(function() {
    	$('#e-tabs').height( ($('.ui-layout-center').height()-30) ).tabs(
			{
                activate: function(event, ui) {
                    <%-- 이 부분을 해줘야 탭을 변경했을 때 그리드가 제대로 display 된다. --%>
                    $(window).trigger('resize');
                }
            }
    	);
		$('#e-tabs').tabs('option', 'active', 0);
		getContentTab('1');
	});

    function getContentTab(uu) {
		if (uu == '1') {
			window.scrollbars = true;
		}
		if (uu == '2') {
			window.scrollbars = true;
		}
	}

    function reset1() {
    	EVF.C('RECIPIENT').setValue('');
    	EVF.C('TFT_MEMBER').setValue('');
    	EVF.C('CAPTION_SMS').setValue('');
        gridSms.delAllRow();
    }
    
    function reset2() {
    	EVF.C('RECIPIENT2').setValue('');
    	EVF.C('TFT_MEMBER2').setValue('');
    	EVF.C('SUBJECT').setValue('');
    	EVF.C('CAPTION_MSG').setValue('');
        gridMsg.delAllRow();
    }

    function searchUsers1() {
        var param = {
              callBackFunction: "setUserids1",
              USER_IDS: EVF.C("TFT_MEMBER").getValue(),  //'94034283,99026729,99026638'
              detailView: false
        };
        everPopup.openPopupByScreenId('userMultiSearch', 1200, 620, param);
    }

    function setUserids1(data) {

        var kkk   = '';
        var names = '';
        for (var k = 0; k < data.length; k++) {
            if (k == 0) {
                kkk += data[k].USER_ID_$TP;
                names += data[k].USER_NM;
            } else {
                kkk += ',' + data[k].USER_ID_$TP;
                names += ',' + data[k].USER_NM;
            }

            //sms발송대상 히든 그리드에추가
            var addParam = [{"RECV_USER_ID": data[k].USER_ID, "RECV_USER_NM": data[k].USER_NM, "RECV_TEL_NUM": data[k].CELL_NUM, "VENDOR_CD": data[k].COMPANY_CD }];
            gridSms.addRow(addParam);
        }

        EVF.C("TFT_MEMBER").setValue(kkk);
        EVF.C("RECIPIENT").setValue(names);
    }

    function searchUsers2() {
        var param = {
            callBackFunction: "setUserids2",
            USER_IDS: EVF.C("TFT_MEMBER").getValue(),
            detailView: false
        };
        everPopup.openPopupByScreenId('userMultiSearch', 1200, 620, param);
    }

    function setUserids2(data) {

        var kkk   = '';
        var names = '';
        for (var k = 0; k < data.length; k++) {
            if (k == 0) {
                kkk += data[k].USER_ID_$TP;
                names += data[k].USER_NM;
            } else {
                kkk += ',' + data[k].USER_ID_$TP;
                names += ',' + data[k].USER_NM;
            }

            //sms발송대상 히든 그리드에추가
            var addParam = [{"RECV_USER_ID": data[k].USER_ID, "RECV_USER_NM": data[k].USER_NM, "RECV_EMAIL": data[k].EMAIL, "VENDOR_CD": data[k].COMPANY_CD }];
            gridMsg.addRow(addParam);
        }

        EVF.C("TFT_MEMBER2").setValue(kkk);
        EVF.C("RECIPIENT2").setValue(names);
    }

	// SMS 발송
    function send1() {

    	/* if (EVF.C("RECIPIENT").getValue() == '' || EVF.C("CAPTION_SMS").getValue() == '') {
    		alert('${BSN_040_0001 }');
    		return;
    	} */

        var store = new EVF.Store();
    	if (!confirm("${msg.M0060 }")) return;

        store.setGrid([gridSms]);
        store.getGridData(gridSms, 'all');
        store.load(baseUrl + 'BSN_040/doSendSms', function() {
        	alert(this.getResponseMessage());
        	reset1();
        });
    }

	// EMail 발송
    function send2() {
    	
		/* if (EVF.C("SUBJECT").getValue() == '' || EVF.C("RECIPIENT2").getValue() == '' || EVF.C("CAPTION_MSG").getValue() == '') {
	   		alert('${BSN_040_0002 }');
	   		return;
   		} */

        var store = new EVF.Store();
    	if (!confirm("${msg.M0060 }")) return;

        store.setGrid([gridMsg]);
        store.getGridData(gridMsg, 'all');
    	store.doFileUpload(function() {
	        store.load(baseUrl + 'BSN_040/doSendMsg', function() {
	        	alert(this.getResponseMessage());
	        	reset2()
	        });
    	});
    }

	</script>

	<e:window id="BSN_040" onReady="init" initData="${initData}" width="100%" height="100%" name="${fullScreenName}" title="${fullScreenName}">

	<e:panel id="pnl2" width="100%">
		<div id="e-tabs" class="e-tabs">
	        <ul>
	        	<li><a href="#ui-tabs-1" onclick="getContentTab('1');">SMS</a></li>
	        	<li><a href="#ui-tabs-2" onclick="getContentTab('2');">Mail</a></li>
	        </ul>
	        <e:panel id="pnl2_sub" width="100%">
		        <!-- SMS 발송 -->
		        <div id="ui-tabs-1">
					<e:buttonBar id="bx" width="100%" align="right">
						<e:button id="doSend" name="doSend" label="${doSend_N}" onClick="send1" disabled="${doSend_D}" visible="${doSend_V}"/>
						<e:button id="doReset" name="doReset" label="${doReset_N}" onClick="reset1" disabled="${doReset_D}" visible="${doReset_V}"/>
					</e:buttonBar>

			        <e:searchPanel id="form1" title="${form_CAPTION_N }" useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
						<e:inputHidden id="RECIPIENT" name="RECIPIENT"/>
						<e:inputHidden id="TFT_MEMBER" name="TFT_MEMBER"/>
						<e:row>
							<e:label for="CAPTION_SMS" title="${form_CAPTION_SMS_N}"/>
							<e:field>
								<e:textArea disabled="false" height="410px" maxLength="600" width="100%" required="true" id="CAPTION_SMS" readOnly="false" name="CAPTION_SMS"/>
							</e:field>
							<e:label for="RECIPIENT" title="${form_RECIPIENT_N}"/>
							<e:field>
								<e:buttonBar id="sms" width="100%" align="right">
									<e:button id="searchUserSms" name="searchUserSms" label="${searchUserSms_N}" onClick="searchUsers1" disabled="${searchUserSms_D}" visible="${searchUserSms_V}"/>
								</e:buttonBar>
								<e:gridPanel id="gridSms" name="gridSms" width="100%" height="345" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridSms.gridColData}" />
							</e:field>
						</e:row>
					</e:searchPanel>
	   			</div>

	   			<!-- EMail 발송 -->
	   			<div id="ui-tabs-2">
					<e:buttonBar id="b" width="100%" align="right">
						<e:button id="doSend1" name="doSend1" label="${doSend1_N}" onClick="send2" disabled="${doSend1_D}" visible="${doSend1_V}"/>
						<e:button id="doReset1" name="doReset1" label="${doReset1_N}" onClick="reset2" disabled="${doReset1_D}" visible="${doReset1_V}"/>
					</e:buttonBar>

			        <e:searchPanel id="form" title="${form_CAPTION_N }"  useTitleBar="false" labelWidth="${labelWidth}" width="100%" columnCount="2">
						<e:inputHidden id="RECIPIENT2" name="RECIPIENT2"/>
						<e:inputHidden id="TFT_MEMBER2" name="TFT_MEMBER2"/>
						<e:row>
							<e:label for="SUBJECT" title="${form_SUBJECT_N}"/>
							<e:field>
								<e:inputText id="SUBJECT" name="SUBJECT" value="${form.SUBJECT}" width="100%" maxLength="${form_SUBJECT_M}" disabled="${form_SUBJECT_D}" readOnly="${form_SUBJECT_RO}" required="${form_SUBJECT_R}" />
							</e:field>
							<e:label for="RECIPIENT" title="${form_RECIPIENT_N}" rowSpan="3"/>
							<e:field rowSpan="3">
								<e:buttonBar id="msg" width="100%" align="right">
									<e:button id="searchUserMsg" name="searchUserMsg" label="${searchUserMsg_N}" onClick="searchUsers2" disabled="${searchUserMsg_D}" visible="${searchUserMsg_V}"/>
								</e:buttonBar>
								<e:gridPanel id="gridMsg" name="gridMsg" width="100%" height="345" gridType="${_gridType}" readOnly="${param.detailView}" columnDef="${gridInfos.gridMsg.gridColData}" />
							</e:field>
						</e:row>
						<e:row>
			               	<e:label for="CAPTION_MSG" title="${form_CAPTION_MSG_N }" />
			               	<e:field>
			               		<e:textArea id="CAPTION_MSG" width="100%" name="CAPTION_MSG" height="370" disabled="false" visible="true" readOnly="false" required="true" maxLength="9999" />
								<e:inputHidden id="USER_TYPE" name="USER_TYPE" value="C" />
			 				</e:field>
			 			</e:row>
					</e:searchPanel>
	        	</div>
	        </e:panel>
       	</div>
	</e:panel>
    </e:window>
</e:ui>
