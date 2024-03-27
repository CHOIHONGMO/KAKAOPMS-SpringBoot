<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<html>
<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <style>
        .e-error-page-background {
            position: relative;
            width: 100%;
            height: 100%;
        }

        .e-error-body {
            height: 100%;
            width: 100%;
            line-height: 100%;
            background: url(/images/everuxf/error/bg_error.jpg) no-repeat center;
        }

        .e-error-indicate-icon {
            /*outline: 1px solid red;*/
            background: url(/images/everuxf/error/icon_error.png) no-repeat center;
            width: 32px;
            height: 32px;
        }

        .e-error-messagebox {
            /*outline: 1px dotted #999999;*/
            margin: auto;
            padding: 0;
            position: relative;
            top: 45%;
        }

        .e-error-message {
            /*outline: 1px solid blue;*/
            font-family: '돋움';
            font-size: 12px;
            color: #333333;
            letter-spacing: -1px;
            padding: 2px;
            margin: 0;;
        }
    </style>
</head>

<body class="e-error-body">
<div class="e-error-page-background">
    <table class="e-error-messagebox" border="0">
        <tr>
            <td>
                <div class="e-error-indicate-icon"></div>
            </td>
            <td>
                <p class="e-error-message">서버에서 문제가 발생했습니다. 관리자에게 문의해주시기 바랍니다.</p>
            </td>
        </tr>
    </table>
</div>
</body>
</html>