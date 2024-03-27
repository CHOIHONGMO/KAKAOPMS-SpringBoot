/* ****************
 *  일정 편집
 * ************** */
var editEvent = function (obj, event, element) {
    $('#deleteEvent').data('id', event._id); //클릭한 이벤트 ID

    $('.popover.fade.top').remove();
    $(element).popover("hide");

    if (event.allDay === true) {
        editAllDay.prop('checked', true);
    } else {
        editAllDay.prop('checked', false);
    }

    //하루짜리 all day
    if (event.allDay && event.end === event.start) {
        event.end = event.start;
        editEnd.val(event.start);
    }

    //2일이상 all day
    else if (event.allDay && event.end !== null) {
        editEnd.val(moment(event.end).subtract(1, 'days').format('YYYY-MM-DD' + ' 00:00'));
    }

    //all day가 아님
    else if (!event.allDay) {
        editEnd.val(moment(event.end).add(-1, 'days').format('YYYY-MM-DD HH:mm'));
    }

    modalTitle.html('<i class="fas fa-circle" style="font-size: 10px; color: #0c7cd5;position: relative; top: -2px;"></i> 일정 수정');
    editTitle.val(event.title);
    editStart.val(moment(event.start).format('YYYY-MM-DD HH:mm'));
    editType.val(event._def.extendedProps.type);
    editDesc.val(event._def.extendedProps.description);
    editColor.val(event.backgroundColor).css('color', event.backgroundColor);

    addBtnContainer.hide();
    modifyBtnContainer.show();
    eventModal.modal('show');

    //업데이트 버튼 클릭시
    $('#updateEvent').off('click');
    $('#updateEvent').on('click', function () {

        if (editStart.val() > editEnd.val()) {
            alert('끝나는 날짜가 앞설 수 없습니다.');
            return false;
        }

        if (editTitle.val() === '') {
            alert('일정명은 필수입니다.')
            return false;
        }

        var statusAllDay;
        var startDate;
        var endDate;
        var displayDate;

        if (editAllDay.is(':checked')) {
            statusAllDay = true;
        } else {
            statusAllDay = false;
        }

        startDate = editStart.val();
        endDate = editEnd.val();
        displayDate = moment(editEnd.val()).add(1, 'days').format('YYYY-MM-DD HH:mm');

        eventModal.modal('hide');

        event.allDay = statusAllDay;
        event.title = editTitle.val();
        event.start = startDate;
        event.end = displayDate;
        event.type = editType.val();
        event.backgroundColor = editColor.val();
        event.description = editDesc.val();

        var eventData = {
            _id: event._def.extendedProps._id,
            title: editTitle.val(),
            start: startDate,
            end: displayDate,
            realEndDay: endDate,
            description: editDesc.val(),
            username: event._def.extendedProps.username,
            type: event.type,
            backgroundColor: editColor.val(),
            allDay: statusAllDay
        };

        //일정 업데이트
        $.ajax({
            type: "post",
            url: "/everadmin/system/calendar/CALENDAR01_010_doSave.so",
            data: eventData,
            dataType: "html",
            success: function (response) {
                event.remove();
                obj.addEvent(eventData);
                $('.tooltips').remove();
                alert('수정되었습니다.');
                // location.href = "/everadmin/system/calendar/CALENDAR01_010/view.so";
            }
        });
    });

    // 삭제버튼
    $('#deleteEvent').off('click');
    $('#deleteEvent').on('click', function () {

        $('#deleteEvent').unbind();

        eventModal.modal('hide');

        //삭제시
        $.ajax({
            type: "post",
            url: "/everadmin/system/calendar/CALENDAR01_010_doDelete.so",
            data: {
                _id: event._def.extendedProps._id,
            },
            success: function (response) {
                event.remove();
                $('.tooltips').remove();
                alert('삭제되었습니다.');
            },
            done: function() {

            }
        });

    });
};
