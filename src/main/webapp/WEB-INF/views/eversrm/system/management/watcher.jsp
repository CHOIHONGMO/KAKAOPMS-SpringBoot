<%--*
  * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
  * @LastModified 17. 11. 3 오전 11:05
  --%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <head>
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <style>
            p {
                line-height: 3px;
            }
        </style>
        <script src="/js/jquery-3.1.1.min.js"></script>
        <script>
            $(document).ready(function() {

//                var patten = /\[.+?\]/g;
//                $('p').each(function(k, v) {
//                    var text = $(v).text();
//                    var logMatch = text.match(patten);
//
//                    if( (text.indexOf('WARN') > -1 || text.indexOf('INFO') > -1 || text.indexOf('ERROR') > -1 ) && logMatch != null ) {
//                        var status = $(v).find('span');
//
//                        if(logMatch[0] != undefined && logMatch[0].indexOf(':') > -1) {
//                            $(v).text('');
//                            $(v).append(text.replace($(status).text(), status[0].outerHTML).replace(logMatch[0], '<span style="color:yellowgreen">' + logMatch[0] + '</span>'));
//                        } else if (logMatch[1] != undefined && logMatch[1].indexOf(':') > -1 && logMatch[1].indexOf('context') == -1) {
//                            $(v).text('');
//                            $(v).append(text.replace($(status).text(), status[0].outerHTML).replace(logMatch[1], '<span style="color:yellowgreen;">' + logMatch[1] + '</span>'));
//                        }
//                    }
//                });

                document.getElementById('terminal').innerHTML = document.getElementById('terminal').innerHTML.replace(/\[([a-zA-Z].*?[:]{1}.*?)\]/gm, '[<span style="color: #9ad717;">$1</span>]');
                $('#terminal').show();

                $('#lastIdx').focus();
                $('#lastIdx').blur();
            });
        </script>
    </head>
</head>
<body style="padding: 15px;">
<pre id="terminal" style="height: 95%; width: 99%; overflow: auto; font-family: Consolas, Inconsolata, Monaco, 'Courier New'; font-size: 12px; color: gray;background-color: #000; border-radius: 3px; padding: 5px; display: none;">${logString}<input type="text" id="lastIdx" style="width: 0; height: 0; border: 0;"></a></pre>
<div style="border-radius: 2px; line-height: 20px; background-color: #ccc; color: #000; font-size: 12px; text-indent: -1px; width: 80px; height: 23px; text-align: center; margin-top: 4px; cursor: pointer;" onclick="location.href='/eversrm/system/management/watcher/view';">새로고침</div>
</body>
</html>