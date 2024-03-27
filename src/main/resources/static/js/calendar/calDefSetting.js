//SELECT 색 변경
$('#edit-color').change(function () {
    $(this).css('color', $(this).val());
});

//필터
$('.filter').on('change', function () {
    $('#calendar').fullCalendar('rerenderEvents');
});

$("#type_filter").select2({
    placeholder: "선택..",
    allowClear: true
});

//datetimepicker
$("#edit-start, #edit-end").datetimepicker({
    dayViewHeaderFormat: 'YYYY MMMM',
    format: 'YYYY-MM-DD HH:mm',
    locale: 'ko',
    icons: {
        time: "far fa-clock",
        date: "far fa-calendar",
        up: "fas fa-arrow-up",
        down: "fas fa-arrow-down",
        previous: "fas fa-chevron-left",
        next: "fas fa-chevron-right",
        today: "far fa-clock",
        clear: "fas fa-trash"
    }
});