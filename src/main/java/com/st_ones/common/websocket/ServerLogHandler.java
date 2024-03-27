package com.st_ones.common.websocket;
//
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//import org.springframework.nosession.socket.CloseStatus;
//import org.springframework.nosession.socket.TextMessage;
//import org.springframework.nosession.socket.WebSocketSession;
//import org.springframework.nosession.socket.handler.TextWebSocketHandler;
//
///**
// * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
// * @LastModified 17. 11. 3 오후 1:24
// */
//public class ServerLogHandler extends TextWebSocketHandler {
//
//    private Logger logger = LoggerFactory.getLogger(getClass());
//
//    @Override
//    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
//        logger.info("{}", session.getId());
//        super.afterConnectionEstablished(session);
//    }
//
//    @Override
//    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
//        session.sendMessage(new TextMessage(message.getPayload()));
//    }
//
//    @Override
//    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
//        logger.info("{}", status.getReason());
//        super.afterConnectionClosed(session, status);
//    }
//
//
//}
