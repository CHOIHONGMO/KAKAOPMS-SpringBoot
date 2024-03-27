/**
 * everSRM common scripts
 */

var everCommon = {};

everCommon.blank = function() {
    // <e:search TAG의 readOnly가 true이면 호출됨.
};

// session info alert
shortcut.add("F2", function() {
    var store = new EVF.Store();
    store.load('/common/util/sessionInfo.so', function(){
        var sessionInfo = JSON.parse(this.getParameter('sessionInfoString'));
        var printString = '';
        for(var x in sessionInfo){
            if(sessionInfo.hasOwnProperty(x)){
                printString += x + ': ';
                printString += '[ ' + sessionInfo[x] + ' ]';
                printString += '\n';
            }
        }
        console.log(printString);
    });
});

function mComboConvert(val){
    let rtn = '';
    if(val != '' && val != null){
        rtn = val.split(",");
    }
    return rtn;
}
var yppl = function() {

};
/*
*  select 태그 onkeyup 선언시 id 다음요소 nm 공백처리 
* ex) REG_USER_NM 다음요소  DEPT_NM 공백처리
*    
                    <e:label for="REG_USER_NM" title="${form_REG_USER_NM_N}"/>
                    <e:field>
                        <e:search id="REG_USER_NM" name="REG_USER_NM" value="" width="40%" maxLength="${form_REG_USER_NM_M}" onIconClick="${form_REG_USER_NM_RO ? 'everCommon.blank' : 'fnUserPopup'}" disabled="${form_REG_USER_NM_D}" readOnly="${form_REG_USER_NM_RO}" required="${form_REG_USER_NM_R}" onEnter="fnUserPopup"  onKeyUp="yppl.clearNameData"/>
                        <e:inputText id="DEPT_NM" name="DEPT_NM" value="" width="60%" maxLength="${form_DEPT_NM_M}" disabled="${form_DEPT_NM_D}" readOnly="${form_DEPT_NM_RO}" required="${form_DEPT_NM_R}" />
                       
                    </e:field>
*   
* */
yppl.clearNameData = function (event) {

    // keyCode.ENTER=13, keyCode.TAB=9
    if( event.keyCode != 13 && event.keyCode != 9 && !event.isComposing && event.keyCode != 229 ){
        $(event.target).closest('.e-editfield-wrapper').next().find('input:eq("0")').val('')
    }
}
/*
*  2024-01-18 박민호
*  동적 피벗 컬럼 셋팅
*  [필수] gridData 그리드 조회해온 데이터
*  [필수] gridColHeader  그리드 매핑할 컬럼년도 아이디
*  gridGropHeader 선언시  gridColHeader 매핑 아이디 그룹핑
*  gridColHeaderHide 선언시  gridColHeaderHide 매핑 아이디 hidden처리
*  gridColHeaderRequired 선언시  gridColHeaderRequired 매핑 아이디 필수값 선언
*  gridGropDecimal 선언시  decimalLength 소수점자리수 지정 미선언시 colOption.decimalLength 디폴트로 따라감.
*  startYear  시작년도
*  endYear   끝년도
*  groupSize   그룹사이즈 선언시 칼럼 크키 조정
*  [필수] colOption  컬럼 생성할 속성값 {columnType : 'number', align : 'right', width: 50, editable :true, option: {...}}
* */
yppl.settingPivotCol = function (data) {
    let gridColHeader  = data.gridColHeader;
    let endYear        = data.endYear;
    let startYear      = data.startYear;
    let idx   = endYear -startYear;
    let grid           = data.gridObj;
    let gridData       = data.gridData;
    let colOption      = data.colOption;
    let groupSize      = data.groupSize;
    let gridGropHeader = data.gridGropHeader;
    let gridColHeaderHide = data.gridColHeaderHide;
    let gridColHeaderRequired = data.gridColHeaderRequired;
    let gridGropDecimal = data.gridGropDecimal;
    let decimalType = data.decimalType;
    let decimalLength = colOption.customOption.decimalLength;
    colOption.customOption.decimalType = decimalType == null ?"2R" : decimalType;
    let groupHeaderList = [];

    for(let inx in gridColHeader){
        colOption.Required = false;
        if(data.startYear ==null && gridData !=null){

            let maxVal = -1;
            let minVal = 99999999999999999;

            for(let key in gridData[0]){
                if(key.indexOf(gridColHeader[inx]) == 0){

                    maxVal = Math.max(maxVal,Number(key.slice(-4)));
                    minVal = Math.min(minVal,Number(key.slice(-4)));
                }
            }

            startYear = minVal;
            endYear   = maxVal;

        }else{
            startYear = data.startYear;
            endYear   = data.endYear;
        }
        idx = endYear - startYear;
        grid.columns=grid.columns.filter(v=>v.fieldName.includes(gridColHeader[inx])!=true )
        grid.fields=grid.fields.filter(v=>v.fieldName.includes(gridColHeader[inx])!=true )
        let colIdList = [];
        let currentDate = new Date(startYear-1, 0, 1);
        for (let i = 0; i <= idx; i++) {
            currentDate.setFullYear(currentDate.getFullYear() + 1);
            let nextYear = currentDate.getFullYear();
            let id = gridColHeader[inx] + "_" + nextYear
            //HIDEEN 컬럼일시 그리드 크기 0
            colOption.customOption.width = gridColHeader[inx].indexOf("HIDDEN_") == 0 ? "0" : colOption.width;
            //gridColHeaderHide 선언시 일치한거 hide
            for(let hidx in  gridColHeaderHide){
                if(gridColHeader[inx] == gridColHeaderHide[hidx]){
                    colOption.customOption.width = "0";
                }
            }
            //gridColHeaderRequired 선언시 일치한거 필수값
            for(let hidx in  gridColHeaderRequired){
                if(gridColHeader[inx] == gridColHeaderRequired[hidx]){
                    colOption.Required = true;
                }
            }
            //gridColHeader 선언한 배열의 gridGropDecimal 소수점 따라감 단 숫자 벗어날시 디폴트 decimalLength 선언한 소수점 따라감
            if(gridGropDecimal != null){
                colOption.customOption.decimalLength = gridGropDecimal[inx] == null ? decimalLength : gridGropDecimal[inx];
            }

            grid.createColumn(id, nextYear, colOption.width, colOption.align, colOption.columnType, 110, colOption.Required, colOption.editable, colOption.customOption);
            if(startYear == nextYear){
                grid.setColStyle(id,"background-color",'#f8e6e6');
            }else{
                grid.setColStyle(id,"background-color",'#ffffff');
            }
            colIdList.push(id);
        }
        if(data.gridGropHeader != null){

            groupHeaderList.push(
                {
                    "groupName" : gridGropHeader[inx],
                    "columns"   : colIdList
                }
            );

        }
    }
    if(gridData !=null){
        grid.delAllRow();
        grid._gdp.setRows(gridData)

    }

    //기존 groupheader그룹 선언한거 있으면 머지해서 setColGroup
    if(data.gridGropHeader !=null){
        let colList = grid._gvo.saveColumnLayout()
        let groupList = [];
         for(let i in colList){

              let items =colList[i].items;
              if(items !=null){
                  let obj = {};
                  let colmergeList = [];
                  obj.groupName =colList[i].name;
                  for(let j in items){
                      colmergeList.push(items[j].column)
                  }
                  obj.columns = colmergeList
                  groupList.push(obj);
              }
          }
        groupSize = groupSize ==null ? 50 : groupSize;
        //기존 존재하는 그룹헤더랑 다를시만 push;
        for(let h in groupList){
            let flag = true;
            let hName = groupList[h].groupName;
            for(let g in groupHeaderList){
               let gNmae = groupHeaderList[g].groupName
               if(hName == gNmae){
                   flag =false;
               }
            }
            if(flag){
                groupHeaderList.push(groupList[h])
            }
        }
        grid.setColGroup(groupHeaderList,groupSize);
    }
  /*  console.log(gridPo._gvo.setColumnProperty('MAKE_QTY_GRID_2025','numberFormat',"#,##0.###"))
                console.log(gridPo._gvo.setColumnProperty('MAKE_QTY_GRID_2025','editor',{editFormat : "#,##0.###",maxLength :110}))*
                 console.log(gridPo._gvo.getColumns())/
   */
}
//=========================================================================================

