<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="sessionInfoList" value='<%=request.getAttribute("SESSION_INFO")%>' />
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">


    <script type="text/javascript" src="/js/RSA/rsa.js"></script>
    <script type="text/javascript" src="/js/RSA/jsbn.js"></script>
    <script type="text/javascript" src="/js/RSA/prng4.js"></script>
    <script type="text/javascript" src="/js/RSA/rng.js"></script>

    <script type="text/javascript">

    	function executeBatch1() {
    		var store = new EVF.Store();
    		store.load('/test/executeBatch1', function () {
	    		var message = this.getResponseMessage();
	    		alert(message);
    		});
    	}

    	function executeBatch2() {
    		var store = new EVF.Store();
    		store.load('/test/executeBatch2', function () {
	    		var message = this.getResponseMessage();
	    		alert(message);
    		});
    	}

        function changeSession() {


            var rsa = new RSAKey();
            rsa.setPublic($('#RSAModulus').val(),$('#RSAExponent').val());

            var store = new EVF.Store();
//            store.setParameter("userId", $('#userId').val());
//            store.setParameter("password", $('#password').val());

            store.setParameter("userId", rsa.encrypt($('#userId').val()));
            store.setParameter("password", rsa.encrypt(""));
            store.setParameter("userType", EVF.V("USER_TYPE_SEARCH"));

            store.setParameter("sessionChange", "true");


            if($('#userId').val().trim() == '') {
                return alert('아이디를 입력해야 합니다.');
            }

            store.load('/login', function () {
                var message = this.getResponseMessage();
                if (message == undefined) { <%-- 오류가 없으면 json 형식으로 리턴되지 않기 때문에 undefined로 체크한다. --%>
                top.location.href = "/";
                } else {
                    alert(message);
                    top.location.href = "/error/" + this.getParameter("failType") + "";
                }
            });
        }

        function doUpdateVendorUserPassword() {
            var store = new EVF.Store();
            if(!confirm('협력회사 패스워드가 모두 초기화 됩니다. 계속하시겠습니까?')) {
                return;
            }

            if(!confirm('한번 더,,,, 협력회사 패스워드가 모두 초기화 됩니다. 계속하시겠습니까?')) {
                return;
            }

            if(!confirm('수정되면 당신 책임입니다,,,, 협력회사 패스워드가 모두 초기화 됩니다. 계속하시겠습니까?')) {
                return;
            }

            store.load('/common/doUpdateVendorUserPassword', function () {
                var message = this.getResponseMessage();
                alert(message);
            });
        }

        function getUserId() {
            if(EVF.V("USER_TYPE_SEARCH")==""){
                alert("${sessionChange_0002}");
                EVF.C('USER_TYPE_SEARCH').setFocus();
                return;
            }

            var param = {
                callBackFunction: "setUserId",
                GATE_CD : "${ses.gateCd}"
            };

            if(EVF.V("USER_TYPE_SEARCH")=="C"){
                everPopup.openCommonPopup(param, "SP0011");
            }else if(EVF.V("USER_TYPE_SEARCH")=="B"){
                everPopup.openCommonPopup(param, "SP0090");
            }else{
                everPopup.openCommonPopup(param, "SP0091");
            }


        }

        function openContentsPopup() {
        	var param = {
					  havePermission : true
					, callBackFunction : 'setTextContents'
				};

			everPopup.openPopupByScreenId('commonTextContents', 650, 350, param);
        }

        function setTextContents(contents) {
        	alert(contents);
        }

        function setUserId(data) {
    	    if(everString.isEmpty(data['USER_ID_$TP'])) {
                $('#userId').val(data['USER_ID']);
            } else {
                $('#userId').val(data['USER_ID_$TP']);
            }
        }

        function getVendorCode() {

            var param = {
                callBackFunction: "setVendorCode",
                BUYER_CD: "${ses.companyCd}"
            };
            everPopup.openCommonPopup(param, 'SP0013');
        }

        function setVendorCode(dataJsonArray) {
            EVF.C('VENDOR_CD').setValue(dataJsonArray['VENDOR_CD']);
            EVF.C('VENDOR_NM').setValue(dataJsonArray['VENDOR_NM']);
        }

        function getVendorCodeB() {

            var param = {
                callBackFunction: "setVendorCodeb",
                BUYER_CD: "${ses.companyCd}"
            };
            everPopup.openCommonPopup(param, 'SP0013');
        }

        function setVendorCodeb(dataJsonArray) {
            EVF.C('VENDOR_CD_B').setValue(dataJsonArray['VENDOR_CD']);
            EVF.C('VENDOR_NM_B').setValue(dataJsonArray['VENDOR_NM']);
        }



        function doUpdateVendorEncQta() {

            var vendorCd = EVF.C('VENDOR_CD').getValue();
            if(EVF.isEmpty(vendorCd)) {
                return alert('협력회사코드를 먼저 조회해주세요.');
            }

            var qtaNum = EVF.C('QTA_NUM').getValue();
            if(EVF.isEmpty(qtaNum)) {
                return alert('견적서번호를 입력해주세요.');
            }

            if(!confirm('해당 견적서의 암호화된 단가, 금액을 재암호화하여 업데이트합니다.\n업데이트 이전 데이터값은 로그파일에 기록됩니다.\n\n계속하시겠습니까?')) { return; }

            var store = new EVF.Store();
            store.load('/common/doUpdateVendorEncQta', function() {
                alert(this.getResponseMessage());
            }, true);
        }


        function changeVendorCd() {

            var vendorCd = EVF.C('VENDOR_CD_B').getValue();
            if(EVF.isEmpty(vendorCd)) {
                return alert('협력회사코드를 먼저 조회해주세요.');
            }

            var vendorCdb = EVF.C('VENDOR_CD_A').getValue();
            if(EVF.isEmpty(vendorCdb)) {
                return alert('변경할 협력회사코드를 입력해주세요.');
            }



            if(!confirm('업체코드를 변경합니다.\n\n계속하시겠습니까?')) { return; }

            var store = new EVF.Store();
            store.load('/common/changeVendorCd', function() {
                alert(this.getResponseMessage());
            }, true);
        }

    </script>
    <e:window id="sessionChange" title="Session Change">

        <e:searchPanel id="sc" title="Functions" columnCount="1" labelWidth="120" useTitleBar="false" >
            <e:row>
                <e:label for="USER_TYPE_SEARCH" title="${sForm_USER_TYPE_SEARCH_N}"></e:label>
                <e:field>
                    <e:select id="USER_TYPE_SEARCH" name="USER_TYPE_SEARCH" value="C" options="${userTypeSearchOptions}" width="200" disabled="${sForm_USER_TYPE_SEARCH_D}" readOnly="${sForm_USER_TYPE_SEARCH_RO}" required="${sForm_USER_TYPE_SEARCH_R}" placeHolder=""  usePlaceHolder="false" onChange="UserTypeSearchChange" />
                    <e:inputHidden id="GRID_USER_TYPE" name="GRID_USER_TYPE" value=""/>
                </e:field>
            </e:row>
            <e:row>
                <e:label for="">변경할 사용자 ID</e:label>
                <e:field>
                    <input type="hidden" id="RSAModulus" value="${RSAModulus}"/>
                    <input type="hidden" id="RSAExponent" value="${RSAExponent}"/>

                    <e:inputText id="userId" name="userId" required="false" disabled="false" readOnly="false" maxLength="100" width="200" />
                    <e:text>&nbsp;</e:text>
                    <e:button id="searchUserId" label="사용자 검색" onClick="getUserId" />
                    <e:button id="changeSession" label="세션 변경" onClick="changeSession" />
                    <%--<e:button id="openContentsPopup" label="Contents Common Popup" onClick="openContentsPopup" />--%>
                    <%-- <e:button id="doUpdateVendorUserPassword" label="협력회사패스워드 일괄변경" onClick="doUpdateVendorUserPassword" /> --%>
                </e:field>
            </e:row>
            <%--<e:row>--%>
                <%--<e:label for="">변경할 업체코드</e:label>--%>
                <%--<e:field>--%>
                    <%--<e:search id="VENDOR_CD" name="VENDOR_CD" required="false" disabled="true" readOnly="false" maxLength="100" onIconClick="getVendorCode" />--%>
                    <%--<e:inputText id="VENDOR_NM" name="VENDOR_NM" required="false" disabled="false" readOnly="true" maxLength="100" />--%>
                    <%--<e:inputText id="QTA_NUM" name="QTA_NUM" required="false" disabled="false" readOnly="false" maxLength="100" placeHolder="견적번호" />--%>
                    <%--<e:text>&nbsp;</e:text>--%>
                    <%--<e:button id="doUpdateVendorEncQta" label="협력회사견적서재암호화" onClick="doUpdateVendorEncQta" />--%>
                <%--</e:field>--%>
            <%--</e:row>--%>


            <%--<e:row>--%>
                <%--<e:label for="">변경할 업체코드2</e:label>--%>
                <%--<e:field>--%>
                    <%--<e:search id="VENDOR_CD_B" name="VENDOR_CD_B" required="false" disabled="true" readOnly="false" maxLength="100" onIconClick="getVendorCodeB" />--%>
                    <%--<e:inputText id="VENDOR_NM_B" name="VENDOR_NM_B" required="false" disabled="false" readOnly="true" maxLength="100" />--%>
                    <%----%>
                    <%--<e:inputText id="VENDOR_CD_A" name="VENDOR_CD_A" required="true" disabled="false" readOnly="false" maxLength="100" placeHolder="변경할 업체번호" />--%>
                    <%--<e:text>&nbsp;</e:text>--%>
                    <%--<e:button id="changeVendorCd" label="협력업체코드변경" onClick="changeVendorCd" />--%>
                <%--</e:field>--%>
            <%--</e:row>--%>



        </e:searchPanel>

        <e:searchPanel id="sesPanel" title="Session Detail" columnCount="2" labelWidth="120" useTitleBar="false" >
            <c:forEach var="ses" items="${sessionInfoList}" varStatus="status">
                <c:if test="${status.index % 2 == 0}">
                    <tr>
                </c:if>

                <e:label for="" title="${ses.text}"/>
                <e:field>
                    <e:text>${ses.value}</e:text>
                </e:field>

                <c:if test="${status.index % 2 == 1}">
                    </tr>
                </c:if>
            </c:forEach>
        </e:searchPanel>

    </e:window>
