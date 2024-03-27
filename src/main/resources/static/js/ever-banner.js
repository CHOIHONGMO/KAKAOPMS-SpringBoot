var banner = function() {
    {
    }
};

// 움직이는 배너 스크립트
banner.scrollbarFollow = function() {
    $(window).scroll(function() {
        $('#banner').animate({top:$(window).scrollTop()+"px" },{queue: false, duration: 350});
    });

    $('#banner').click(function() {
        $('#banner').animate({ top:"+=15px",opacity:0 }, "slow");
    });
};
