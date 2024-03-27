<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>

<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
<script type="text/javascript">

    function doSearch() {
        var store = new EVF.Store();
        store.setParameter("P1", "ABCDE");
        store.setParameter("P2", "가나다라마바사");
        store.load("/common/sample/doSearch", function () {
            alert('doSearch! ::' + this.getParameter("P2"));
        });
    }

    function doRedirect() {
        location.href = "/common/sample/samplePage1/view.so?P2=하하하하하하하";
    }

    function doUpdate() {
        var store = new EVF.Store();
        store.setParameter('grid1', grid1.getAllRows());
        store.setParameter("grid1", "testdata");
        store.setParameter("grid2", "test2data");
        store.load('/common/sample/doDelete', function () {
            alert(this.getResponseMessage());
            alert(this.getParameter('result'));

            doSearch();
        });
    }

    function doDelete() {
        console.log('doDelete');
    }

    function testInit() {
        alert('init!');
    }

    function doTestButton() {
        var store = new EVF.Store();
        store.setParameter("test", "testdata");
        store.setParameter("test2", "test2data");
        store.load('/common/sample/doSearch', function () {

        });
    }

    function init2() {

        console.log('page init!');

        var grid1 = {};

        var gridSelect = {
            '1': 'test1',
            '2': 'test2',
            '3': 'test3',
            '4': 'test4'
        };

        var gridSelect = {
            '1': 'test1',
            '2': 'test2',
            '3': 'test3',
            '4': 'test4'
        };

        var imgData = {
            src: '/images/eversrm/buttons/btn_user.gif',
            text: ''
        };

        EVF.C('select1').setFocus();
    }

    function selectDate(old, new2, obj) {
        console.log(old, new2, obj);
    }

    function onChanged() {
        console.log('called onChanged!');
    }

    function onKeyPress() {
        console.log('called onKeyPress!');
    }

    function onKeyDown() {
        console.log('called onKeyDown!');
    }

    function onClick() {
        console.log('called onClick!');
    }

    function onKeyUp() {
        console.log('called onKeyUp!');
    }

    function onDblClick() {
        console.log('called onDblClick!');
    }

    function onFocus() {
        console.log('called onFocus!');
    }

    function onBlur() {
        console.log('called onBlur!');
    }

    function onSelect() {

    }

    function doSave2() {
        alert('저장');
        var store = new EVF.Store();
        store.validate();
        store.doFileUpload(function () {
            <%--alert(EVF.getComponent('fileManager').getFileId());--%>
            <%--alert(EVF.getComponent('fileManager2').getFileId());--%>
            store.load("/common/sample/doSearch", function () {

            });
        });
    }

    function onIconClicked() {
        console.log('onIconClick fired!');
    }

    function onBeforeRemove() {
        console.log('onBeforeRemove');
    }

    function onFileClick() {
        console.log('onFileClick');
    }

    function onSuccess() {
        console.log('onSuccess');
    }

    function onChangeD1() {
        EVF.C('dynamicSelect2').setOptions([
            {text: 'A', value: 'A'},
            {text: 'B', value: 'B'},
            {text: 'C', value: 'C'}
        ]);
    }

    function yes(val) {
        alert(val);
    }

    function toggleDisabled() {
        EVF.C('BSYO_020').iterator(function () {
            this.setDisabled(!this.isDisabled());
        });
//            EVF.C('AA').setDisabled(!EVF.C('AA').isDisabled());
//            EVF.C('AA2').setDisabled(!EVF.C('AA2').isDisabled());
//            EVF.C('BB').setDisabled(!EVF.C('BB').isDisabled());
//            EVF.C('BB2').setDisabled(!EVF.C('BB2').isDisabled());
//            EVF.C('CC').setDisabled(!EVF.C('CC').isDisabled());
//            EVF.C('CC2').setDisabled(!EVF.C('CC2').isDisabled());
    }

    function toggleSearchPanel() {
        EVF.C('form').setHeight(0);
    }

