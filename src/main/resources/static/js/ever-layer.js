var layer = function() {};

layer.getLayerSample = function() {
    var sample =
        $('<div id="layerPop" class="pop-layer">\n' +
        '  <div class="pop-container">\n' +
        '    <div class="pop-conts">\n' +
        '      <p class="ctxt mb20">\n' +
        '      </p>\n' +
        '      <div class="btn-r">\n' +
        '        <a href="#" class="btn-layerClose">Close</a>\n' +
        '      </div>\n' +
        '    </div>\n' +
        '  </div>\n' +
        '</div>');
    return sample;
};

layer.getDimLayerSample = function() {
    var dimSample =
        $('<div class="dim-layer">\n' +
        '  <div class="dimBg"></div>\n' +
        '  <div id="dimLayerPop" class="pop-layer">\n' +
        '    <div class="pop-container">\n' +
        '      <div class="pop-conts">\n' +
        '        <p class="ctxt mb20">\n' +
        '        </p>\n' +
        '        <div class="btn-r">\n' +
        '          <a href="#" class="btn-layerClose">Close</a>\n' +
        '        </div>\n' +
        '      </div>\n' +
        '    </div>\n' +
        '  </div>\n' +
        '</div>');
    return dimSample;
};

layer.openPopup = function(el) {
    var $el = $(el);        //���̾��� id�� $el ������ ����
    var isDim = $el.prev().hasClass('dimBg');   //dimmed ���̾ �����ϱ� ���� boolean ����

    isDim ? $('.dim-layer').fadeIn() : $el.fadeIn();

    var $elWidth = ~~($el.outerWidth()),
        $elHeight = ~~($el.outerHeight()),
        docWidth = $(document).width(),
        docHeight = $(document).height();

    // ȭ���� �߾ӿ� ���̾ ����.
    if ($elHeight < docHeight || $elWidth < docWidth) {
        $el.css({
            marginTop: -$elHeight /2,
            marginLeft: -$elWidth/2
        })
    } else {
        $el.css({top: 0, left: 0});
    }

    $el.find('a.btn-layerClose').click(function(){
        isDim ? $('.dim-layer').fadeOut() : $el.fadeOut(); // �ݱ� ��ư�� Ŭ���ϸ� ���̾ ������.
        return false;
    });

    $('.layer .dimBg').click(function(){
        $('.dim-layer').fadeOut();
        return false;
    });

    $el.draggable();
};