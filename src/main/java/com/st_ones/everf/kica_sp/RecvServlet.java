package com.st_ones.everf.kica_sp;

import com.st_ones.common.util.SpringContextUtil;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.util.StringUtil;
import com.st_ones.evermp.vendor.cont.service.CT0600Service;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kica.sgic.util.SGIxLinker;
import kica.sgic.util.XmlToData;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class RecvServlet extends HttpServlet {

    private String configpath = "";
    private CT0600Service ct0600Service;

    public void init(ServletConfig config) throws ServletException {

        super.init(config);
        this.configpath = PropertiesManager.getString("sgic_recvinfo_conf");
    }

    public synchronized void service(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
//		req.setCharacterEncoding("UTF-8");
//		res.setContentType("text/html;charset=UTF-8");
        System.out.println("req.getCharacterEncoding()---------------" + req.getCharacterEncoding());
        System.out.println("res.getCharacterEncoding()---------------" + res.getCharacterEncoding());
        System.out.println();
        SGIxLinker xLinker = new SGIxLinker(this.configpath, this.getServletName(), true); // true:파일로 수신, false:Data로 수신

        try {
            boolean isOK = xLinker.doRecvProcess((javax.servlet.http.HttpServletRequest) req, (javax.servlet.http.HttpServletResponse) res);
            if (!isOK) {
                super.getServletContext().log("isOK is false");
                throw new Exception("정보인증 정보수신 API 오류입니다 : [" + xLinker.getErrorCode() + "] : " + xLinker.getErrorMsg());
            }

            String recvDocCode = xLinker.getRecvDocCode(); // 전문코드
            String recvXmlDoc = xLinker.getRecvXmlData(); // 전문데이터

            if (StringUtil.isEmpty(recvXmlDoc)) {
                recvXmlDoc = xLinker.getDecXmlPath();    // 수신전문경로 + 파일명
            }
            String responseXml = "";

            XmlToData xmlToData = new XmlToData(PropertiesManager.getString("sgic_templates_path"), recvDocCode, recvXmlDoc);
            if (xmlToData.getErrorCode() != 0) {
                throw new Exception("정보인증 수신 데이터 오류입니다 : " + xmlToData.getErrorMsg());
            } else {
                String headMesgType = xmlToData.getData("head_mesg_type"); // 문서구분(CONGUA:계약보증, PREGUA:선급보증, FLRGUA:하자보증, BIDGUA:입찰보증)
                String bondNumbText = xmlToData.getData("bond_numb_text"); // 보증보험 증권번호
                String bondBegnDate = xmlToData.getData("bond_begn_date"); // 보증증권 시작일자
                String bondFnshDate = xmlToData.getData("bond_fnsh_date"); // 보증증권 종료일자
                String contNumText = ""; // 계약번호
                if ("BIDGUA".equals(headMesgType)) {
                    contNumText = xmlToData.getData("bidd_numb_text"); // 입찰보증보험 신청번호
                } else {
                    contNumText = xmlToData.getData("cont_numb_text"); // 계약,선급,하자 보증보험 신청번호
                }
                Map<String, String> contMap = new HashMap<>();
                contMap.put("head_mesg_type", headMesgType);
                contMap.put("bond_numb_text", bondNumbText);
                contMap.put("bond_begn_date", bondBegnDate);
                contMap.put("bond_fnsh_date", bondFnshDate);
                String[] contArr = contNumText.split("-");
                String contNum = contArr[0]; // 계약번호
                String contCnt = contArr[1]; // 계약차수
                contMap.put("contNumText", contNumText);
                contMap.put("CONT_NUM", contNum);
                contMap.put("CONT_CNT", contCnt);
                contMap.put("recvDocCode", recvDocCode); //구분값
                ct0600Service = SpringContextUtil.getBean(CT0600Service.class);

                if (recvDocCode.equals("CONGUA") || recvDocCode.equals("PREGUA") || recvDocCode.equals("FLRGUA")) {
                    //중복 체크
                    int overlapCnt = ct0600Service.overlapRecvInfo(contMap);
                    if (overlapCnt == 0) {
                        if ((recvDocCode != null) && (!recvDocCode.equals(""))
                                && (recvXmlDoc != null) && (!recvXmlDoc.equals(""))) {
                            contMap.put("status", "SA"); //수용
                            ct0600Service.updateRecvSaInfo(contMap);
                            responseXml = xLinker.responseAck("SA", "업체정보 수신업무가 정상적으로 수행되었습니다  ", bondNumbText);

                        } else {
                            responseXml = xLinker.responseAck("SR", "실행중 오류가 발생하였습니다 : " + bondNumbText, bondNumbText);
                        }
                    } else {
                        responseXml = xLinker.responseAck("SR", "중복 처리된건 입니다. : " + bondNumbText, bondNumbText);
                    }

                }
            }


            // 오류로 인한 전송전문 전송
            if (xLinker.sendResponse((javax.servlet.http.HttpServletResponse) res, responseXml)) {
                System.out.println(this.getServletName() + " service finished SUCCESSFULLY!!!");
            } else {
                System.out.println(this.getServletName() + " service FAILED!!!!");
            }
            System.out.println("responseXml---------------\n" + responseXml);

            ServletOutputStream output = null;
            try {
//				output = res.getOutputStream();
//				output.write(responseXml.getBytes()) ;
//				output.flush() ;
                if (output != null) output.close();
            } catch (IOException e) {
                System.out.println(this.getServletName() + " service FAILED!!!!");
                e.printStackTrace();
                throw new Exception("응답서 전송중 오류가 발생하였습니다.:" + e.toString());
            }
            System.out.println(this.getServletName() + " service finished SUCCESSFULLY!!!");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {

        }
    }

    public void destroy() {
        super.destroy();
    }

    public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        System.out.println("doGet Start======>");
        service(req, res);
    }

    public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        System.out.println("doPost Start======>");
        service(req, res);
    }
}
