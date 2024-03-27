package com.st_ones.common.websocket;

import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping(value = "/common/webSocket/")
public class WebSocketController {

    @RequestMapping(value="webSocketClient/view")
    public String webSocketClient(EverHttpRequest req) throws Exception {

        /*
        String userAgent = req.getHeader("User-Agent");
        boolean ie = (userAgent.indexOf("MSIE") > -1) || (userAgent.indexOf("Trident") > -1);

        req.setAttribute("ieFlag", ie);
        */

        return "/common/webSocket/webSocketClient";
    }

    @RequestMapping(value="fileManager/view")
    public String fileManager(EverHttpRequest req) throws Exception {

        return "/common/webSocket/fileManager";
    }
}