</script>
<e:window id="BSYO_020" onReady="" width="100%" height="100%" name="windowName" title="샘플페이지1">
    <e:panel id="aa" visible="true">
        <e:searchPanel id="form" name="form1" title="검색조건" labelWidth="${labelWidth}" columnCount="2" height="0" visible="false">
            <e:row>
                <e:label for="align=left" title="align 속성"/>
                <e:field>
                    <e:search id="CC" name="CC" onIconClick="onIconClicked" width="100%" visible="true" required="" disabled="false" readOnly="false" maxLength="" align="left" value="left" />
                    <e:br />
                    <e:inputText id="AA" name="AA" required="" disabled="false" readOnly="false" value="left" maxLength="" align="left" width="100" style="color: red; font-weight: bold;" />
                    <e:br />
                    <e:inputText id="AA2" name="AA2" required="" disabled="false" readOnly="false" value="left" maxLength="" align="left" width="100" />
                    <e:inputText id="AA3" name="AA3" required="" disabled="false" readOnly="false" value="left" maxLength="" align="left" width="100" />
                </e:field>
            </e:row>
        </e:searchPanel>
    </e:panel>
    <%--${html}
    <textarea style="width: 500px; height: 300px;">
        ${html}
    </textarea>--%>
    <e:buttonBar id="bbar" width="100%">
        <e:button id="toggleSearchPanel" onClick="toggleSearchPanel" label="toogle SearchPanel" />
    </e:buttonBar>
    <%--<e:searchPanel id="form" name="form1" title="검색조건" labelWidth="${labelWidth}" columnCount="2" height="0">--%>
    <%--<e:row>--%>
    <%--<e:label for="align=left" title="align 속성" />--%>
    <%--<e:field>--%>
    <%--<e:inputText id="AA" name="AA" required="" disabled="false" readOnly="false" value="left" maxLength="" align="left" width="100" />--%>
    <%--<e:inputText id="AA2" name="AA2" required="" disabled="false" readOnly="false" value="right" maxLength="" align="right" width="100" />--%>
    <%--<e:inputNumber id="BB" name="BB" align="left" required="" disabled="false" readOnly="false" value="123456" currencyUnit="KRW" decimalPlace="4" width="100" />--%>
    <%--<e:inputNumber id="BB2" name="BB2" align="right" required="" disabled="false" readOnly="false" value="123456" currencyUnit="KRW" decimalPlace="4" width="100" />--%>
    <%--<e:search id="CC" name="CC" onIconClick="onIconClicked" width="100" visible="true" required="" disabled="false" readOnly="false" maxLength="" align="left" value="left" />--%>
    <%--<e:search id="CC2" name="CC2" onIconClick="onIconClicked" width="100" visible="true" required="" disabled="false" readOnly="false" maxLength="" align="right" value="right" />--%>
    <%--<e:button id="toggleDisabled" onClick="toggleDisabled" alt="toggle DisabledAttr" label="toggle DisabledAttr" />--%>
    <%--</e:field>--%>
    <%--<e:label for="number1" title="">숫자입력폼</e:label>--%>
    <%--<e:field>--%>
    <%--<e:inputNumber value="123125125.12312312321" visible="true" readOnly="" disabled="" align="left" id="number1" name="number1" onChange="onChanged" onKeyPress="onKeyPress" onKeyDown="onKeyDown" onClick="onClick" onBlur="onBlur" onKeyUp="onKeyUp" onDblClick="onDblClick" onFocus="onFocus" required="true" />--%>
    <%--</e:field>--%>
    <%--</e:row>--%>
    <%--<e:row>--%>
    <%--<e:label for="select1" title="선택상자" />--%>
    <%--<e:field>--%>
    <%--<e:select id="select1" name="select1" visible="true" readOnly="" disabled="" placeHolder="------ 전체 ------" required="true" width="100%">--%>
    <%--<e:option text="AA" value="AA" />--%>
    <%--<e:option text="BB" value="BB" />--%>
    <%--<e:option text="CC" value="CC" />--%>
    <%--</e:select>--%>
    <%--</e:field>--%>
    <%--<e:label for="date1" title="날짜" />--%>
    <%--<e:field>--%>
    <%--<e:inputDate id="date1" name="date1" value="20131010" visible="true" required="" readOnly="true" disabled="true" datePicker="false" />--%>
    <%--<e:text>~</e:text>--%>
    <%--<e:inputDate id="date2" name="date2" value="201310" visible="true" required="" readOnly="true" disabled="false" format="yy/mm" />--%>
    <%--<e:search id="A" name="A" required="false" disabled="false" readOnly="false" maxLength="false" onClick="doClickA" onIconClick="doClickA" />--%>
    <%--<e:inputDate id="B" name="B" required="false" disabled="false" readOnly="false" />--%>
    <%--</e:field>--%>
    <%--</e:row>--%>
    <%--<e:row>--%>
    <%--<e:label for="" title="라디오"/>--%>
    <%--<e:field>--%>
    <%--<e:radioGroup id="radioGroup1" name="radioGroup1" visible="true" required="" readOnly="" disabled="">--%>
    <%--<e:radio id="radio1" name="radioGroup1" label="R1" value="" checked="true" onClick="yes" />--%>
    <%--<e:radio id="radio2" name="radioGroup1" label="R2" value="R2" onClick="yes" />--%>
    <%--<e:radio id="radio3" name="radioGroup1" label="R3" value="R3" onClick="yes" />--%>
    <%--</e:radioGroup>--%>
    <%--</e:field>--%>
    <%--<e:label for="" title="체크박스" />--%>
    <%--<e:field>--%>
    <%--<e:checkGroup id="cg1" name="cg1" visible="true" required="" readOnly="" disabled="">--%>
    <%--<e:check id="c1" name="a" label="C1" value="C1" onClick="yes"  />--%>
    <%--<e:check id="c2" name="b" label="C2" value="C2" checked="true" onClick="yes" />--%>
    <%--<e:check id="c3" name="c" label="C3" value="C3"  checked="true" onClick="yes" />--%>
    <%--</e:checkGroup>--%>
    <%--<e:inputHidden id="h1" name="h1" value="h1" />--%>
    <%--</e:field>--%>
    <%--</e:row>--%>

    <%--<e:row>--%>
    <%--<e:label for="search1" title="Search" />--%>
    <%--<e:field colSpan="3">--%>
    <%--<e:search id="search1" name="search1" onIconClick="onIconClicked" width="95%" visible="true" required="" readOnly="" disabled="" maxLength="" />--%>
    <%--</e:field>--%>
    <%--</e:row>--%>

    <%--<e:row>--%>
    <%--<e:label for="search" title="inputText" />--%>
    <%--<e:field colSpan="3">--%>
    <%--<e:inputText id="search" name="search" width="95%" visible="true" required="" readOnly="" disabled="" maxLength="" />--%>
    <%--</e:field>--%>
    <%--</e:row>--%>

    <%--<e:row>--%>
    <%--<e:label for="search" title="RichTextEditor" />--%>
    <%--<e:field colSpan="3">--%>
    <%--<e:richTextEditor id="rich1" name="rich1" width="100%" visible="true" required="" readOnly="" disabled=""/>--%>
    <%--</e:field>--%>
    <%--</e:row>--%>

    <%--<e:row>--%>
    <%--<e:label for="" title="그룹" />--%>
    <%--<e:field>--%>
    <%--<e:inputDate label="달력" id="form10" name="form10" visible="true" required="" readOnly="" disabled=""/>--%>
    <%--</e:field>--%>

    <%--<e:label for="" title="선택!" />--%>
    <%--<e:field>--%>
    <%--<e:select width="50px" id="dynamicSelect1" name="dynamicSelect1" visible="true" required="" readOnly="" disabled="" options='[{"text":"=","value":"E"},{"text":"!=","value":"D"},{"text":"Like","value":"L"},{"text":"Not Like","value":"NL"},{"text":">","value":"B"},{"text":">=","value":"BE"},{"text":"<","value":"S"},{"text":"<=","value":"SE"},{"text":"In","value":"I"},{"text":"Not In","value":"NI"},{"text":"is Null","value":"IN"},{"text":"is Not Null","value":"INN"}]' onFocus="onFocus" onDblClick="onDblClick" onKeyUp="onKeyUp" onBlur="onBlur" onChange="onChangeD1" onClick="onClick" onKeyDown="onKeyDown" onKeyPress="onKeyPress" />--%>
    <%--<e:select width="50px" id="dynamicSelect2" name="dynamicSelect2" visible="true" required="" readOnly="" disabled="" onFocus="onFocus" onDblClick="onDblClick" onKeyUp="onKeyUp" onBlur="onBlur" onChange="onChanged" onClick="onClick" onKeyDown="onKeyDown" onKeyPress="onKeyPress" />--%>
    <%--</e:field>--%>
    <%--</e:row>--%>
    <%--<e:row>--%>
    <%--<e:label for="" title="TextArea" />--%>
    <%--<e:field>--%>
    <%--<e:textArea id="textArea" name="textArea" height="300px" width="100%" visible="true" required="" readOnly="" disabled="false" maxLength="10" />--%>
    <%--</e:field>--%>
    <%--<e:label for="" title="FileModule" />--%>
    <%--<e:field>--%>
    <%--<e:fileManager id="fileManager" downloadable="true" name="asdasd" readOnly="" required="" bizType="PR" height="10px" fileId="" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" />--%>
    <%--<e:fileManager id="fileManager2" downloadable="true" name="asdasd" readOnly="" required="" bizType="PR" height="150px" fileId="" onBeforeRemove="onBeforeRemove" onError="onError" onFileClick="onFileClick" onSuccess="onSuccess" />--%>
    <%--</e:field>--%>
    <%--</e:row>--%>
    <%--</e:searchPanel>--%>
    <%--<e:buttonBar id="a" width="100%" align="right">--%>
    <%--<e:button id="doSearch" name="doSearch" label="조회" disabled="false" onClick="doSearch" visible="true" />--%>
    <%--<e:button id="doSave" name="doSave" label="저장" disabled="false" onClick="doSave2" visible="true" />--%>
    <%--<e:button id="doRedirect" name="doRedirect" label="이동하기" disabled="false" onClick="doRedirect" visible="true" />--%>
    <%--</e:buttonBar>--%>
    <%--<e:inputHidden id="hi" name="hi" value="hidden" />--%>
    <%--<e:gridPanel gridType="${_gridType}" id="grid" name="grid" width="100%" height="500px" />--%>
</e:window>
</e:ui>