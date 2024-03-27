package com.st_ones.common;//package com.st_ones.common;
//
//import org.apache.commons.lang3.math.NumberUtils;
//import org.w3c.dom.Document;
//import org.w3c.dom.Element;
//import org.xml.sax.SAXException;
//
//import javax.xml.parsers.DocumentBuilder;
//import javax.xml.parsers.DocumentBuilderFactory;
//import javax.xml.parsers.ParserConfigurationException;
//import javax.xml.transform.OutputKeys;
//import javax.xml.transform.Transformer;
//import javax.xml.transform.TransformerException;
//import javax.xml.transform.TransformerFactory;
//import javax.xml.transform.dom.DOMSource;
//import javax.xml.transform.stream.StreamResult;
//import java.io.IOException;
//import java.io.OutputStream;
//import java.net.Socket;
//import java.util.ArrayList;
//import java.util.HashMap;
//import java.util.List;
//import java.util.Map;
//
///**
// * Created by azure on 2015-06-10.
// */
//public class XmlProcessor {
//
//    public static void main(String[] args) throws ParserConfigurationException, SAXException, TransformerException, IOException {
//
//        DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
//        DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
//        Document doc = documentBuilder.newDocument();
//
//        Element rootEl = doc.createElement("root");
//        doc.appendChild(rootEl);
//
//        Element orderHeaderEl = doc.createElement("orderheader");
//
//        appendTextElement(doc, orderHeaderEl, "ordercustomer", "hass");
//        appendTextElement(doc, orderHeaderEl, "ordernumber", "po20150429-53541");
//        appendTextElement(doc, orderHeaderEl, "orderissuedate", "2015-04-30 08:53:16.617");
//
//        Element senderInfoEl = doc.createElement("senderinfo");
//        appendTextElement(doc, senderInfoEl, "sendername", "123");
//        appendTextElement(doc, senderInfoEl, "senderowner", "123");
//        appendTextElement(doc, senderInfoEl, "senderssno", "123");
//        appendTextElement(doc, senderInfoEl, "sendertype1", "123");
//        appendTextElement(doc, senderInfoEl, "sendertype2", "123");
//        appendTextElement(doc, senderInfoEl, "senderzipc", "123");
//        appendTextElement(doc, senderInfoEl, "sendercity", "123");
//        appendTextElement(doc, senderInfoEl, "sendertown", "123");
//        appendTextElement(doc, senderInfoEl, "senderdong", "123");
//        appendTextElement(doc, senderInfoEl, "senderaddr", "123");
//        appendTextElement(doc, senderInfoEl, "senderphone", "123");
//        appendTextElement(doc, senderInfoEl, "sendermobile", "123");
//        appendTextElement(doc, senderInfoEl, "senderfax", "123");
//        appendTextElement(doc, senderInfoEl, "senderemail", "123");
//        orderHeaderEl.appendChild(senderInfoEl);
//
//        Element receiverInfoEl = doc.createElement("receiverinfo");
//        appendTextElement(doc, receiverInfoEl, "receivername", "김원기");
//        appendTextElement(doc, receiverInfoEl, "receiverowner", "선장덕");
//        appendTextElement(doc, receiverInfoEl, "receiverssno", "120");
//        appendTextElement(doc, receiverInfoEl, "receivertype1", "사무및전산용품 ");
//        appendTextElement(doc, receiverInfoEl, "receivertype2", "도매업");
//        appendTextElement(doc, receiverInfoEl, "receiverzipc", "135");
//        appendTextElement(doc, receiverInfoEl, "receivercity", "서울시");
//        appendTextElement(doc, receiverInfoEl, "receivertown", "강남구");
//        appendTextElement(doc, receiverInfoEl, "receiverdong", "언주로 ");
//        appendTextElement(doc, receiverInfoEl, "receiveraddr", "건설회관 ");
//        appendTextElement(doc, receiverInfoEl, "receiverphone", "0x");
//        appendTextElement(doc, receiverInfoEl, "receivermobile", "0x456");
//        appendTextElement(doc, receiverInfoEl, "receiverfax", "0x");
//        appendTextElement(doc, receiverInfoEl, "receiveremail", "xxx");
//        appendTextElement(doc, receiverInfoEl, "receiverdept", "it");
//        appendTextElement(doc, receiverInfoEl, "receivermemo", "");
//        orderHeaderEl.appendChild(receiverInfoEl);
//
//        rootEl.appendChild(orderHeaderEl);
//
//        Element orderDetailEl = doc.createElement("orderdetail");
//        List<Map<String, Object>> itemDetailList = new ArrayList<Map<String, Object>>();
//
//        // dummy
//        Map<String, Object> dummyItemData = new HashMap<String, Object>();
//        dummyItemData.put("lineno", "1");
//        dummyItemData.put("idcode", "t2013022146903");
//        dummyItemData.put("idvendorcode", "803761");
//        dummyItemData.put("iddesc", "오픈휴지통 ");
//        dummyItemData.put("idunit", "ea");
//        dummyItemData.put("quantity", "1");
//        dummyItemData.put("qtyprice", "2000");
//        dummyItemData.put("qtyvendorprice", "1800");
//        dummyItemData.put("midtotal", "2000");
//        dummyItemData.put("midvendortotal", "1800");
//        itemDetailList.add(dummyItemData);
//
//        dummyItemData = new HashMap<String, Object>();
//        dummyItemData.put("lineno", "2");
//        dummyItemData.put("idcode", "t2013022146903");
//        dummyItemData.put("idvendorcode", "803761");
//        dummyItemData.put("iddesc", "오픈휴지통 #2");
//        dummyItemData.put("idunit", "ea");
//        dummyItemData.put("quantity", "5");
//        dummyItemData.put("qtyprice", "2000");
//        dummyItemData.put("qtyvendorprice", "1800");
//        dummyItemData.put("midtotal", "2000");
//        dummyItemData.put("midvendortotal", "1800");
//        itemDetailList.add(dummyItemData);
//
//        int midTotalSum = 0;
//        int midVendorTotalSum = 0;
//        for (Map<String, Object> item : itemDetailList) {
//
//            Element itemDetailEl = doc.createElement("itemdetail");
//            appendTextElement(doc, itemDetailEl, "lineno", (String)item.get("lineno"));
//            appendTextElement(doc, itemDetailEl, "idcode", (String)item.get("idcode"));
//            appendTextElement(doc, itemDetailEl, "idvendorcode", (String)item.get("idvendorcode"));
//            appendTextElement(doc, itemDetailEl, "iddesc", (String)item.get("iddesc"));
//            appendTextElement(doc, itemDetailEl, "idunit", (String)item.get("idunit"));
//            appendTextElement(doc, itemDetailEl, "quantity", (String)item.get("quantity"));
//            appendTextElement(doc, itemDetailEl, "qtyprice", (String)item.get("qtyprice"));
//            appendTextElement(doc, itemDetailEl, "qtyvendorprice", (String)item.get("qtyvendorprice"));
//            appendTextElement(doc, itemDetailEl, "midtotal", (String)item.get("midtotal"));
//            appendTextElement(doc, itemDetailEl, "midvendortotal", (String)item.get("midvendortotal"));
//            orderDetailEl.appendChild(itemDetailEl);
//
//            midTotalSum = midTotalSum + NumberUtils.toInt((String) item.get("midtotal"));
//            midVendorTotalSum = midVendorTotalSum + NumberUtils.toInt((String) item.get("midvendortotal"));
//        }
//
//        rootEl.appendChild(orderDetailEl);
//
//        Element priceDetailEl = doc.createElement("pricedetail");
//        appendTextElement(doc, priceDetailEl, "totalprice", String.valueOf(midTotalSum));
//        appendTextElement(doc, priceDetailEl, "totalvendorprice", String.valueOf(midVendorTotalSum));
//        orderDetailEl.appendChild(priceDetailEl);
//
//        Socket socket = new Socket("localhost", 8088);
//        OutputStream outputStream = socket.getOutputStream();
//
//        TransformerFactory transformerFactory = TransformerFactory.newInstance();
//        Transformer transformer = transformerFactory.newTransformer();
//        transformer.setOutputProperty(OutputKeys.VERSION, "1.0");
//        transformer.setOutputProperty(OutputKeys.ENCODING, "utf-8");
//        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
//        DOMSource source = new DOMSource(doc);
//        StreamResult result = new StreamResult(outputStream);
//
//        transformer.transform(source, result);
//
//        outputStream.close();
//    }
//
//    private static void appendTextElement(Document doc, Element containerElement, String name, String value) throws ParserConfigurationException {
//
//        Element te = doc.createElement(name);
//        te.appendChild(doc.createTextNode(value));
//        containerElement.appendChild(te);
//    }
//
//}