//[유라 기준정보 전용] UUID 존재하는 데이터는 행삭제 불가능
yppl.delRow = function (grid){
    var rowIds = grid.getSelRowId();
    for(var i = rowIds.length -1; i >= 0; i--) {
        if(EVF.isEmpty(grid.getCellValue(rowIds[i], "UUID"))) {
            grid.delRow(rowIds[i]);
        } else {
            continue;
        }
    }
}
//createColumn : PROJECT_AUTO_GRID , HIDDEN_GRID 고정
//createColumn 속한 그리드 , 변경되는 행 , 바뀐 값 , 합계
yppl.calculategrQty =  function (grid,rowId,value,ColName){

    let sumQty   = 0;
    let makeRate = Number(value);
    let sumCol = ColName;

    var columns  = grid._gvo.getColumnNames();
    for(let i in columns) {
        let calculategrQt = "";
        if(columns[i].indexOf('PROJECT_AUTO_GRID') == 0) {
            for(let j in columns){
                if(columns[j].indexOf('HIDDEN_GRID_'+ columns[i].slice(-4)) == 0) {
                    calculategrQt = grid.getCellValue(rowId, columns[j]);
                }
            }
            if(!EVF.isEmpty(calculategrQt)) {
                grid.setCellValue(rowId, columns[i], (makeRate / 100 * calculategrQt))
                sumQty += grid.getCellValue(rowId, columns[i]);
            }
        }
    }
    if(!EVF.isEmpty(sumCol)){
        grid.setCellValue(rowId , sumCol , sumQty);
    }

}

//======================날짜체크===================================================================
/*
* 컬럼 필수 시작 종료 ID 선언
*
* dt 필수 개월 선언.
* 2024-01-08 박민호
* */

yppl.checkDate=function (startDt,endDt,dt){
    let flag;
    const fromDate = EVF.V(startDt)
    const toDate   = EVF.V(endDt)

    const fromYear  = parseInt(fromDate.substring(0, 4));
    const fromMonth = parseInt(fromDate.substring(4, 6));
    const toYear    = parseInt(toDate.substring(0, 4));
    const toMonth   = parseInt(toDate.substring(4, 6));

    const month = (toYear - fromYear) * 12 + (toMonth - fromMonth);

    let day   = parseInt(toDate.slice(6, 8))-parseInt(fromDate.slice(6, 8));

    if (dt<=month && day>0 || dt<month) {

        EVF.alert("조회기간은 " + dt + "달 이내로 설정해야 합니다." )
        flag = true;

    }else{
        flag = false;
    }

    return flag;
}