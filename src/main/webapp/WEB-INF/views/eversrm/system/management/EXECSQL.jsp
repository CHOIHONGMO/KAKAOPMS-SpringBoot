<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script>
        var cnt = 0;
        var baseUrl = '/eversrm/system/management';

        function init() {
        }
        
        function goexec() {
        	if(!confirm('실행 하시겠습니까?')) {
        		return;
        	}
        	
            var param = {
  				  havePermission : false
  				, SQL : EVF.C('SQL').getValue()
  				, PWD : EVF.C('PWD').getValue()
  				, TYPE : getActiveRadio()
  				, detailView : false
  			};
  	  		everPopup.openPopupByScreenId('EXECSQLRESULT', 1000, 850, param);    	
        }

        function getActiveRadio() {
            var radioArray = ["S", "T"];
            for (var i = 0; i < radioArray.length; i++) {
                if (EVF.C(radioArray[i]).isChecked()) {
                    return radioArray[i];
                }
            }
        }
        
        
        
    </script>

    <e:window id="SYSM_010" onReady="init" initData="${initData}">
        <e:title title="SQL" />
        <e:searchPanel id="form" columnCount="1" collapsed="false" useTitleBar="false">
            <e:row>
                <e:label for="MESSAGE1" title="SQL"/>
                <e:field colSpan="2">
                    <e:textArea id="SQL" name="SQL" required="" disabled="" readOnly="" maxLength="" width="100%" height="500"/>
                </e:field>
            </e:row>

            <e:row>
                <e:label for="MESSAGE1" title="구분"/>
                <e:field colSpan="2">
			        <e:radio id="S" name="radio" label="조회" required="false" readOnly="false" checked="true" value="S"/>
			        <e:radio id="T" name="radio" label="트랜잭션" required="false" readOnly="false" value="T"/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="MESSAGE1" title="패스워드"/>
                <e:field colSpan="2">
					<e:inputPassword disabled="false" maxLength="200" width="400" required="true" id="PWD" readOnly="false" name="PWD"/>
				</e:field>
            </e:row>

        </e:searchPanel>
        
        <e:br/>
		<e:button id="GOEXEC" onClick="goexec" label="실 행" />
    </e:window>
</e:ui>