</e:ui>
<%--</head>--%>
<%--<body>--%>
<%--<table>--%>
    <%--<tr>--%>
        <%--<td>--%>
            <%--<font color="blue">■ 변경할 사용자 ID 를 입력하세요.</font>--%>
        <%--</td>--%>
        <%--<td>--%>
            <%--<input type="text" id="userId" name="userId" value="" />--%>
            <%--<button onclick="">사용자 검색</button>--%>
            <%--<button onclick="changeSession()">Session Change</button>--%>
            <%--<button onclick="openContentsPopup()"></button>--%>
            <%--<button onclick="doUpdateVendorUserPassword()"></button>--%>
        <%--</td>--%>
    <%--</tr>--%>
    <%--<tr>--%>
        <%--<td>--%>
            <%--<font color="blue">■ 변경할 협력회사코드를 입력하세요.</font>--%>
        <%--</td>--%>
        <%--<td>--%>
            <%--<input type="text" id="VENDOR_CD" name="VENDOR_CD" value="" readonly="readonly" onclick="javascript:getVendorCode();" />--%>
            <%--<input type="text" id="VENDOR_NM" name="VENDOR_NM" value="" readonly="readonly" onclick="javascript:getVendorCode();" />--%>
            <%--<button onclick="doUpdateVendorEncQta()">협력회사견적서재암호화</button>--%>
        <%--</td>--%>
    <%--</tr>--%>

    <%--<tr>--%>
        <%--<th scope="col">ID</th>--%>
        <%--<th scope="col">VALUE</th>--%>
    <%--</tr>--%>

    <%--<%--%>
        <%--java.util.ArrayList al = (java.util.ArrayList) request.getAttribute("SESSION_INFO");--%>
        <%--for (int k = 0; k < al.size(); k++) {--%>
            <%--java.util.HashMap mm = (java.util.HashMap) al.get(k);--%>
            <%--if (k % 2 == 0) {--%>
    <%--%>--%>
    <%--<tr class="odd">--%>
        <%--<td><%=mm.get("text") %>--%>
        <%--</td>--%>
        <%--<td><%=mm.get("value") %>--%>
        <%--</td>--%>
    <%--</tr>--%>

    <%--<% } else { %>--%>
    <%--<tr>--%>
        <%--<td><%=mm.get("text") %>--%>
        <%--</td>--%>
        <%--<td><%=mm.get("value") %>--%>
        <%--</td>--%>
    <%--</tr>--%>
    <%--<% }--%>
    <%--}--%>
    <%--%>--%>
<%--</table>--%>
<%--</body>--%>
<%--</html>--%>