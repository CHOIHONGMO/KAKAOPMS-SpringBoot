<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var cnt = 0;
        var baseUrl = '/eversrm/system/management';

        function init() {
//            setInterval(function() {
//                var store = new EVF.Store();
//                store.load(baseUrl+'/SYSM_010/getSystemInfo', function() {
//                    var systemInfo = this.getParameter('systemInfo');
//                    EVF.C('A').setValue(systemInfo);
//                }, false);
//            }, 2000);

            EVF.C('MESSAGE1').setValue("분 후 소스반영으로 서버가 다운됩니다.\n점검 시간은 2분 입니다.");
            EVF.C('MESSAGE2').setValue("서버가 다운됩니다.\n점검 시간은 2분 입니다.");
        }

        function alarmNotice() {
            var store = new EVF.Store();

            if(EVF.C("TIME").getValue() != "" && EVF.C("TIME_CHECK").getValue() == "1") {

                if(EVF.C("TIME").getValue() != 0) {
                    EVF.C('NOTICE_TEXT').setValue(EVF.C("TIME").getValue() + EVF.C('MESSAGE1').getValue());
                } else {
                    EVF.C('NOTICE_TEXT').setValue(EVF.C('MESSAGE2').getValue());
                }

                store.load(baseUrl+'/SYSM_010/alarmNotice', function() {

                    if(EVF.C("TIME").getValue() != "0") {
                        EVF.C('TIME').setValue(EVF.C("TIME").getValue() - 1);
                        setTimeout("alarmNotice();", 60000);
                    }
                });
            } else {
                store.load(baseUrl+'/SYSM_010/alarmNotice', function() {
                    EVF.C('NOTICE_TEXT').setValue('');
                });
            }

        }

        function onChangeText(a, b, c) {
            console.log(a, b, c);
        }
    </script>

    <e:window id="SYSM_010" onReady="init" initData="${initData}">
        <e:title title="전체공지" />
        <e:searchPanel id="form" columnCount="3" collapsed="false" useTitleBar="false">
            <e:row>
                <e:label for="NOTICE_TEXT" title="실시간 전체 알림" />
                <e:field colSpan="5">
                    <e:textArea id="NOTICE_TEXT" name="NOTICE_TEXT" required="false" disabled="false" readOnly="false" maxLength="2000" width="500" height="50" />
                    <e:button id="ALARM_NOTICE" onClick="alarmNotice" label="알림" />
                    <div style="float: inherit;">
                        <e:inputText id="TIME" name="TIME" required="" disabled="" readOnly="" maxLength="2" width="25px"/>
                        <e:text>분 설정 / </e:text>
                        <e:check id="TIME_CHECK" name="TIME_CHECK" label="1분 마다 알림" value="1"/>
                    </div>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MESSAGE1" title="시작 메세지"/>
                <e:field colSpan="2">
                    <e:textArea id="MESSAGE1" name="MESSAGE1" required="" disabled="" readOnly="" maxLength="" width="100%" height="50"/>
                </e:field>
                <e:field colSpan="3"/>
            </e:row>
            <e:row>
                <e:label for="MESSAGE2" title="종료 메세지"/>
                <e:field colSpan="2">
                    <e:textArea id="MESSAGE2" name="MESSAGE2" required="" disabled="" readOnly="" maxLength="" width="100%" height="50"/>
                </e:field>
                <e:field colSpan="3"/>
            </e:row>
        </e:searchPanel>
        <div style="display: none;">
        <e:title title="시스템 정보" />
        <e:searchPanel id="form2" columnCount="3">
            <e:row>
                <e:label for="정보" />
                <e:field colSpan="5">
                    <e:textArea id="A" name="A" required="false" disabled="false" readOnly="false" maxLength="false" width="100%" height="300" />
                </e:field>
            </e:row>
            <e:row>
                <e:label for="정보" />
                <e:field>
                    <e:inputText id="B" name="B" required="false" disabled="false" readOnly="false" maxLength="100" onChange="onChangeText" />
                </e:field>
            </e:row>
        </e:searchPanel>
        </div>
    </e:window>
</e:ui>