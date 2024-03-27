<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
    <title>File Manager</title>
    <link href="/css/chatting/chatting.css" rel="stylesheet">
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.8/jquery.min.js"></script>
    <script src="/js/websocket/binary.js"></script>
    <script src="/js/websocket/socket.io.js"></script>
    <script>
        var domain = $(location).attr('host');
        var port = $(location).attr('port');
        var ip = domain.replace(port, '');

        var client = new BinaryClient("ws://"+ip+'50001');
        var socket = io.connect("http://"+ip+'50002');

        client.on('open', function () {
            var box = $('#dropBox');
            box.on('dragenter', doNothing);
            box.on('dragover', doNothing);
            box.on('drop', function (e) {
                e.originalEvent.preventDefault();
                var files = e.originalEvent.dataTransfer.files;

                for (var i = 0; i < files.length; i++) {
                    file = files[i];

                    // Add to list of uploaded files
                    $('#dropBox').append($('<a title="'+file.name+'" href="http://'+ip+'50001/'+file.name+'" download></a><br>').text(file.name));

                    // `client.send` is a helper function that creates a stream with the
                    // given metadata, and then chunks up and streams the data.
                    var stream = client.send(file, { name: file.name, size: file.size, userId: '${ses.userId}' });

                    // Print progress
                    var tx = 0;
                    stream.on('data', function (data) {
                        var percent = Math.round(tx += data.rx * 100);

                        $('#progress').text(percent + '% complete');

                        if(percent == (files.length * 100))
                            location.reload();
                    });
                }

                scrollerSet();
            });
        });

        // Deal with DOM quirks
        function doNothing(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        $(document).ready(function() {
            socket.emit('fileList', '${ses.userId}');

            socket.on('fileList', function (data) {
                data = texDupArr(data);

                for (var i = 0; i < data.length; i++) {
                    $('#dropBox').append('<input type="checkbox" value="'+data[i]+'"/>').append($('<a title="'+data[i]+'" href="http://'+ip+'50002/'+data[i]+'" download></a>').text(data[i])).append($('<a class="delLink" title="삭제" href="javascript:rowDel('+'\''+ data[i] +'\''+')"></a><br>').text("[삭제]"));

                    // 커지는 화면만큼 heigth 증가 그렇지 않으면 dragdrop 영역이 안잡힘
                    if($('#dropBox').height() > 200)
                        $('#dropBox').css('height', (data.length * 23));
                }

                scrollerSet();
            });

            socket.on('delFile', function () {
                location.reload();
            });

            $('#sel').click(function() {
                var linkList = "";

                $('input[type="checkBox"]').each(function(a,b) {

                    if (b.checked == true) {
                        var link = $('div a[title="'+ b.value+'"]');

                        linkList += link[0].outerHTML+'<br>';
                    }
                });

                opener['fileList'](JSON.stringify(linkList));

                window.close();
            });
        });

        function scrollerSet() {
            // 스크롤 높이에 맞게 따라가기
            $('#boxHeight').scrollTop($('#dropBox').prop('scrollHeight'));
        }

        // 배열내에 중복된 요소 제거함수
        function texDupArr(arr) {
            for(var i=0; i<arr.length; i++) {
                var checkDobl = 0;
                for(var j=0; j<arr.length; j++) {
                    if(arr[i] != arr[j]) {

                    } else {
                        checkDobl++;
                        if(checkDobl>1){
                            spliced = arr.splice(j,1);
                        }
                    }
                }
            }
            return arr;
        }

        function rowDel(fileName) {

            socket.emit('delFile', fileName);
        }
    </script>
</head>
<body>
<div class="box" style="height: 25px; text-align: center;">Drag files here</div>
<div id="boxHeight" class="box">
    <div id="dropBox"></div>
</div>
<div>
    <div style="float: right;"><input class="btnCls" type="button" id="sel" value="선택" /></div>
    <div id="progress" align="center">0% complete</div>
</div>

</body>
</html>