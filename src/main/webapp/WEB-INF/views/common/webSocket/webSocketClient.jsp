<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <link href="/css/chatting/chatting.css" rel="stylesheet">
    <script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <script src="/js/websocket/socket.io.js"></script>

    <script>
        var domain = $(location).attr('host');
        var port = $(location).attr('port');
        var dp = domain.replace(port, '');
        var socket = io.connect("http://"+dp+'50000');

        // on connection to server, ask for user's name with an anonymous callback
        socket.on('connect', function () {
            if('${param.roomNm}' != '') {
                socket.emit('adduser', '${ses.userNm}', '${param.roomNm}');
            } else {
                // call the server-side function 'adduser' and send one parameter (value of prompt)
                socket.emit('adduser', '${ses.userNm}', 'ALL', 'ALL');

                // Mac Address
                socket.emit('macAddress');

                $('#roomNm').val('ALL');
            }
        });

        // listener, whenever the server emits 'updatechat', this updates the chat body
        socket.on('updatechat', function (username, data, flag) {
            if(flag == '1') {
                $('#conversation').append('<b style="color: red">*' + username + ':</b><span class="fontStyle">' + data + '</span><br>');
            } else {
                $('#conversation').append('<b >' + username + ':</b><span class="fontStyle">' + data + '</span><br>');
            }
            $('#scrollHeight').scrollTop($('#conversation').prop('scrollHeight'));

            // 채팅창 접속, 종료 메시지가 나올 경우 제외하고 채팅창 호출
            if(data.indexOf('connected') == -1) {
                var chatFlag = $(parent.document).find('#chatRoom').css('display');

                if(chatFlag == 'none')
                    $(parent.document).find('#chatRoom').css('display', 'block');
            }
        });

        // listener, whenever the server emits 'updaterooms', this updates the room the client is in
        socket.on('updaterooms', function (rooms, current_room) {
            /*
             $('#rooms').empty();
             $.each(rooms, function (key, value) {
             if (value == current_room) {
             $('#rooms').append('<div>' + value + '</div>');
             }
             else {
             $('#rooms').append('<div><a href="#" onclick="switchRoom(\'' + value + '\')">' + value + '</a></div>');
             }
             });
             */
        });

        socket.on('macAddress', function (ip, mac) {
            console.log(ip);
            console.log(mac);
            //$.post("/macAddress", { ip: ip, macAddress: mac });
        });

        socket.on('userList', function (usernames) {
            var userList = sortObject(usernames);

            var cnt = 0;
            var user = "";

            for(var idx in userList) {

                if('${ses.userNm}' != userList[idx]){

                    if ((cnt + 1) != Object.keys(userList).length) {
                        user += '<input type="checkbox" value="' + userList[idx] + '">' + userList[idx] + '</input><br>';
                    } else {
                        user += '<input type="checkbox" value="' + userList[idx] + '">' + userList[idx] + '</input>';
                    }

                    cnt++;
                }
            }

            $('#userList').html(user);

            $('#scrollHeight2').scrollTop($('#userList').prop('scrollHeight'));

            if('${param.roomNm}' != '') {
                $('input[type="checkBox"]').each(function(a,b) {
                    b.checked = true;
                });
            }
        });

        socket.on('newChat', function (roomNm) {
            newChat(roomNm);
        });

        function switchRoom(room) {
            socket.emit('switchRoom', room);
        }

        // on load of page
        $(function () {
            // when the client clicks SEND
            $('#datasend').click(function () {
                var message = $('#data').val();
                $('#data').val('');

                chatMsg(message);
            });

            // when the client hits ENTER on their keyboard
            $('#data').keypress(function (e) {
                if (e.which == 13) {
                    $(this).blur();
                    $('#datasend').focus().click();
                }
            });

            $('#file').click(function() {
                var url = "/common/websocket/fileManager/view";
                window.open(url, "File Manager", "width=550,height=262,scrollbars=yes,resizeable=no,left=150,top=150");
            });

            $('#close').click(function() {
                console.log(window.opener);
                if(window.opener == null) {
                    $(parent.document).find('#chatRoom').css('display', 'none');
                } else {
                    window.close();
                }
            });

            $('#newChat').click(function() {

                var checkFlag = $('input[type="checkBox"]').is(':checked');

                if(checkFlag == false) {
                    return alert("사용자를 선택하여 주시기 바랍니다.");
                }

                var na = Math.floor(Math.random() * 100000) + 1;

                // 체크 된 사용자 추출
                $('input[type="checkBox"]').each(function(a,b) {
                    if(b.checked == true) {
                        //var msg = '<a href="javascript:newChat('+'\''+ na +'\''+');">초대</a>';
                        //chatMsg(msg)

                        // 상대 팝업창
                        socket.emit('newChat', na, b.value);
                        // 본인 팝업창
                        newChat(na);
                    }
                });

                //newChat(checkUser);

            });

        });

        function newChat(roomNm) {
            var url = "/common/websocket/webSocketClient/view";
            var form = document.form;
            var title = roomNm;

            window.open('', title, "width=531,height=340,scrollbars=yes,resizeable=no,left=150,top=150");

            form.userNm.value = '${ses.userNm}';
            form.roomNm.value = roomNm;
            form.action = url;
            form.target = title;
            form.submit();
        }

        // 사용자 리스트 정렬
        function sortObject(o)
        {
            var sorted = {},
                    key, a = [];

            // 키이름을 추출하여 배열에 집어넣음
            for (key in o) {
                if (o.hasOwnProperty(key)) a.push(key);
            }
            // 키이름 배열을 정렬
            a.sort();

            // 정렬된 키이름 배열을 이용하여 object 재구성
            for (key=0; key<a.length; key++) {
                sorted[a[key]] = o[a[key]];
            }

            return sorted;
        }

        function fileList(data) {
            var checkFlag = $('input[type="checkBox"]').is(':checked');

            if(checkFlag == false) {
                return alert("파일을 전송할 사용자를 지정하여 주시기 바랍니다.");
            }

            chatMsg(JSON.parse(data));
        }

        function chatMsg(message) {
            var checkFlag = $('input[type="checkBox"]').is(':checked');

            if(checkFlag == true) {
                var userNm = [];

                $('input[type="checkBox"]').each(function(a,b) {
                    if(b.checked == true) {
                        userNm.push(b.value);
                    }
                });

                socket.emit('sendchat', {to: userNm, msg:message});
                //socket.emit('sendchat', {to:$('#to').val(), msg:message});
            } else {
                if('${ses.userType}' == 'B' && '${ses.superUserFlag}' == '1')
                    socket.emit('sendchat', {to: 'ALL', msg:message});
            }

            $('#data').focus();
        }

        function closePage( event ){
            if( event.clientY < 0 ){
                alert("close Page1");
            }
        }

    </script>
</head>
<body onbeforeunload="closePage(event)">
<form name="form" method="post">
    <input type="hidden" id="roomNm" name="roomNm" value="${param.roomNm}">
    <input type="hidden" id="userNm" name="userNm" value="${param.userNm}">
</form>

<div id="mainDiv">
    <!-- 채팅방 사용 시
    <div style="float:left;width:100px;border-right:1px solid black;height:300px;padding:10px;overflow:auto;">
        <b>ROOMS</b>

        <div id="rooms"></div>
    </div>
    -->
    <div style="float: left;">
        <div id="scrollHeight">
            <div id="conversation"></div>
        </div>
        <div style="padding: 5px 0 0 0;">
            <%--
            <select id="to" style="width: 56px;">
                <option value="ALL">ALL</option>
            </select>
            --%>
            <input id="data" name="data"/>
            <input class="btnCls" type="button" id="datasend" value="send"/>
            <input class="btnCls" type="button" id="file" value="File"/>
            <input class="btnCls" type="button" id="newChat" value="nChat"/>
            <input class="btnCls" type="button" id="close" value="Close"/>
        </div>
    </div>
    <div id="scrollHeight2">
        <div id="userList"></div>
    </div>
</div>
</body>
</html>