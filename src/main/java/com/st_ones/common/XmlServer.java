package com.st_ones.common;//package com.st_ones.common;
//
//import org.w3c.dom.Document;
//import org.w3c.dom.Node;
//import org.w3c.dom.NodeList;
//import org.xml.sax.InputSource;
//import org.xml.sax.SAXException;
//
//import javax.xml.parsers.DocumentBuilderFactory;
//import javax.xml.parsers.ParserConfigurationException;
//import javax.xml.transform.TransformerException;
//import javax.xml.xpath.XPath;
//import javax.xml.xpath.XPathConstants;
//import javax.xml.xpath.XPathFactory;
//import java.io.*;
//import java.net.InetAddress;
//import java.net.ServerSocket;
//import java.net.Socket;
//
///**
// * Created by azure on 2015-06-10.
// */
//public class XmlServer {
//
//    private static void startServer() throws IOException {
//
//        ServerSocket server = null;
//        Socket socket = null;
//        InputStream is = null;
//        OutputStream os = null;
//        BufferedReader bufferedReader = null;
//        PrintWriter printWriter = null;
//
//        try {
//
//            server = new ServerSocket(8088);
//            socket = server.accept();
//
//            InetAddress inetAddress = server.getInetAddress();
//
//            is = socket.getInputStream();
//            os = socket.getOutputStream();
//            bufferedReader = new BufferedReader(new InputStreamReader(is, "utf-8"));
//            printWriter = new PrintWriter(new OutputStreamWriter(os));
//
//            String msg;
//            StringBuffer xmlBuffer = new StringBuffer();
//            while((msg = bufferedReader.readLine()) != null) {
//                xmlBuffer.append(msg);
//            }
//
//
//            InputSource inputSource = new InputSource(new StringReader(xmlBuffer.toString()));
//            Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(inputSource);
//
//            XPath xpath = XPathFactory.newInstance().newXPath();
//            NodeList nl = (NodeList) xpath.evaluate("//orderdetail/itemdetail", doc, XPathConstants.NODESET);
//            for (int idx = 0; idx < nl.getLength(); idx++) {
//                NodeList item = nl.item(idx).getChildNodes();
//                for (int itemIdx = 0; itemIdx < item.getLength(); itemIdx++) {
//
//                    Node itemAttribute = item.item(itemIdx);
//
//
//                }
//            }
//
//        } catch (Exception e) {
//            getLog().error(e.getMessage(), e);
//        } finally {
//
//            bufferedReader.close();
//            printWriter.close();
//            is.close();
//            os.close();
//            socket.close();
//            server.close();
//
//        }
//    }
//
//    public static void main(String[] args) throws ParserConfigurationException, SAXException, TransformerException, IOException {
//
//        startServer();
//
//    }
//}