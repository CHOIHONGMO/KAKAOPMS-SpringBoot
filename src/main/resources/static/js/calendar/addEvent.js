var eventModal = $('#eventModal');

var modalTitle = $('.modal-title');
var editAllDay = $('#edit-allDay');
var editTitle = $('#edit-title');
var editStart = $('#edit-start');
var editEnd = $('#edit-end');
var editType = $('#edit-type');
var editColor = $('#edit-color');
var editDesc = $('#edit-desc');

var addBtnContainer = $('.modalBtnContainer-addEvent');
var modifyBtnContainer = $('.modalBtnContainer-modifyEvent');


/* ****************
 *  새로운 일정 생성
 * ************** */
var newEvent = function (obj, start, end, eventType, userNm) {

    $("#contextMenu").hide(); //메뉴 숨김

    modalTitle.html('<i class="fas fa-circle" style="font-size: 10px; color: #0c7cd5;position: relative; top: -2px;"></i> 새로운 일정');
    editType.val(eventType);
    editTitle.val('');
    editStart.val(start);
    editEnd.val(end);
    editDesc.val('');

    // 체크가 선택되어 있으면 년월일 00 시간으로 표시
    if (editAllDay.is(':checked')) {
        setAllDay();
    }

    addBtnContainer.show();
    modifyBtnContainer.hide();
    eventModal.modal('show');

    var editColorFlag = false;

    // 컬러 설정
    var disabledFlag = true;
    if (eventType == '1') {
        setEditColor = '#388E3C';
    } else if (eventType == '2') {
        setEditColor = '#658CD9';
    } else if (eventType == '3') {
        setEditColor = '#D39A11';
    } else if (eventType == '4') {
        setEditColor = '#D32F2F';
    } else {
        setEditColor = editColor.val();
        disabledFlag = false;
    }
    editColor.val(setEditColor);

    // 제어 불가
    if (disabledFlag) {
        $('#edit-type').attr('disabled', true);
        $('#edit-color').attr('disabled', true);
    } else {
        $('#edit-type').attr('disabled', false);
        $('#edit-color').attr('disabled', false);
    }

    /******** 임시 RAMDON ID - 실제 DB 연동시 삭제 **********/
    var eventId = 1 + Math.floor(Math.random() * 1000);
    /******** 임시 RAMDON ID - 실제 DB 연동시 삭제 **********/

    //새로운 일정 저장버튼 클릭
    $('#save-event').unbind();
    $('#save-event').on('click', function () {

        var eventData = {
            /*_id: eventId,*/
            title: editTitle.val(),
            start: editStart.val(),
            end: editEnd.val(),
            realEndDay: editEnd.val(),
            description: editDesc.val(),
            username: userNm,
            type: eventType,
            backgroundColor: setEditColor,
            textColor: '#ffffff',
            allDay: false
        };

        if (eventData.start > eventData.end) {
            alert('끝나는 날짜가 앞설 수 없습니다.');
            return false;
        }

        if (eventData.title === '') {
            alert('일정명은 필수입니다.');
            return false;
        }

        var realEndDay;

        if (editAllDay.is(':checked')) {
            eventData.start = moment(eventData.start).format('YYYY-MM-DD');
            //DB에 넣을때(선택)
            eventData.realEndDay = moment(eventData.end).format('YYYY-MM-DD');
            //render시 날짜표기수정
            eventData.end = moment(eventData.end).add(1, 'days').format('YYYY-MM-DD');
            eventData.allDay = true;
        }

        eventModal.find('input, textarea').val('');
        editAllDay.prop('checked', false);
        eventModal.modal('hide');

        //새로운 일정 저장
        $.ajax({
            type: "post",
            url: "/everadmin/system/calendar/CALENDAR01_010_doSave.so",
            data: eventData,
            success: function (response) {
                eventData._id = response;
                obj.addEvent(eventData);
                // location.href = "/everadmin/system/calendar/CALENDAR01_010/view.so";
            }
        });

    });
};