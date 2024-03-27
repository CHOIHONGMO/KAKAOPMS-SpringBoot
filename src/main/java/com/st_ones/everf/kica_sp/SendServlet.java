package com.st_ones.everf.kica_sp;

import com.st_ones.common.util.SpringContextUtil;
import com.st_ones.common.util.clazz.EverDate;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import com.st_ones.evermp.vendor.cont.service.CT0600Service;
import io.netty.util.internal.StringUtil;
import jakarta.servlet.ServletException;
import kica.sgic.util.DataToXml;
import kica.sgic.util.SGIxLinker;
import kica.sgic.util.XmlToData;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Service(value="SendServlet")
public class SendServlet {

	private String configpath = ""; // 서울보증 연결정보 경로
	private String strHeadFuncCode = ""; // 문서기능 : 9(원본), 1(취소), 53(테스트)
	private String strSGICCode = ""; // 전문수신기관
	private String strSGICSenderCode = ""; // 전문송신기관

	private CT0600Service ct0600Service;

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void service(EverHttpRequest req, EverHttpResponse res) throws ServletException, IOException {
		
    	this.configpath = PropertiesManager.getString("sgic_sendinfo_conf");
        this.strHeadFuncCode = PropertiesManager.getString("sgic_headfunccode_flag");
        this.strSGICCode = PropertiesManager.getString("sgic_code");
        this.strSGICSenderCode = PropertiesManager.getString("sgic_sender_code");
    	req.setCharacterEncoding("UTF-8");
    	res.setContentType("text/html; charset=UTF-8");
    	System.out.println(req.getContentType());

    	String SYSDATE = EverDate.getDateString();
    	String SYSTIME = EverDate.getTimeString();

    	System.out.println("SYSDATE ::::: " + SYSDATE);
    	System.out.println("SYSTIME ::::: " + SYSTIME);
    	System.out.println("SGI_GUBUN                    ::::: " + req.getParameter("SGI_GUBUN"));						//통보서[CONINF], 최종응답서[RBONGU] 구분
    	System.out.println("MENGEL_END_DATE              ::::: " + req.getParameter("MENGEL_END_DATE_SGI"));			//하자보증 완료일자(=계약종료일자+하자보증기간)
    	System.out.println("MENGEL_START_DATE            ::::: " + req.getParameter("MENGEL_START_DATE_SGI"));			//하자보증 시작일자(=계약종료일자)
    	System.out.println("MENGEL_WARRANTY_AMT          ::::: " + req.getParameter("MENGEL_WARRANTY_AMT_SGI"));		//하자이행 보증금액
    	System.out.println("CONT_NO                      ::::: " + req.getParameter("CONT_NUM_SGI"));					//계약번호
    	System.out.println("CONT_SEQ                     ::::: " + req.getParameter("CONT_CNT_SGI"));					//계약차수
    	System.out.println("CONT_TITLE                   ::::: " + req.getParameter("CONT_TITLE_SGI"));					//계약명
    	System.out.println("CONT_DATE                    ::::: " + req.getParameter("CONT_DATE_SGI"));					//계약체결일자
    	System.out.println("SORDER_AMT                   ::::: " + req.getParameter("SORDER_AMT_SGI"));					//매입금액
    	System.out.println("SUPPLY_AMT                   ::::: " + req.getParameter("SUPPLY_AMT_SGI"));					//매출금액
    	System.out.println("CONT_START_DATE              ::::: " + req.getParameter("CONT_START_DATE_SGI"));			//계약시작일자
    	System.out.println("CONT_END_DATE                ::::: " + req.getParameter("CONT_END_DATE_SGI"));				//계약완료일자
    	System.out.println("CONT_WARRANTY_AMT_SGI        ::::: " + req.getParameter("CONT_WARRANTY_AMT_SGI"));			//계약이행 보증금액
    	System.out.println("CONT_WARRANTY_AMT_RATE_SGI   ::::: " + req.getParameter("CONT_WARRANTY_AMT_RATE_SGI"));	    //계약이행 보증율(%)
    	System.out.println("MENGEL_WARRANTY_AMT_RATE_SGI ::::: " + req.getParameter("MENGEL_WARRANTY_AMT_RATE_SGI"));	//하자이행 보증율(%)
    	System.out.println("FIRST_SECURITIES_AMT_SGI     ::::: " + req.getParameter("FIRST_SECURITIES_AMT_SGI"));		//선급이행보증금액
    	System.out.println("FIRST_SECURITIES_AMT_RATE_SGI::::: " + req.getParameter("FIRST_SECURITIES_AMT_RATE_SGI"));	//선급이행 보증율(%)
    	System.out.println("IRS_NO_VENDOR                ::::: " + req.getParameter("IRS_NO_VENDOR"));					//공급사 사업자번호
    	System.out.println("CONT_ISU_BILL_FLAG_SGI       ::::: " + req.getParameter("CONT_ISU_BILL_FLAG_SGI"));			//계약이행보증 발급여부
    	System.out.println("FIRST_ISU_BILL_FLAG_SGI      ::::: " + req.getParameter("FIRST_ISU_BILL_FLAG_SGI"));		//선급보증 발급여부
    	System.out.println("MENGEL_ISU_BILL_FLAG_SGI     ::::: " + req.getParameter("MENGEL_ISU_BILL_FLAG_SGI"));		//하자이행보증 발급여부
    	System.out.println("VENDOR_NAME_LOC     		 ::::: " + req.getParameter("VENDOR_NAME_LOC"));				//기관명
    	System.out.println("CEO_NAME_LOC     			 ::::: " + req.getParameter("CEO_NAME_LOC"));					//대표자명
    	System.out.println("RBONGU_STATUS     			 ::::: " + req.getParameter("RBONGU_STATUS"));					//통보서 : 접수(TA), 거부(TR)
    	System.out.println("CONT_INSU_NUM     			 ::::: " + req.getParameter("CONT_INSU_NUM"));					//계약이행보증번호 I/F
    	System.out.println("AMT_INSU_NUM     			 ::::: " + req.getParameter("AMT_INSU_NUM"));					//선급이행보증번호 I/F
    	System.out.println("AS_INSU_NUM     			 ::::: " + req.getParameter("AS_INSU_NUM"));					//하자이행보증번호 I/F
    	System.out.println("INSU_STATUS     			 ::::: " + req.getParameter("INSU_STATUS"));					//계약상태값
    	System.out.println("GUBN     					 ::::: " + req.getParameter("GUBN"));							//구분자
    	System.out.println(this.configpath);
    	String CONT_ISU_BILL_FLAG_SGI	= req.getParameter("CONT_ISU_BILL_FLAG_SGI");	//계약이행증권유무 O/X
    	String FIRST_ISU_BILL_FLAG_SGI	= req.getParameter("FIRST_ISU_BILL_FLAG_SGI");	//선급이행증권유무 O/X
    	String MENGEL_ISU_BILL_FLAG_SGI	= req.getParameter("MENGEL_ISU_BILL_FLAG_SGI");	//하자이행증권유무 O/X
    	String GUBN						= req.getParameter("GUBN");					    // 업데이트시 구분값
    	String INSU_STATUS				= req.getParameter("INSU_STATUS");			    //계약상태값
    	/*계약자정보*/
    	String VENDOR_NAME_LOC	= req.getParameter("VENDOR_NAME_LOC");	//기관명
    	String CEO_NAME_LOC		= req.getParameter("CEO_NAME_LOC");		//대표자명
    	String IRS_NO_VENDOR	= req.getParameter("IRS_NO_VENDOR");	//사업자번호

    	String cont_seq			= req.getParameter("CONT_CNT_SGI");		//계약차수
    	String workGubun 		= ""; // 신규 또는 변경(배서) 업무구분 - 10:신규,20:연장,60:증액,62:연장증액,70:감액,90:기타(그 외)
    	String hostCode 		= ""; // 기존에 발행되었던 신규(원) 증권번호(18자리)
    	// 변경계약일 경우 업무구분 처리

    	//	통보서[CONINF], 최종응답서[RBONGU] 구분
    	//  통보서 : 계약, 선급, 이행
    	String SGI_GUBUN = req.getParameter("SGI_GUBUN");
    	//	통보서 : 접수, 거부
    	String RBONGU_STATUS = req.getParameter("RBONGU_STATUS");

    	/**
    	 * 계약이행보증(CONGUA)
    	 * */
    	// 	보험개시일자 : CONT_START_DATE[계약보증기간(FROM)]
    	String CONT_START_DATE = req.getParameter("CONT_START_DATE_SGI");
        //	보험종료일자 : CONT_END_DATE[계약보증기간(TO)]
    	String CONT_END_DATE = req.getParameter("CONT_END_DATE_SGI");
    	//  보증금율 : CONT_WARRANTY_AMT_RATE[계약이행보증금액율]
        String CONT_WARRANTY_AMT_RATE = req.getParameter("CONT_WARRANTY_AMT_RATE_SGI");

        /**
         * 이행선금보증서(PREGUA)
         * */
        //	보험종료일자[선급보증기간(TO)]
    	String FIRST_END_DATE = req.getParameter("CONT_END_DATE_SGI");    	//계약종료일자를 넣는다.
        //	보험가입금액[선급이행보증금액]
    	String FIRST_SECURITIES_AMT = req.getParameter("FIRST_SECURITIES_AMT_SGI");
    	//  보증금율[선급이행보증금액율]
        String FIRST_SECURITIES_AMT_RATE = req.getParameter("FIRST_SECURITIES_AMT_RATE_SGI");

        //	선급지급예정일 계산
		DateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
		Date preGiveDate = null;
		try{
			preGiveDate = dateFormat.parse(CONT_START_DATE);
		}catch(ParseException e){
			e.printStackTrace();
		}

		// 날짜 더하기 (계약시작일자+7일)
        Calendar cal = Calendar.getInstance();
        cal.setTime(preGiveDate);
        cal.add(Calendar.DATE, 7);
        String PREGIVEDATE = dateFormat.format(cal.getTime());

    	/**
    	 * 이행하자보증서(FLRGUA)
    	 * */
        // 보험개시일자 : MENGEL_START_DATE[하자보증기간(FROM)]
    	String MENGEL_START_DATE = req.getParameter("MENGEL_START_DATE_SGI");
        // 보험종료일자 : MENGEL_END_DATE[하자보증기간(TO)]
    	String MENGEL_END_DATE = req.getParameter("MENGEL_END_DATE_SGI");
        // 보험가입금액 : MENGEL_WARRANTY_AMT[하자이행보증금액]
    	String MENGEL_WARRANTY_AMT = req.getParameter("MENGEL_WARRANTY_AMT_SGI");
    	// 보증금율 : MENGEL_WARRANTY_AMT_RATE[하자이행보증금액율]
        String MENGEL_WARRANTY_AMT_RATE = req.getParameter("MENGEL_WARRANTY_AMT_RATE_SGI");

        /**
         * 공통 파라미터
         * */
        // 계약금액
    	String CONT_WARRANTY_AMT = req.getParameter("CONT_WARRANTY_AMT_SGI");
    	// 계약건명 : CONT_TITLE[계약서명(품명)]
    	String CONT_TITLE = req.getParameter("CONT_TITLE_SGI");
        // 준공예정일 : 컬럼이 없어서 일단 [계약일자]값으로 테스트
    	String CONT_DATE_1 = req.getParameter("CONT_DATE_SGI");
        // 계약체결일자 : CONT_DATE[계약일자]
    	String CONT_DATE = req.getParameter("CONT_DATE_SGI");
    	// 계약번호 : CONT_NUM[계약번호] + CONT_CNT[계약차수]
    	String CONT_NUM = req.getParameter("CONT_NUM_SGI");
    	String CONT_CNT = req.getParameter("CONT_CNT_SGI");
    	String MASTER_CONT_NO_NEW = GUBN.substring(0,1)+CONT_NUM + "-" + CONT_CNT;

        // 계약금액 : 공급사 = SORDER_AMT[(매입)(계약금액), 고객사 = SUPPLY_AMT[(매출)(계약금액)]}]
    	String AMT = "";
    	//2022-10-14 대명소노시즌은 매입만 함.
    	AMT = req.getParameter("SORDER_AMT_SGI");
//    	String cont_hd_type = req.getParameter("cont_hd_type_h");
//    	if (cont_hd_type.equals("P")) { 		// 매입
//    		AMT = req.getParameter("SORDER_AMT_SGI");
//    	} else if(cont_hd_type.equals("S")) { 	// 매출
//    		AMT = req.getParameter("SUPPLY_AMT_SGI");
//    	}

        //	계약기간 : 계약시작일자,계약종료일자로 계산
    	String SDIFFDAYS  = "";	// YYYYMMDD
    	String SDIFFDAYS2 = "";	// YYYYMMDD
    	try{
	    	SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");

	    	/*계약기간*/
	        Date beginDate = formatter.parse(CONT_START_DATE);
	        Date endDate   = formatter.parse(CONT_END_DATE);

	        // 시간차이를 시간,분,초를 곱한 값으로 나누면 하루 단위가 나옴
	        long diff = endDate.getTime() - beginDate.getTime();
	        long diffDays = diff / (24 * 60 * 60 * 1000);
	        SDIFFDAYS = String.valueOf(diffDays);

	        /*하자기간*/
	        Date beginDate2 = formatter.parse(MENGEL_START_DATE);
	        Date endDate2   = formatter.parse(MENGEL_END_DATE);

	        // 시간차이를 시간,분,초를 곱한 값으로 나누면 하루 단위가 나옴
	        long diff2 = endDate2.getTime() - beginDate2.getTime();
	        long diffDays2 = diff2 / (24 * 60 * 60 * 1000);
	        SDIFFDAYS2 = String.valueOf(diffDays2);
        }
    	catch (ParseException e) {
            e.printStackTrace();
        }

    	System.out.println("계약번호+차수          ::::: " + MASTER_CONT_NO_NEW);
    	System.out.println("계약금액                  ::::: " + AMT);
    	System.out.println("계약시작일자            ::::: " + SDIFFDAYS);

    	// 서울보증 증권번호
    	String CONT_INSU_NUM = req.getParameter("CONT_INSU_NUM"); // 계약이행보증
    	String AMT_INSU_NUM  = req.getParameter("AMT_INSU_NUM");  // 선급보증
    	String AS_INSU_NUM   = req.getParameter("AS_INSU_NUM");   // 하자보증

    	String reqXml = null;
    	String status = null;
    	XmlToData xmlToData = null;

    	//*****전자보증*****//
    	if (SGI_GUBUN.equals("CONINF")){ // 통보서[CONINF] : 계약, 선급, 하자

    		//***** 계약서정보 테이블의 계약보증서번호 조회(변경품의서 작성시 기존 번호 가져오기) *****//
    		/**
    		SELECT CONT_INSU_NUM, ADV_INSU_NUM, WARR_INSU_NUM
    		  FROM STOCECCT
    		 WHERE CONT_NUM = #{CONT_NUM}
    		   AND CONT_CNT = #{CONT_CNT}
    		*/

    		// 보증번호 가져오기
    		//CONT_INSU_NUM = wf.getValue("ORG_CONT_INSU_NUM",0); // 계약이행보증번호
    		//AMT_INSU_NUM  = wf.getValue("ORG_ADV_INSU_NUM",0);	// 선급보증번호
    		//AS_INSU_NUM   = wf.getValue("ORG_WARR_INSU_NUM",0);	// 하자보증번호

	    	if (cont_seq == "1" || cont_seq.equals("1")){	//신규일 경우
	    		workGubun = "10"; //신규 또는 변경(배서) 업무구분 - 10:신규,20:연장,60:증액,62:연장증액,70:감액,90:기타(그 외)
	    		CONT_INSU_NUM = null;
	    	} else {											//변경일 경우
	    		workGubun = "90";
	    		// 계약이행보증번호
	    		if( !StringUtil.isNullOrEmpty(CONT_INSU_NUM) ){
	    			CONT_INSU_NUM = CONT_INSU_NUM.substring(6, 24);
	    		}
	    		// 선급보증번호
	    		if( !StringUtil.isNullOrEmpty(AMT_INSU_NUM) ){
	    			AMT_INSU_NUM = AMT_INSU_NUM.substring(6, 24);
	    		}
	    		// 하자이행보증번호
	    		if( !StringUtil.isNullOrEmpty(AS_INSU_NUM) ){
	    			AS_INSU_NUM = AS_INSU_NUM.substring(6, 24);
	    		}
	    	}
	    	//***** 변경품의 전 보증번호를 가져온다(끝) *****//

    		//***** 계약이행증권이 있을 경우 *****//
    		if(CONT_ISU_BILL_FLAG_SGI.equals("O/X") && GUBN.equals("CONT")){
    			reqXml = composeXML(CONT_START_DATE			//계약시작일자
    					           ,CONT_END_DATE			//계약종료일자
    					           ,CONT_WARRANTY_AMT		//계약보증금액
    					           ,MASTER_CONT_NO_NEW		//계약번호+계약차수
    					           ,CONT_TITLE				//계약명
    					           ,CONT_DATE_1				//준공일(=계약일자)
    					           ,CONT_DATE				//계약일자
    					           ,AMT						//매입금액
    					           ,SDIFFDAYS				//계약기간일수
    					           ,CONT_WARRANTY_AMT_RATE	//계약보증금율(%)
    					           ,SYSDATE
    					           ,SYSTIME
    					           ,VENDOR_NAME_LOC			//공급사명
    					           ,CEO_NAME_LOC			//공급사대표자명
    					           ,workGubun				//업무구분 - 10:신규,20:연장,60:증액,62:연장증액,70:감액,90:기타(그 외)
    					           ,hostCode				//기존에 발행되었던 신규(원) 증권번호(18자리)
    					           ,IRS_NO_VENDOR			//공급사 사업자번호
    					           ,CONT_INSU_NUM			//계약보증 증권번호
    					           ,PREGIVEDATE				//선급지급예정일
    					           );

    			/***** SGI 전송  start******/
            	System.out.println("================> 계약이행보증 SendServlet : " + reqXml);
        		SGIxLinker xLinker = new SGIxLinker(this.configpath, "SendServlet", false);	// true:파일로 송신, false:Data로 송신

        		// 전송 문자 인코딩 : UTF-8
        		xLinker.setXmlEncoding("UTF-8");

            	boolean isOK = xLinker.doSendProcess(reqXml, null);
        		if(!isOK) {
        			System.out.println("================> 계약이행보증 SendServlet Error : " + xLinker.getErrorMsg());
        			return;
        		}

        		String recvXml = xLinker.getRecvXmlData();
        		System.out.println("================> 계약이행보증 SendServlet의 수신값 : " + recvXml);

        		//***************************************
        		// xml 응답서 문서 정보를 XmltoData로 추출하여 상태값 DB에 저장 (매핑 정보 파일, XML 탬플릿 정보 파일)
        		try{
        			xmlToData = new XmlToData(xLinker.getTempPath() , "RESPONSE", recvXml);
        			if(xmlToData.getErrorCode()!=0) {
        				System.out.println(xmlToData.getErrorMsg());
        				return;
        			}
        		} catch(Exception e) {
        			System.out.println("================> 계약이행보증 SendServlet Exception : " + e.toString());
        			e.printStackTrace();
        		}
        		/***** SGI 전송  end ******/
    		}
    		System.out.println("***********************************************");
    	    System.out.println(CONT_START_DATE+"CONT_START_DATE");
			System.out.println(CONT_END_DATE+"CONT_END_DATE");
			System.out.println(MASTER_CONT_NO_NEW+"MASTER_CONT_NO_NEW");
			System.out.println(CONT_TITLE+"CONT_TITLE");
			System.out.println(CONT_DATE_1+"CONT_DATE_1");
			System.out.println(CONT_DATE+"CONT_DATE");
			System.out.println(AMT+"AMT");				//매입금액
			System.out.println(SDIFFDAYS+"SDIFFDAYS");					//계약기간일수
			System.out.println(FIRST_SECURITIES_AMT+"FIRST_SECURITIES_AMT");		//선급보증금액
			System.out.println(FIRST_SECURITIES_AMT_RATE+"FIRST_SECURITIES_AMT_RATE");	//선급보증금율
			System.out.println(SYSDATE+"SYSDATE");
			System.out.println(SYSTIME+"SYSTIME");
			System.out.println(VENDOR_NAME_LOC+"VENDOR_NAME_LOC");
			System.out.println(CEO_NAME_LOC+"CEO_NAME_LOC");
			System.out.println(workGubun+"workGubun");
			System.out.println(hostCode+"hostCode");
			System.out.println(IRS_NO_VENDOR+"IRS_NO_VENDOR");				//공급사 사업자번호
			System.out.println(AMT_INSU_NUM+"AMT_INSU_NUM");			//선급보증증권번호
			System.out.println(PREGIVEDATE+"PREGIVEDATE");				//선급지급예정일
			System.out.println("***********************************************");
    		//*****선급이행증권이 있을 경우*****//
    		if(FIRST_ISU_BILL_FLAG_SGI.equals("O/X") && GUBN.equals("ADV")){
    			try {
					reqXml = composeXML2(CONT_START_DATE
										,CONT_END_DATE
										,MASTER_CONT_NO_NEW
										,CONT_TITLE
										,CONT_DATE_1
										,CONT_DATE
										,AMT						//매입금액
										,SDIFFDAYS					//계약기간일수
										,FIRST_SECURITIES_AMT		//선급보증금액
										,FIRST_SECURITIES_AMT_RATE	//선급보증금율
										,SYSDATE
										,SYSTIME
										,VENDOR_NAME_LOC
										,CEO_NAME_LOC
										,workGubun
										,hostCode
										,IRS_NO_VENDOR				//공급사 사업자번호
										,AMT_INSU_NUM				//선급보증증권번호
										,PREGIVEDATE				//선급지급예정일
										);
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					e1.printStackTrace();
				}

    			//***** SGI 전송  start******//
            	System.out.println("================> 선급이행증권 SendServlet : " + reqXml);
        		SGIxLinker xLinker = new SGIxLinker(this.configpath, "SendServlet", false);	// true:파일로 송신, false:Data로 송신

        		// 전송 문자 인코딩 : UTF-8
        		xLinker.setXmlEncoding("UTF-8");

            	boolean isOK = xLinker.doSendProcess(reqXml, null);
        		if(!isOK) {
        			System.out.println("================> 선급이행증권 SendServlet Error : " + xLinker.getErrorMsg());
        			return;
        		}

        		String recvXml = xLinker.getRecvXmlData();
        		System.out.println("================> 선급이행증권 SendServlet의 수신값 : " + recvXml);

        		//***************************************
        		// xml 응답서 문서 정보를 XmltoData로 추출하여 상태값 DB에 저장 (매핑 정보 파일, XML 탬플릿 정보 파일)
        		try{
        			xmlToData = new XmlToData(xLinker.getTempPath() , "RESPONSE", recvXml);
        			if(xmlToData.getErrorCode()!=0) {
        				System.out.println(xmlToData.getErrorMsg());
        				return;
        			}
        		} catch(Exception e) {
        			System.out.println("================> 선급이행증권 SendServlet Exception : " + e.toString());
        			e.printStackTrace();
        		}
        		/***** SGI 전송  end ******/
    		}

    		//*****하자이행증권이 있을 경우*****//
    		if(MENGEL_ISU_BILL_FLAG_SGI.equals("O/X") && GUBN.equals("WARR")){
    			reqXml = composeXML3(CONT_START_DATE
						            ,CONT_END_DATE
						            ,MASTER_CONT_NO_NEW
						            ,CONT_WARRANTY_AMT
						            ,CONT_TITLE
						            ,CONT_DATE_1
						            ,CONT_DATE
						            ,AMT						//매입금액
						            ,SDIFFDAYS2					//하자보증일수
						            ,MENGEL_WARRANTY_AMT		//하자보증금액
						            ,MENGEL_WARRANTY_AMT_RATE	//하자보증금율(%)
						            ,MENGEL_START_DATE			//하자보증 시작일자
						            ,MENGEL_END_DATE			//하자보증 종료일자
						            ,SYSDATE
						            ,SYSTIME
						            ,VENDOR_NAME_LOC
						            ,CEO_NAME_LOC
						            ,workGubun
						            ,hostCode
						            ,IRS_NO_VENDOR				//공급사 사업자번호
						            ,AS_INSU_NUM				//하자이행보증 증권번호
						            ,PREGIVEDATE				//선급지급예정일
    								);

    			//***** SGI 전송  start******//
            	System.out.println("================> 하자이행증권 SendServlet : " + reqXml);
        		SGIxLinker xLinker = new SGIxLinker(this.configpath, "SendServlet", false);	// true:파일로 송신, false:Data로 송신

        		// 전송 문자 인코딩 : UTF-8
        		xLinker.setXmlEncoding("UTF-8");

        		//SGI 전송
            	boolean isOK = xLinker.doSendProcess(reqXml, null);
        		if(!isOK) {
        			System.out.println("================> 하자이행증권 SendServlet Error : " + xLinker.getErrorMsg());
        			return;
        		}

        		String recvXml = xLinker.getRecvXmlData();
        		System.out.println("================> 하자이행증권 SendServlet의 수신값 : " + recvXml);

        		//***************************************
        		// xml 응답서 문서 정보를 XmltoData로 추출하여 상태값 DB에 저장 (매핑 정보 파일, XML 탬플릿 정보 파일)
        		try{
        			xmlToData = new XmlToData(xLinker.getTempPath() , "RESPONSE", recvXml);
        			if(xmlToData.getErrorCode()!=0) {
        				System.out.println(xmlToData.getErrorMsg());
        				return;
        			}
        		}catch(Exception e){
        			System.out.println("================> 하자이행증권 SendServlet Exception : " + e.toString());
        			e.printStackTrace();
        		}
        		/***** SGI 전송  end ******/
    		}

    		status = "TA";   //SGI전송시 계약완료

    	} //***** 최종응답서 전송(RBONGU) *****//
    	else if(SGI_GUBUN.equals("RBONGU")){

        	//	계약서정보 테이블의 계약보증서번호 유무조회 (ICOMECCV.CONT_INSU_NUM : ex)004002100000201610049756 00)
	    	String cont_num = req.getParameter("cont_num");
	    	String cont_cnt = req.getParameter("cont_cnt");
	    	System.out.println("MASTER_CONT_NO_NEW   	   ::::::::::::::::::" + MASTER_CONT_NO_NEW);
	    	System.out.println("CONT_TITLE            	   ::::::::::::::::::" + CONT_TITLE        );
	    	System.out.println("CONT_INSU_NUM         	   ::::::::::::::::::" + CONT_INSU_NUM     );
	    	System.out.println("VENDOR_NAME_LOC       	   ::::::::::::::::::" + VENDOR_NAME_LOC   );
	    	System.out.println("CEO_NAME_LOC          	   ::::::::::::::::::" + CEO_NAME_LOC      );
	    	System.out.println("SYSDATE               	   ::::::::::::::::::" + SYSDATE           );
	    	System.out.println("SYSTIME               	   ::::::::::::::::::" + SYSTIME           );
	    	System.out.println("IRS_NO_VENDOR         	   ::::::::::::::::::" + IRS_NO_VENDOR     );
	    	System.out.println("RBONGU_STATUS         	   ::::::::::::::::::" + RBONGU_STATUS     );
	    	System.out.println("INSU_STATUS           	   ::::::::::::::::::" + INSU_STATUS       );
	    	System.out.println("CONT_ISU_BILL_FLAG_SGI           	   ::::::::::::::::::" + CONT_ISU_BILL_FLAG_SGI       );
	    	System.out.println("GUBN           	   ::::::::::::::::::" + GUBN       );

	    	/**
    		SELECT CONT_INSU_NUM, ADV_INSU_NUM, WARR_INSU_NUM
    		  FROM STOCECCT
    		 WHERE CONT_NUM = #{CONT_NUM}
    		   AND CONT_CNT = #{CONT_CNT}
    		*/

	    	// 보증번호 가져오기
    		//CONT_INSU_NUM = wf.getValue("ORG_CONT_INSU_NUM",0); // 계약이행보증번호
    		//AMT_INSU_NUM  = wf.getValue("ORG_ADV_INSU_NUM",0);	// 선급보증번호
    		//AS_INSU_NUM   = wf.getValue("ORG_WARR_INSU_NUM",0);	// 하자보증번호

	    	//*****계약이행증권이 있을 경우*****//
    		if(CONT_ISU_BILL_FLAG_SGI.equals("O/O") && GUBN.equals("CONT")){ //--> O/X추가
	    		reqXml = composeXML9(MASTER_CONT_NO_NEW
	    						   , CONT_TITLE
	    						   , CONT_INSU_NUM
	    						   , VENDOR_NAME_LOC
	    						   , CEO_NAME_LOC
	    						   , SYSDATE
	    						   , SYSTIME
	    						   , IRS_NO_VENDOR
	    						   , RBONGU_STATUS
	    						   , INSU_STATUS
	    						   );

	    		//***** SGI 전송  start******//
	        	System.out.println("================> 계약이행증권 최종응답서 SendServlet : " + reqXml);
	    		SGIxLinker xLinker = new SGIxLinker(this.configpath, "SendServlet", false);	// true:파일로 송신, false:Data로 송신

	    		// 전송 문자 인코딩 : UTF-8
        		xLinker.setXmlEncoding("UTF-8");

	        	boolean isOK = xLinker.doSendProcess(reqXml, null);
	    		if(!isOK) {
	    			System.out.println("================> 계약이행증권 최종응답서 SendServlet Error : " + xLinker.getErrorMsg());
	    			return;
	    		}

	    		String recvXml = xLinker.getRecvXmlData();
	    		System.out.println("================> 계약이행증권 최종응답서 SendServlet의 수신값 : " + recvXml);

	    		//***************************************
	    		// xml 응답서 문서 정보를 XmltoData로 추출하여 상태값 DB에 저장 (매핑 정보 파일, XML 탬플릿 정보 파일)
	    		try{
	    			xmlToData = new XmlToData(xLinker.getTempPath() , "RESPONSE", recvXml);
	    			if(xmlToData.getErrorCode()!=0) {
	    				System.out.println(xmlToData.getErrorMsg());
	    				return;
	    			}
	    		}catch(Exception e){
	    			System.out.println("================> 계약이행증권 최종응답서 SendServlet Exception : " + e.toString());
	    			e.printStackTrace();
	    		}
    		}
    		//*****선급이행증권이 있을 경우*****//
    		if(FIRST_ISU_BILL_FLAG_SGI.equals("O/O") && GUBN.equals("ADV")){		//--> O/X추가
	    		reqXml = composeXML10(MASTER_CONT_NO_NEW
	    						    , CONT_TITLE
	    						    , AMT_INSU_NUM
	    						    , VENDOR_NAME_LOC
	    						    , CEO_NAME_LOC
	    						    , SYSDATE
	    						    , SYSTIME
	    						    , IRS_NO_VENDOR
	    						    , RBONGU_STATUS
	    						    , INSU_STATUS
	    							);

	    		//***** SGI 전송  start******//
	        	System.out.println("================> 선급이행증권 최종응답서 SendServlet : " + reqXml);
	    		SGIxLinker xLinker = new SGIxLinker(this.configpath, "SendServlet", false);	// true:파일로 송신, false:Data로 송신

	    		// 전송 문자 인코딩 : UTF-8
        		xLinker.setXmlEncoding("UTF-8");

	        	boolean isOK = xLinker.doSendProcess(reqXml, null);
	    		if(!isOK) {
	    			System.out.println("================> 선급이행증권 최종응답서 SendServlet Error : " + xLinker.getErrorMsg());
	    			return;
	    		}

	    		String recvXml = xLinker.getRecvXmlData();
	    		System.out.println("================> 선급이행증권 최종응답서 SendServlet의 수신값 : " + recvXml);

	    		//***************************************
	    		// xml 응답서 문서 정보를 XmltoData로 추출하여 상태값 DB에 저장 (매핑 정보 파일, XML 탬플릿 정보 파일)
	    		try{
	    			xmlToData = new XmlToData(xLinker.getTempPath() , "RESPONSE", recvXml);
	    			if(xmlToData.getErrorCode()!=0) {
	    				System.out.println(xmlToData.getErrorMsg());
	    				return;
	    			}
	    		}catch(Exception e){
	    			System.out.println("================> 선급이행증권 최종응답서 SendServlet Exception : " + e.toString());
	    			e.printStackTrace();
	    		}
    		}

    		//*****하자이행증권이 있을 경우*****//
    		if(MENGEL_ISU_BILL_FLAG_SGI.equals("O/O") && GUBN.equals("WARR")){ //--> O/X추가
	    		reqXml = composeXML11(MASTER_CONT_NO_NEW
	    						    , CONT_TITLE
	    						    , AS_INSU_NUM
	    						    , VENDOR_NAME_LOC
	    						    , CEO_NAME_LOC
	    						    , SYSDATE
	    						    , SYSTIME
	    						    , IRS_NO_VENDOR
	    						    , RBONGU_STATUS
	    						    , INSU_STATUS
	    							);

	    		//***** SGI 전송  start******//
	        	System.out.println("================> 하자이행증권 최종응답서 SendServlet : " + reqXml);
	    		SGIxLinker xLinker = new SGIxLinker(this.configpath, "SendServlet", false);	// true:파일로 송신, false:Data로 송신
	    		// 전송 문자 인코딩 : UTF-8
        		xLinker.setXmlEncoding("UTF-8");

	        	boolean isOK = xLinker.doSendProcess(reqXml, null);
	    		if(!isOK) {
	    			System.out.println("================> 하자이행증권 최종응답서 SendServlet Error : " + xLinker.getErrorMsg());
	    			return;
	    		}

	    		String recvXml = xLinker.getRecvXmlData();
	    		System.out.println("================> 하자이행증권 최종응답서 SendServlet의 수신값 : " + recvXml);

	    		//***************************************
	    		// xml 응답서 문서 정보를 XmltoData로 추출하여 상태값 DB에 저장 (매핑 정보 파일, XML 탬플릿 정보 파일)
	    		try{
	    			xmlToData = new XmlToData(xLinker.getTempPath() , "RESPONSE", recvXml);
	    			if(xmlToData.getErrorCode()!=0) {
	    				System.out.println(xmlToData.getErrorMsg());
	    				return;
	    			}
	    		}catch(Exception e){
	    			System.out.println("================> 하자이행증권 최종응답서 SendServlet Exception : " + e.toString());
	    			e.printStackTrace();
	    		}
    		}

			//최종응답서 보낼때 진행상태 변경
			//거부일 경우 다시 SGI 에서 차수 변경해서 보증서가 전송되며, 최종응답서를 SGI에  재전송해야되므로 진행상태값이 그대로 계약서전송(31)상태로 있어야함)
    		if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("SA") ){	//승인후 계약파기
    			//status = "31";	//계약서전송
    			status = "DE";		//계약서 전송하면 계약완료로 봐야함
    		}else if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("TA")){ // 승인전 계약취소
    			status = "DD";
    		}
    		/***** SGI 전송  end ******/
    	}

    	/**
    	 * 보증보험 전송 후 수신한 결과값 정보를 DB에 저장
    	 */
		try {
			String resContNum   = xmlToData.getData("res_cont_num");
			String respTypeCode = xmlToData.getData("res_info_code");	//
			String respTypeName = xmlToData.getData("res_info_typename");
			String respMesgText = xmlToData.getData("res_info_result");
			String resDocuNum   = xmlToData.getData("res_docu_num");
			String resDocNum    = "";
			
			System.out.println("대명소노 계약번호  = " + resContNum);
			System.out.println("서울보증 응답코드  = " + respTypeCode);
			System.out.println("서울보증 응답코드명 = " + respTypeName);
			System.out.println("서울보증 응답메시지 = " + respMesgText);
			System.out.println("서울보증 res_docu_num = " + xmlToData.getData("res_docu_num"));
			System.out.println("서울보증 res_cont_num = " + xmlToData.getData("res_cont_num"));
			System.out.println("서울보증 res_result = " + xmlToData.getData("res_result"));
			System.out.println("서울보증 res_gxmlhead = " + xmlToData.getData("res_gxmlhead"));
			System.out.println("서울보증 res_nextpass = " + xmlToData.getData("res_nextpass"));
			
			res.setParameter("TEST","ZZZZQTDE");
			res.setResponseMessage(respMesgText);
//	        PrintWriter out = res.getWriter();
//	        out.println("<html>");
//	        out.println("<head>");
//	        out.println("<title>SGIxLiner Servlet Test</title>");
//	        out.println("</head>");
//	        out.println("<body>");
//	        out.println("<h1>SGIxLiner Servlet Test</h1>");
//	        out.println("<br>");
//	        out.println("Response Code = " + respTypeCode);
//	        out.println("<br>");
//	        out.println("Response Name = "+respTypeName);
//	        out.println("<br>");
//	        out.println("Response Message = "+respMesgText);
//	        out.println("<br>");
//	        out.println("</body>");
//	        out.println("</html>");
			
			//jsp 파일 파싱
	        Map<String, String> dataInfo =new HashMap<String,String>();
	        // SA : MRO사이트 "보증서 수용"
	        if( respTypeCode.equals("SA") ){
	        	//	계약서정보 테이블의 상태값을 업데이트 (ICOMECCV.STATUS: 전자보증['21(본사승인완료)'->'31(SGI전송완료)'] , 최종응답서['31(SGI전송완료)'->'32(SGI납입완료)'])
	        	if(status.equals("TA")) {
	        		resDocNum = resContNum;
	        	}else {
	        		resDocNum = resDocuNum;
	        	}

		    	dataInfo.put("CONT_NUM"				 ,CONT_NUM);
		    	dataInfo.put("CONT_CNT"	 			 ,CONT_CNT);
		    	dataInfo.put("RESP_CODE" 			 ,status);
		    	dataInfo.put("GUBN" 				 ,GUBN);
		    	dataInfo.put("MASTER_CONT_NO_NEW" 	 ,MASTER_CONT_NO_NEW);
		    	dataInfo.put("RES_CONT_NUM" 	 	 ,resDocNum);

		    	ct0600Service = SpringContextUtil.getBean(CT0600Service.class);
		    	ct0600Service.updateSaInfo(dataInfo);
	        }
		}
		catch(Exception _e) {
			System.out.println(_e.toString());
		}
	}

    /* 전자보증-계약이행증권*/
    /* 계약정보통보서(CONINF) */
	public String composeXML(String CONT_START_DATE
						   , String CONT_END_DATE
						   , String CONT_WARRANTY_AMT_SGI
						   , String MASTER_CONT_NO_NEW
						   , String CONT_TITLE
						   , String CONT_DATE_1
			               , String CONT_DATE
			               , String AMT
			               , String SDIFFDAYS
			               , String CONT_WARRANTY_AMT_RATE
			               , String SYSDATE
			               , String SYSTIME
			               , String VENDOR_NAME_LOC
			               , String CEO_NAME_LOC
			               , String workGubun
			               , String hostCode
			               , String IRS_NO_VENDOR		//공급사 사업자번호
			               , String CONT_INSU_NUM
			               , String PREGIVEDATE			//선급지급예정일
			               )
	{
		/* HEADER */
		String	head_mesg_send  =this.strSGICSenderCode;	/*	[필수]	 전문송신기관 (고정)*/
		String	head_mesg_recv  =this.strSGICCode;			/*	[필수]	 전문수신기관 (고정?)*/
		String	head_func_code  =this.strHeadFuncCode;		/*	[필수]	 문서기능	(운영에는 9로 수정*/
		String	head_mesg_type  ="CONINF";					/*	[필수]	 문서코드	(고정)*/
		String	head_mesg_name  ="계약정보통보서";				/*	[필수]	 문서명 (고정)*/
		String	head_mesg_vers  ="1.0";						/*	[선택]	 전자문서버전	(고정)*/
		String	head_docu_numb  ="004002" + MASTER_CONT_NO_NEW + " 00";		/*	[필수]	 문서번호	*/
		String	head_mang_numb  ="13." + SYSDATE + SYSTIME + ".12345." + "004002" + MASTER_CONT_NO_NEW + " 00";	/*	[필수]	 문서관리번호	*/
		String	head_refr_numb  ="004002" + MASTER_CONT_NO_NEW + " 00";		/*	[필수]	 참조번호	*/
		String	head_titl_name  ="계약정보통보서";				/*	[필수]	 문서개요	(고정)*/
		String  head_orga_code  ="DMC";             		/*  [필수]   연계코드   (고정)*/

		/* 보험계약정보 */
		String	bond_kind_code  ="002";						/*	[필수]	" 보험종목구분(002:계약,003:하자,004:선금,006:지급)"	(고정)*/
		String	bond_begn_date  =CONT_START_DATE ;			/*	[필수]	 보험개시일자	*/
		String	bond_fnsh_date  =CONT_END_DATE;				/*	[필수]	 보험종료일자	*/
		String	bond_curc_code  ="WON";						/*	[필수]	" 보험가입금액/통화코드(WON, USD …)"	(고정)*/
		String	bond_oper_code  ="SELECT";					/*	[선택]	" 조회등록 업무구분(SELECT,INSERT)"	 (고정)*/
		String	bond_penl_amnt  =CONT_WARRANTY_AMT_SGI;		/*	[필수]	 보험가입금액/보험가입금액	계약금액*보증금율*/
		String	bond_appl_code  =workGubun;					/*	[필수]	" 신규배서 업무구분(10:신규,20:연장,60:증액,62:연장증액,70:감액,90:기타)"	(고정)*/

		/* 주요계약정보 */
		String	cont_numb_text  =MASTER_CONT_NO_NEW;		/*	[필수]	 계약번호	*/
		String	cont_name_text  =CONT_TITLE;				/*	[필수]	 계약건명	*/
		String	cont_proc_type  ="F00";						/*	[필수]	 계약구분	????????????????????*/
		String	cont_type_iden  ="2";						/*	[필수]	" 계약방식(1:공동, 2:단독, 3:분담)"	(고정)*/
		String	cont_asgn_rate  =null;						/*	[선택]	 지분율	*/
		String	cont_news_divs  ="1";						/*	[필수]	" 신규/갱신 계약구분(1:신규계약, 2:갱신계약)"	(고정)*/
		String	cont_plan_date  =null;						/*	[선택]	 준공예정일	*/
		String	cont_main_date  =CONT_DATE;					/*	[선택]	 계약체결일자	*/
		String	cont_curc_code  ="WON";						/*	[필수]	 계약금액(원화)/통화코드(WON)	(고정)*/
		String	forn_curc_code  =null;						/*	[선택]	 계약금액(외화)/통화코드(USD …)	*/
		String	forn_main_amnt  =null;						/*	[선택]	 계약금액(외화)/계약금액	*/
		String	cont_main_amnt  =AMT;						/*	[필수]	 계약금액(원화)/계약금액	*/
		String	hist_bond_numb  =CONT_INSU_NUM;				/*	[선택]	 배서대상 증권번호	*/

		/* 계약정보 */
		String	cont_begn_date  =CONT_START_DATE;			/*	[필수]	 계약시작일자	*/
		String	cont_fnsh_date  =CONT_END_DATE;				/*	[필수]	 계약종료일자	*/
		String	cont_term_text  =SDIFFDAYS;					/*	[선택]	 계약기간	*/
		String	cont_pric_rate  =CONT_WARRANTY_AMT_RATE;	/*	[필수]	" 보증금율(단가계약일 경우 ""0""으로 입력)"	*/
		String	cont_unit_divs  ="1";						/*	[필수]	" 단가계약 여부(1:단가계약,2:일반계약)"	*/

		/* 채권자 정보 */
		String	cred_orga_name  ="(주)대명소노시즌";				/*	[필수]	 기관명	*/
		String	cred_orps_divs  ="O";						/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	cred_orga_numb  ="1801110068668";			/*	[필수]	 법인등록번호	*/
		String	cred_orps_iden  ="6048115788";				/*	[필수]	 사업자/주민번호	*/
		String	cred_ownr_numb  ="1111111111111";			/*	[필수]	 대표자 주민등록번호	*/
		String	cred_ownr_name  ="서준혁";						/*	[필수]	 성명(대표자명)	*/
		String	cred_bond_hold  ="서준혁";						/*	[필수]	 채권자명	*/
		String	cred_addn_name  ="";						/*	[선택]	 채권기관 부가상호	??*/
		String	cred_orga_post  ="25102";					/*	[필수]	 회사 우편번호	*/
		String	cred_orga_addr  ="강원도 홍천군 서면 한치골길 262";		/*	[필수]	 회사 주소	*/
		String	cred_chrg_name  ="차호정";						/*	[필수]	 담당자명	*/
		String	cred_dept_name  ="기획지원팀";					/*	[필수]	 소속부서	*/
		String	cred_phon_numb  ="02-2222-7573";			/*	[필수]	 전화번호	*/
		String	cred_cell_phon  ="010-4646-0856";			/*	[필수]	 핸드폰번호	*/
		String	cred_send_mail  ="hojung.cha@daemyung.com";	/*	[필수]	 담당자 EMAIL	*/
		String	cred_user_iden  =this.strSGICSenderCode;	/*	[필수]	 수신처ID	*/
		String	cred_user_type  ="DMC";						/*	[필수]	 수신처TYPE	*/

		/* 계약자 정보 */
		String	appl_orga_name  =VENDOR_NAME_LOC;	/*	[필수]	 기관명	*/
		String	appl_orps_divs  ="O";				/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	appl_orga_numb  =null;				/*	[선택]	 법인등록번호	*/
		String	appl_orps_iden  =IRS_NO_VENDOR;		/*	[필수]	 사업자/주민번호	*/
		String	appl_ownr_numb  ="1111111111111";	/*	[필수]	 대표자 주민등록번호	(고정)*/
		String	appl_ownr_name  =CEO_NAME_LOC;		/*	[필수]	 성명(대표자명)	*/
		String	appl_addn_name  =null;				/*	[선택]	 계약업체 부가상호	*/
		String	appl_orga_post  =null;				/*	[선택]	 회사 우편번호	*/
		String	appl_orga_addr  =null;				/*	[선택]	 회사 주소	*/
		String	appl_chrg_name  =null;				/*	[선택]	 담당자명	*/
		String	appl_dept_name  =null;				/*	[선택]	 소속부서	*/
		String	appl_offc_phon  =null;				/*	[선택]	 전화번호	*/
		String	appl_cell_phon  =null;				/*	[선택]	 핸드폰번호	*/
		String	appl_send_mail  =null;				/*	[선택]	 담당자 EMAIL	*/
		String	appl_home_post  =null;				/*	[선택]	 자택 우편번호	*/
		String	appl_home_addr  =null;				/*	[선택]	 자택 주소	*/
		String	appl_home_phon  =null;				/*	[선택]	 자택 전화번호	*/
		String	appl_user_iden  ="B123456789012";	/*	[필수]	 수신처ID	*/
		String	appl_user_type  ="DMC";				/*	[필수]	 수신처TYPE	*/

		/* 수요자 정보 사용하지 않지만 빈값으로 넘김*/
		String	mang_orga_name  =null;				/*	[선택]	 기관명	*/
		String	mang_orps_divs  =null;				/*	[선택]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	mang_orps_iden  =null;				/*	[선택]	 사업자/주민번호	*/
		String	mang_ownr_numb  =null;				/*	[선택]	 대표자 주민등록번호	*/
		String	mang_ownr_name  =null;				/*	[선택]	 성명(대표자명)	*/
		String	mang_addn_name  =null;				/*	[선택]	 수요(대행)업체 부가상호	*/
		String	mang_orga_post  =null;				/*	[선택]	 회사 우편번호	*/
		String	mang_orga_addr  =null;				/*	[선택]	 회사 주소	*/
		String	mang_bond_hold  =null;				/*	[선택]	 채권자명	*/
		String	mang_chrg_name  =null;				/*	[선택]	 담당자명	*/
		String	mang_dept_name  =null;				/*	[선택]	 소속부서	*/
		String	mang_phon_numb  =null;				/*	[선택]	 전화번호	*/
		String	mang_cell_phon  =null;				/*	[선택]	 핸드폰번호	*/
		String	mang_send_mail  =null;				/*	[선택]	 담당자 EMAIL	*/
		String	mang_user_iden  =null;				/*	[선택]	 수신처ID	*/
		String	mang_user_type  =null;				/*	[선택]	 수신처TYPE	*/

		// 매핑 정보 파일, XML 탬플릿 정보 파일
		DataToXml datatoxml = new DataToXml(PropertiesManager.getString("sgic_templates_path"), "CONINF");
		if(datatoxml.getErrorCode()!=0) {
			System.out.println(datatoxml.getErrorMsg());
			return null;
		}

		/* 계약정보통보서(CONINF) */
		/* HEADER */
		try{
			if(
				/* Begin of Header */
					datatoxml.setData("head_mesg_send", head_mesg_send)
				&&	datatoxml.setData("head_mesg_recv", head_mesg_recv)
				&&	datatoxml.setData("head_func_code", head_func_code)
				&&	datatoxml.setData("head_mesg_type", head_mesg_type)
				&&	datatoxml.setData("head_mesg_name", head_mesg_name)
				&&	datatoxml.setData("head_mesg_vers", head_mesg_vers)
				&&	datatoxml.setData("head_docu_numb", head_docu_numb)
				&&	datatoxml.setData("head_mang_numb", head_mang_numb)
				&&	datatoxml.setData("head_refr_numb", head_refr_numb)
				&&	datatoxml.setData("head_titl_name", head_titl_name)
				&&  datatoxml.setData("head_orga_code", head_orga_code)
				/* End of Header */

				/* Begin of 보험계약정보 */
				&&  datatoxml.setData("bond_kind_code", bond_kind_code)
				&&  datatoxml.setData("bond_begn_date", bond_begn_date)
				&&  datatoxml.setData("bond_fnsh_date", bond_fnsh_date)
				&&  datatoxml.setData("bond_curc_code", bond_curc_code)
				&&  datatoxml.setData("bond_penl_amnt", bond_penl_amnt)
				&&  datatoxml.setData("bond_oper_code", bond_oper_code)
				&&  datatoxml.setData("bond_appl_code", bond_appl_code)
				/* End of 보험계약정보 */

				/* Begin of 주요계약정보 */
				&&  datatoxml.setData("cont_numb_text", cont_numb_text)
				&&  datatoxml.setData("cont_name_text", cont_name_text)
				&&  datatoxml.setData("cont_proc_type", cont_proc_type)
				&&  datatoxml.setData("cont_type_iden", cont_type_iden)
				//&&  datatoxml.setData("cont_asgn_rate", cont_asgn_rate)
				&&  datatoxml.setData("cont_news_divs", cont_news_divs)
				&&  datatoxml.setData("cont_plan_date", cont_plan_date)
				&&  datatoxml.setData("cont_main_date", cont_main_date)
				&&  datatoxml.setData("cont_curc_code", cont_curc_code)
				&&  datatoxml.setData("cont_main_amnt", cont_main_amnt)
				//&&  datatoxml.setData("forn_curc_code", forn_curc_code)
				//&&  datatoxml.setData("forn_main_amnt", forn_main_amnt)
				&&  datatoxml.setData("hist_bond_numb", hist_bond_numb)
				/* End of 주요계약정보 */

				/* Begin of 계약정보 */
				&&  datatoxml.setData("cont_begn_date", cont_begn_date)
				&&  datatoxml.setData("cont_fnsh_date", cont_fnsh_date)
				&&  datatoxml.setData("cont_term_text", cont_term_text)
				&&  datatoxml.setData("cont_pric_rate", cont_pric_rate)
				&&  datatoxml.setData("cont_unit_divs", cont_unit_divs)
				/* End of 계약정보 */

				/* Begin of 채권자 정보 */
//				&&  datatoxml.setData("cred_exst_code", cred_exst_code)
				&&  datatoxml.setData("cred_orga_name", cred_orga_name)
				&&  datatoxml.setData("cred_orps_divs", cred_orps_divs)
				&&  datatoxml.setData("cred_orga_numb", cred_orga_numb)
				&&  datatoxml.setData("cred_orps_iden", cred_orps_iden)
				&&  datatoxml.setData("cred_ownr_numb", cred_ownr_numb)
				&&  datatoxml.setData("cred_ownr_name", cred_ownr_name)
				&&  datatoxml.setData("cred_bond_hold", cred_bond_hold)
				&&  datatoxml.setData("cred_addn_name", cred_addn_name)
				&&  datatoxml.setData("cred_orga_post", cred_orga_post)
				&&  datatoxml.setData("cred_orga_addr", cred_orga_addr)
				&&  datatoxml.setData("cred_chrg_name", cred_chrg_name)
				&&  datatoxml.setData("cred_dept_name", cred_dept_name)
				&&  datatoxml.setData("cred_phon_numb", cred_phon_numb)
				&&  datatoxml.setData("cred_cell_phon", cred_cell_phon)
				&&  datatoxml.setData("cred_send_mail", cred_send_mail)
				&&  datatoxml.setData("cred_user_iden", cred_user_iden)
				&&  datatoxml.setData("cred_user_type", cred_user_type)
				/* End of 채권자 정보 */

				/* Begin of 계약자 정보 */
				&&  datatoxml.setData("appl_orga_name", appl_orga_name)
				&&  datatoxml.setData("appl_orps_divs", appl_orps_divs)
				&&  datatoxml.setData("appl_orga_numb", appl_orga_numb)
				&&  datatoxml.setData("appl_orps_iden", appl_orps_iden)
				&&  datatoxml.setData("appl_ownr_numb", appl_ownr_numb)
				&&  datatoxml.setData("appl_ownr_name", appl_ownr_name)
				&&  datatoxml.setData("appl_addn_name", appl_addn_name)
				&&  datatoxml.setData("appl_orga_post", appl_orga_post)
				&&  datatoxml.setData("appl_orga_addr", appl_orga_addr)
				&&  datatoxml.setData("appl_chrg_name", appl_chrg_name)
				&&  datatoxml.setData("appl_dept_name", appl_dept_name)
				&&  datatoxml.setData("appl_offc_phon", appl_offc_phon)
				&&  datatoxml.setData("appl_cell_phon", appl_cell_phon)
				&&  datatoxml.setData("appl_send_mail", appl_send_mail)
				&&  datatoxml.setData("appl_home_post", appl_home_post)
				&&  datatoxml.setData("appl_home_addr", appl_home_addr)
				&&  datatoxml.setData("appl_home_phon", appl_home_phon)
				&&  datatoxml.setData("appl_user_iden", appl_user_iden)
				&&  datatoxml.setData("appl_user_type", appl_user_type)
				/* End of 계약자 정보 */

				/* Begin of 수요자 정보 */
				&&  datatoxml.setData("mang_orga_name", mang_orga_name)
				&&  datatoxml.setData("mang_orps_divs", mang_orps_divs)
				&&  datatoxml.setData("mang_orps_iden", mang_orps_iden)
				&&  datatoxml.setData("mang_ownr_numb", mang_ownr_numb)
				&&  datatoxml.setData("mang_ownr_name", mang_ownr_name)
				&&  datatoxml.setData("mang_addn_name", mang_addn_name)
				&&  datatoxml.setData("mang_orga_post", mang_orga_post)
				&&  datatoxml.setData("mang_orga_addr", mang_orga_addr)
				&&  datatoxml.setData("mang_bond_hold", mang_bond_hold)
				&&  datatoxml.setData("mang_chrg_name", mang_chrg_name)
				&&  datatoxml.setData("mang_dept_name", mang_dept_name)
				&&  datatoxml.setData("mang_phon_numb", mang_phon_numb)
				&&  datatoxml.setData("mang_cell_phon", mang_cell_phon)
				&&  datatoxml.setData("mang_send_mail", mang_send_mail)
				&&  datatoxml.setData("mang_user_iden", mang_user_iden)
				&&  datatoxml.setData("mang_user_type", mang_user_type)
				/* End of 수요자 정보 */
			) {
				return datatoxml.getxmlData();
			} else {
				System.out.println(datatoxml.getErrorMsg());
				return null;
			}
		}
		catch(Exception _e) {
			return null;
		}
	}

	/* 전자보증-선급이행증권*/
	/* 선급정보통보서(PREINF) */
	public String composeXML2(String CONT_START_DATE
			   			   , String CONT_END_DATE
						   , String MASTER_CONT_NO_NEW
						   , String CONT_TITLE
						   , String CONT_DATE_1
			               , String CONT_DATE
			               , String AMT
			               , String SDIFFDAYS
			               , String FIRST_SECURITIES_AMT
			               , String FIRST_SECURITIES_AMT_RATE
			               , String SYSDATE
			               , String SYSTIME
			               , String VENDOR_NAME_LOC
			               , String CEO_NAME_LOC
			               , String workGubun
			               , String hostCode
			               , String IRS_NO_VENDOR		//공급사 사업자번호
			               , String AMT_INSU_NUM
			               , String PREGIVEDATE			//선급지급예정일
			               ) throws Exception
	{
		/* HEADER */
		String	head_mesg_send  =this.strSGICSenderCode;	/*	[필수]	 전문송신기관 (고정)*/
		String	head_mesg_recv  =this.strSGICCode;			/*	[필수]	 전문수신기관 (고정?)*/
		String	head_func_code  =this.strHeadFuncCode;		/*	[필수]	 문서기능	(운영에는 9로 수정*/
		String	head_mesg_type  ="PREINF";					/*	[필수]	 문서코드	(고정)*/
		String	head_mesg_name  = "선급정보통보서";				/*	[필수]	 문서명 (고정)*/
		String	head_mesg_vers  ="1.0";						/*	[선택]	 전자문서버전	(고정)*/
		String	head_docu_numb  ="004004" + MASTER_CONT_NO_NEW + " 00";		/*	[필수]	 문서번호	*/
		String	head_mang_numb  =this.strSGICSenderCode + "." + SYSDATE + SYSTIME + ".12345." + "004004" + MASTER_CONT_NO_NEW + " 00";	/*	[필수]	 문서관리번호	*/
		String	head_refr_numb  ="004004" + MASTER_CONT_NO_NEW + " 00";		/*	[필수]	 참조번호	*/
		String	head_titl_name  ="계약정보통보서";				/*	[필수]	 문서개요	(고정)*/
		String  head_orga_code  ="DMC";             		/*  [필수]   연계코드   (고정)*/

		/* 보험계약정보 */
		String	bond_kind_code  ="004";						/*	[필수]	" 보험종목구분(002:계약,003:하자,004:선금,006:지급)"	(고정)*/
		String	bond_begn_date  =CONT_START_DATE;			/*	[선택]	 보험개시일자	선급일경우 선택*/
		String	bond_fnsh_date  =CONT_END_DATE;				/*	[필수]	 보험종료일자	***********************************/
		String	bond_curc_code  ="WON";						/*	[필수]	" 보험가입금액/통화코드(WON, USD …)"	(고정)*/
		String	bond_oper_code  ="SELECT";					/*	[선택]	" 조회등록 업무구분(SELECT,INSERT)"	 (고정)*/
		String	bond_penl_amnt  =FIRST_SECURITIES_AMT;		/*	[필수]	보험가입금액 예) 1500000- 선금지급(예정) 금액*/
		String	bond_appl_code  =workGubun;					/*	[필수]	" 신규배서 업무구분(10:신규,20:연장,60:증액,62:연장증액,70:감액,90:기타)"	(고정)*/

		/* 주요계약정보 */
		String	cont_numb_text  =MASTER_CONT_NO_NEW;		/*	[필수]	 계약번호	*/
		String	cont_name_text  =CONT_TITLE;				/*	[필수]	 계약건명	*/
		String	cont_proc_type  ="F00";						/*	[필수]	 계약구분	????????????????????*/
		String	cont_type_iden  ="2";						/*	[필수]	" 계약방식(1:공동, 2:단독, 3:분담)"	(고정)*/
		String	cont_asgn_rate  =null;						/*	[선택]	 지분율	*/
		String	cont_news_divs  ="1";						/*	[필수]	" 신규/갱신 계약구분(1:신규계약, 2:갱신계약)"	(고정)*/
		String	cont_plan_date  =CONT_DATE_1;			/*	[선택]	 준공예정일	*/
		String	cont_main_date  =CONT_DATE;					/*	[선택]	 계약체결일자	*/
		String	cont_curc_code  ="WON";						/*	[필수]	 계약금액(원화)/통화코드(WON)	(고정)*/
		String	forn_curc_code  =null;						/*	[선택]	 계약금액(외화)/통화코드(USD …)	*/
		String	forn_main_amnt  =null;						/*	[선택]	 계약금액(외화)/계약금액	*/
		String	cont_main_amnt  =AMT;						/*	[필수]	 계약금액(원화)/계약금액	*/
		String	hist_bond_numb  =AMT_INSU_NUM;				/*	[선택]	 배서대상 증권번호	*/

		/* 선급정보 */
		String  prep_paym_type	="2";						/*  [필수}   	지급구분 - 1:직불(수요자), 2;대지급(채권자)*******************************/
		String	prep_begn_date  =CONT_START_DATE;			/*	[필수]	계약시작일자*/
		String	prep_fnsh_date  =CONT_END_DATE;				/*	[필수]	계약종료일자	*/
		String	prep_term_text  =SDIFFDAYS;					/*	[선택]	계약기간	*/
		String	prep_paym_date  =PREGIVEDATE;				/*	[필수]	선금지급(예정)일자 - YYYYMMDD"	CONT_START_DATE+7*/
		String	prep_curc_code  ="WON";						/*	[필수]	선금지급(예정)금액(원화) 통화코드 - WON(원화)	*/
		String	prep_paym_amnt  =FIRST_SECURITIES_AMT;		/*	[필수]	선금지급(예정)금액(원화) - 예)1500000*/

		/* 채권자 정보 */
		String	cred_orga_name  ="(주)대명소노시즌";				/*	[필수]	 기관명	*/
		String	cred_orps_divs  ="O";						/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	cred_orga_numb  ="1801110068668";			/*	[필수]	 법인등록번호	*/
		String	cred_orps_iden  ="6048115788";				/*	[필수]	 사업자/주민번호	*/
		String	cred_ownr_numb  ="1111111111111";			/*	[필수]	 대표자 주민등록번호	*/
		String	cred_ownr_name  ="서준혁";					/*	[필수]	 성명(대표자명)  */
		String	cred_bond_hold  ="서준혁";						/*	[필수]	 채권자명	*/
		String	cred_addn_name  ="";						/*	[선택]	 채권기관 부가상호	??*/
		String	cred_orga_post  ="25102";					/*	[필수]	 회사 우편번호	*/
		String	cred_orga_addr  ="강원도 홍천군 서면 한치골길 262";		/*	[필수]	 회사 주소	*/
		String	cred_chrg_name  ="차호정";						/*	[필수]	 담당자명	*/
		String	cred_dept_name  ="기획지원팀";					/*	[필수]	 소속부서	*/
		String	cred_phon_numb  ="02-2222-7573";			/*	[필수]	 전화번호	*/
		String	cred_cell_phon  ="010-4646-0856";			/*	[필수]	 핸드폰번호	*/
		String	cred_send_mail  ="hojung.cha@daemyung.com";	/*	[필수]	 담당자 EMAIL	*/
		String	cred_user_iden  =this.strSGICSenderCode;	/*	[필수]	 수신처ID	*/
		String	cred_user_type  ="DMC";						/*	[필수]	 수신처TYPE	*/

		/* 계약자 정보 */
		String	appl_orga_name  =VENDOR_NAME_LOC;	/*	[필수]	 기관명	*/
		String	appl_orps_divs  ="O";				/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	appl_orga_numb  =null;				/*	[선택]	 법인등록번호	*/
		String	appl_orps_iden  =IRS_NO_VENDOR;		/*	[필수]	 사업자/주민번호	*/
		String	appl_ownr_numb  ="1111111111111";	/*	[필수]	 대표자 주민등록번호	(고정)*/
		String	appl_ownr_name  =CEO_NAME_LOC;    	/*	[필수]	 성명(대표자명)	*/
		String	appl_addn_name  =null;				/*	[선택]	 계약업체 부가상호	*/
		String	appl_orga_post  =null;				/*	[선택]	 회사 우편번호	*/
		String	appl_orga_addr  =null;				/*	[선택]	 회사 주소	*/
		String	appl_chrg_name  =null;				/*	[선택]	 담당자명	*/
		String	appl_dept_name  =null;				/*	[선택]	 소속부서	*/
		String	appl_offc_phon  =null;				/*	[선택]	 전화번호	*/
		String	appl_cell_phon  =null;				/*	[선택]	 핸드폰번호	*/
		String	appl_send_mail  =null;				/*	[선택]	 담당자 EMAIL	*/
		String	appl_home_post  =null;				/*	[선택]	 자택 우편번호	*/
		String	appl_home_addr  =null;				/*	[선택]	 자택 주소	*/
		String	appl_home_phon  =null;				/*	[선택]	 자택 전화번호	*/
		String	appl_user_iden  ="B123456789012";	/*	[필수]	 수신처ID	*/
		String	appl_user_type  ="DMC";				/*	[필수]	 수신처TYPE	*/

		/* 수요자 정보 사용하지 않지만 빈값으로 넘김*/
		String	mang_orga_name  =null;				/*	[선택]	 기관명	*/
		String	mang_orps_divs  =null;				/*	[선택]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	mang_orps_iden  =null;				/*	[선택]	 사업자/주민번호	*/
		String	mang_ownr_numb  =null;				/*	[선택]	 대표자 주민등록번호	*/
		String	mang_ownr_name  =null;				/*	[선택]	 성명(대표자명)	*/
		String	mang_addn_name  =null;				/*	[선택]	 수요(대행)업체 부가상호	*/
		String	mang_orga_post  =null;				/*	[선택]	 회사 우편번호	*/
		String	mang_orga_addr  =null;				/*	[선택]	 회사 주소	*/
		String	mang_bond_hold  =null;				/*	[선택]	 채권자명	*/
		String	mang_chrg_name  =null;				/*	[선택]	 담당자명	*/
		String	mang_dept_name  =null;				/*	[선택]	 소속부서	*/
		String	mang_phon_numb  =null;				/*	[선택]	 전화번호	*/
		String	mang_cell_phon  =null;				/*	[선택]	 핸드폰번호	*/
		String	mang_send_mail  =null;				/*	[선택]	 담당자 EMAIL	*/
		String	mang_user_iden  =null;				/*	[선택]	 수신처ID	*/
		String	mang_user_type  =null;				/*	[선택]	 수신처TYPE	*/

		// 매핑 정보 파일, XML 탬플릿 정보 파일

		DataToXml datatoxml = new DataToXml(PropertiesManager.getString("sgic_templates_path"), "PREINF");
		if(datatoxml.getErrorCode()!=0) {
			System.out.println(datatoxml.getErrorMsg());
			return null;
		}

		/* 선급정보통보서(PREINF) */
		/* HEADER */
		try{
			if(
				/* Begin of Header */
					datatoxml.setData("head_mesg_send", head_mesg_send)
				&&	datatoxml.setData("head_mesg_recv", head_mesg_recv)
				&&	datatoxml.setData("head_func_code", head_func_code)
				&&	datatoxml.setData("head_mesg_type", head_mesg_type)
				&&	datatoxml.setData("head_mesg_name", head_mesg_name)
				&&	datatoxml.setData("head_mesg_vers", head_mesg_vers)
				&&	datatoxml.setData("head_docu_numb", head_docu_numb)
				&&	datatoxml.setData("head_mang_numb", head_mang_numb)
				&&	datatoxml.setData("head_refr_numb", head_refr_numb)
				&&	datatoxml.setData("head_titl_name", head_titl_name)
				&&  datatoxml.setData("head_orga_code", head_orga_code)
				/* End of Header */

				/* Begin of 보험계약정보 */
				&&  datatoxml.setData("bond_kind_code", bond_kind_code)
				&&  datatoxml.setData("bond_begn_date", bond_begn_date)
				&&  datatoxml.setData("bond_fnsh_date", bond_fnsh_date)
				&&  datatoxml.setData("bond_curc_code", bond_curc_code)
				&&  datatoxml.setData("bond_penl_amnt", bond_penl_amnt)
				&&  datatoxml.setData("bond_oper_code", bond_oper_code)
				&&  datatoxml.setData("bond_appl_code", bond_appl_code)
				/* End of 보험계약정보 */

				/* Begin of 주요계약정보 */
				&&  datatoxml.setData("cont_numb_text", cont_numb_text)
				&&  datatoxml.setData("cont_name_text", cont_name_text)
				&&  datatoxml.setData("cont_proc_type", cont_proc_type)
				&&  datatoxml.setData("cont_type_iden", cont_type_iden)
				//&&  datatoxml.setData("cont_asgn_rate", cont_asgn_rate)
				&&  datatoxml.setData("cont_news_divs", cont_news_divs)
				&&  datatoxml.setData("cont_plan_date", cont_plan_date)
				&&  datatoxml.setData("cont_main_date", cont_main_date)
				&&  datatoxml.setData("cont_curc_code", cont_curc_code)
				&&  datatoxml.setData("cont_main_amnt", cont_main_amnt)
				//&&  datatoxml.setData("forn_curc_code", forn_curc_code)
				//&&  datatoxml.setData("forn_main_amnt", forn_main_amnt)
				&&  datatoxml.setData("hist_bond_numb", hist_bond_numb)
				/* End of 주요계약정보 */

				/* Begin of 선급정보 */
				&&  datatoxml.setData("prep_paym_type", prep_paym_type)
				&&  datatoxml.setData("prep_begn_date", prep_begn_date)
				&&  datatoxml.setData("prep_fnsh_date", prep_fnsh_date)
				&&  datatoxml.setData("prep_term_text", prep_term_text)
				&&  datatoxml.setData("prep_paym_date", prep_paym_date)
				&&  datatoxml.setData("prep_curc_code", prep_curc_code)
				&&  datatoxml.setData("prep_paym_amnt", prep_paym_amnt)
				/* End of 계약정보 */

				/* Begin of 채권자 정보 */
				//&&  datatoxml.setData("cred_exst_code", cred_exst_code)
				&&  datatoxml.setData("cred_orga_name", cred_orga_name)
				&&  datatoxml.setData("cred_orps_divs", cred_orps_divs)
				&&  datatoxml.setData("cred_orga_numb", cred_orga_numb)
				&&  datatoxml.setData("cred_orps_iden", cred_orps_iden)
				&&  datatoxml.setData("cred_ownr_numb", cred_ownr_numb)
				&&  datatoxml.setData("cred_ownr_name", cred_ownr_name)
				&&  datatoxml.setData("cred_bond_hold", cred_bond_hold)
				&&  datatoxml.setData("cred_addn_name", cred_addn_name)
				&&  datatoxml.setData("cred_orga_post", cred_orga_post)
				&&  datatoxml.setData("cred_orga_addr", cred_orga_addr)
				&&  datatoxml.setData("cred_chrg_name", cred_chrg_name)
				&&  datatoxml.setData("cred_dept_name", cred_dept_name)
				&&  datatoxml.setData("cred_phon_numb", cred_phon_numb)
				&&  datatoxml.setData("cred_cell_phon", cred_cell_phon)
				&&  datatoxml.setData("cred_send_mail", cred_send_mail)
				&&  datatoxml.setData("cred_user_iden", cred_user_iden)
				&&  datatoxml.setData("cred_user_type", cred_user_type)
				/* End of 채권자 정보 */

				/* Begin of 계약자 정보 */
				&&  datatoxml.setData("appl_orga_name", appl_orga_name)
				&&  datatoxml.setData("appl_orps_divs", appl_orps_divs)
				&&  datatoxml.setData("appl_orga_numb", appl_orga_numb)
				&&  datatoxml.setData("appl_orps_iden", appl_orps_iden)
				&&  datatoxml.setData("appl_ownr_numb", appl_ownr_numb)
				&&  datatoxml.setData("appl_ownr_name", appl_ownr_name)
				&&  datatoxml.setData("appl_addn_name", appl_addn_name)
				&&  datatoxml.setData("appl_orga_post", appl_orga_post)
				&&  datatoxml.setData("appl_orga_addr", appl_orga_addr)
				&&  datatoxml.setData("appl_chrg_name", appl_chrg_name)
				&&  datatoxml.setData("appl_dept_name", appl_dept_name)
				&&  datatoxml.setData("appl_offc_phon", appl_offc_phon)
				&&  datatoxml.setData("appl_cell_phon", appl_cell_phon)
				&&  datatoxml.setData("appl_send_mail", appl_send_mail)
				&&  datatoxml.setData("appl_home_post", appl_home_post)
				&&  datatoxml.setData("appl_home_addr", appl_home_addr)
				&&  datatoxml.setData("appl_home_phon", appl_home_phon)
				&&  datatoxml.setData("appl_user_iden", appl_user_iden)
				&&  datatoxml.setData("appl_user_type", appl_user_type)
				/* End of 계약자 정보 */

				/* Begin of 수요자 정보 */
				&&  datatoxml.setData("mang_orga_name", mang_orga_name)
				&&  datatoxml.setData("mang_orps_divs", mang_orps_divs)
				&&  datatoxml.setData("mang_orps_iden", mang_orps_iden)
				&&  datatoxml.setData("mang_ownr_numb", mang_ownr_numb)
				&&  datatoxml.setData("mang_ownr_name", mang_ownr_name)
				&&  datatoxml.setData("mang_addn_name", mang_addn_name)
				&&  datatoxml.setData("mang_orga_post", mang_orga_post)
				&&  datatoxml.setData("mang_orga_addr", mang_orga_addr)
				&&  datatoxml.setData("mang_bond_hold", mang_bond_hold)
				&&  datatoxml.setData("mang_chrg_name", mang_chrg_name)
				&&  datatoxml.setData("mang_dept_name", mang_dept_name)
				&&  datatoxml.setData("mang_phon_numb", mang_phon_numb)
				&&  datatoxml.setData("mang_cell_phon", mang_cell_phon)
				&&  datatoxml.setData("mang_send_mail", mang_send_mail)
				&&  datatoxml.setData("mang_user_iden", mang_user_iden)
				&&  datatoxml.setData("mang_user_type", mang_user_type)
				/* End of 수요자 정보 */
			) {
				return datatoxml.getxmlData();
			}else{
				System.out.println(datatoxml.getErrorMsg());
				return null;
			}
		}
		catch(Exception _e) {
			return null;
		}
	}

	/* 전자보증-하자이행증권 */
	/* 하자정보 통보서(FLRINF) */
	public String composeXML3(String CONT_START_DATE
							, String CONT_END_DATE
							, String MASTER_CONT_NO_NEW
							, String CONT_WARRANTY_AMT
							, String CONT_TITLE
							, String CONT_DATE_1
							, String CONT_DATE
							, String AMT
							, String SDIFFDAYS2
							, String MENGEL_WARRANTY_AMT
							, String MENGEL_WARRANTY_AMT_RATE
							, String MENGEL_START_DATE
							, String MENGEL_END_DATE
							, String SYSDATE
							, String SYSTIME
							, String VENDOR_NAME_LOC
							, String CEO_NAME_LOC
							, String workGubun
							, String hostCode
							, String IRS_NO_VENDOR		//공급사 사업자번호
							, String AS_INSU_NUM
							, String PREGIVEDATE
				            )
	{
		/* HEADER */
		String	head_mesg_send  =this.strSGICSenderCode;	/*	[필수]	 전문송신기관 (고정)*/
		String	head_mesg_recv  =this.strSGICCode;			/*	[필수]	 전문수신기관 (고정?)*/
		String	head_func_code  =this.strHeadFuncCode;		/*	[필수]	 문서기능	(운영에는 9로 수정*/
		String	head_mesg_type  ="FLRINF";					/*	[필수]	 문서코드	(고정)*/
		String	head_mesg_name  ="하자정보통보서";				/*	[필수]	 문서명 (고정)*/
		String	head_mesg_vers  ="1.0";						/*	[선택]	 전자문서버전	(고정)*/
		String	head_docu_numb  ="004003" + MASTER_CONT_NO_NEW + " 00";		/*	[필수]	 문서번호	*/
		String	head_mang_numb  =this.strSGICSenderCode + "." + SYSDATE + SYSTIME + ".12345." + "004003" + MASTER_CONT_NO_NEW + " 00";	/*	[필수]	 문서관리번호	*/
		String	head_refr_numb  ="004003" + MASTER_CONT_NO_NEW + " 00";		/*	[필수]	 참조번호	*/
		String	head_titl_name  ="하자정보통보서";				/*	[필수]	 문서개요	(고정)*/
		String  head_orga_code  ="DMC";             		/*  [필수]    연계코드   (고정)*/

		/* 보험계약정보 */
		String	bond_kind_code  ="003";						/*	[필수]	" 보험종목구분(002:계약,003:하자,004:선금,006:지급)"	(고정)*/
		String	bond_begn_date  =CONT_START_DATE;			/*	[선택]	 보험개시일자	*/
		String	bond_fnsh_date  =CONT_END_DATE;				/*	[필수]	 보험종료일자	***********************************/
		String	bond_curc_code  ="WON";						/*	[필수]	" 보험가입금액/통화코드(WON, USD …)"	(고정)*/
		String	bond_oper_code  ="SELECT";					/*	[선택]	" 조회등록 업무구분(SELECT,INSERT)"	 (고정)*/
		String	bond_penl_amnt  =CONT_WARRANTY_AMT;			/*	[필수]	보험가입금액 예) 1500000- 계약금액 * 하자보증금율*************************/
		String	bond_appl_code  =workGubun;					/*	[필수]	" 신규배서 업무구분(10:신규,20:연장,60:증액,62:연장증액,70:감액,90:기타)"	(고정)*/

		/* 주요계약정보(공통) */
		String	cont_numb_text  =MASTER_CONT_NO_NEW;		/*	[필수]	 계약번호	*/
		String	cont_name_text  =CONT_TITLE;				/*	[필수]	 계약건명	*/
		String	cont_proc_type  ="F00";						/*	[필수]	 계약구분	******************************/
		String	cont_type_iden  ="2";						/*	[필수]	" 계약방식(1:공동, 2:단독, 3:분담)"	(고정)*/
		String	cont_asgn_rate  =null;						/*	[선택]	 지분율	*/
		String	cont_news_divs  ="1";						/*	[필수]	" 신규/갱신 계약구분(1:신규계약, 2:갱신계약)"	(고정)*/
		String	cont_plan_date  =CONT_DATE_1;				/*	[선택]	 준공예정일	*/
		String	cont_main_date  =CONT_DATE;					/*	[선택]	 계약체결일자	*/
		String	cont_curc_code  ="WON";						/*	[필수]	 계약금액(원화)/통화코드(WON)	(고정)*/
		String	forn_curc_code  =null;						/*	[선택]	 계약금액(외화)/통화코드(USD …)	*/
		String	forn_main_amnt  =null;						/*	[선택]	 계약금액(외화)/계약금액	*/
		String	cont_main_amnt  =AMT;						/*	[필수]	 계약금액(원화)/계약금액	*/
		String	hist_bond_numb  =AS_INSU_NUM;				/*	[선택]	 배서대상 증권번호	*/

		/* 하자정보 */
		String	morg_begn_date  =MENGEL_START_DATE;			/*	[필수]	 하자보수 책임시작일 - YYYYMMDD*/
		String	morg_fnsh_date  =MENGEL_END_DATE;			/*	[필수]	 하자보수 책임종료일 - YYYYMMDD	*/
		String	morg_term_text  =SDIFFDAYS2;				/*	[선택]	 하자보수 책임기간 = 하자보수책임 종료일자-하자보수책임 시작일자(하자보수책임 총 일수) 	*/
		String	morg_pric_rate  =MENGEL_WARRANTY_AMT_RATE;	/*	[필수]	 하자보증금율 */

		/* 채권자 정보 */
		String	cred_orga_name  ="(주)대명소노시즌";				/*	[필수]	 기관명	*/
		String	cred_orps_divs  ="O";						/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	cred_orga_numb  ="1801110068668";			/*	[필수]	 법인등록번호	*/
		String	cred_orps_iden  ="6048115788";				/*	[필수]	 사업자/주민번호	*/
		String	cred_ownr_numb  ="1111111111111";			/*	[필수]	 대표자 주민등록번호	*/
		String	cred_ownr_name  ="서준혁";						/*	[필수]	 성명(대표자명)	*/
		String	cred_bond_hold  ="서준혁";						/*	[필수]	 채권자명	*/
		String	cred_addn_name  ="";						/*	[선택]	 채권기관 부가상호	??*/
		String	cred_orga_post  ="25102";					/*	[필수]	 회사 우편번호	*/
		String	cred_orga_addr  ="강원도 홍천군 서면 한치골길 262";		/*	[필수]	 회사 주소	*/
		String	cred_chrg_name  ="차호정";						/*	[필수]	 담당자명	*/
		String	cred_dept_name  ="기획지원팀";					/*	[필수]	 소속부서	*/
		String	cred_phon_numb  ="02-2222-7573";			/*	[필수]	 전화번호	*/
		String	cred_cell_phon  ="010-4646-0856";			/*	[필수]	 핸드폰번호	*/
		String	cred_send_mail  ="hojung.cha@daemyung.com";	/*	[필수]	 담당자 EMAIL	*/
		String	cred_user_iden  =this.strSGICSenderCode;	/*	[필수]	 수신처ID	*/
		String	cred_user_type  ="DMC";						/*	[필수]	 수신처TYPE	*/

		/* 계약자 정보 */
		String	appl_orga_name  =VENDOR_NAME_LOC;	/*	[필수]	 기관명	*/
		String	appl_orps_divs  ="O";				/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	appl_orga_numb  =null;				/*	[선택]	 법인등록번호	*/
		String	appl_orps_iden  =IRS_NO_VENDOR;		/*	[필수]	 사업자/주민번호	*/
		String	appl_ownr_numb  ="1111111111111";	/*	[필수]	 대표자 주민등록번호	(고정)*/
		String	appl_ownr_name  =CEO_NAME_LOC;		/*	[필수]	 성명(대표자명)	*/
		String	appl_addn_name  =null;				/*	[선택]	 계약업체 부가상호	*/
		String	appl_orga_post  =null;				/*	[선택]	 회사 우편번호	*/
		String	appl_orga_addr  =null;				/*	[선택]	 회사 주소	*/
		String	appl_chrg_name  =null;				/*	[선택]	 담당자명	*/
		String	appl_dept_name  =null;				/*	[선택]	 소속부서	*/
		String	appl_offc_phon  =null;				/*	[선택]	 전화번호	*/
		String	appl_cell_phon  =null;				/*	[선택]	 핸드폰번호	*/
		String	appl_send_mail  =null;				/*	[선택]	 담당자 EMAIL	*/
		String	appl_home_post  =null;				/*	[선택]	 자택 우편번호	*/
		String	appl_home_addr  =null;				/*	[선택]	 자택 주소	*/
		String	appl_home_phon  =null;				/*	[선택]	 자택 전화번호	*/
		String	appl_user_iden  ="B123456789012";	/*	[필수]	 수신처ID	*/
		String	appl_user_type  ="DMC";				/*	[필수]	 수신처TYPE	*/

		/* 수요자 정보 사용하지 않지만 빈값으로 넘김*/
		String	mang_orga_name  =null;				/*	[선택]	 기관명	*/
		String	mang_orps_divs  =null;				/*	[선택]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	mang_orps_iden  =null;				/*	[선택]	 사업자/주민번호	*/
		String	mang_ownr_numb  =null;				/*	[선택]	 대표자 주민등록번호	*/
		String	mang_ownr_name  =null;				/*	[선택]	 성명(대표자명)	*/
		String	mang_addn_name  =null;				/*	[선택]	 수요(대행)업체 부가상호	*/
		String	mang_orga_post  =null;				/*	[선택]	 회사 우편번호	*/
		String	mang_orga_addr  =null;				/*	[선택]	 회사 주소	*/
		String	mang_bond_hold  =null;				/*	[선택]	 채권자명	*/
		String	mang_chrg_name  =null;				/*	[선택]	 담당자명	*/
		String	mang_dept_name  =null;				/*	[선택]	 소속부서	*/
		String	mang_phon_numb  =null;				/*	[선택]	 전화번호	*/
		String	mang_cell_phon  =null;				/*	[선택]	 핸드폰번호	*/
		String	mang_send_mail  =null;				/*	[선택]	 담당자 EMAIL	*/
		String	mang_user_iden  =null;				/*	[선택]	 수신처ID	*/
		String	mang_user_type  =null;				/*	[선택]	 수신처TYPE	*/

		// 매핑 정보 파일, XML 탬플릿 정보 파일
		DataToXml datatoxml = new DataToXml(PropertiesManager.getString("sgic_templates_path"), "FLRINF");
		if(datatoxml.getErrorCode()!=0) {
			System.out.println(datatoxml.getErrorMsg());
			return null;
		}

		/* 계약정보통보서(CONINF) */
		/* HEADER */
		try{
			if(
				/* Begin of Header */
					datatoxml.setData("head_mesg_send", head_mesg_send)
				&&	datatoxml.setData("head_mesg_recv", head_mesg_recv)
				&&	datatoxml.setData("head_func_code", head_func_code)
				&&	datatoxml.setData("head_mesg_type", head_mesg_type)
				&&	datatoxml.setData("head_mesg_name", head_mesg_name)
				&&	datatoxml.setData("head_mesg_vers", head_mesg_vers)
				&&	datatoxml.setData("head_docu_numb", head_docu_numb)
				&&	datatoxml.setData("head_mang_numb", head_mang_numb)
				&&	datatoxml.setData("head_refr_numb", head_refr_numb)
				&&	datatoxml.setData("head_titl_name", head_titl_name)
				&&  datatoxml.setData("head_orga_code", head_orga_code)
				/* End of Header */

				/* Begin of 보험계약정보 */
				&&  datatoxml.setData("bond_kind_code", bond_kind_code)
				&&  datatoxml.setData("bond_begn_date", bond_begn_date)
				&&  datatoxml.setData("bond_fnsh_date", bond_fnsh_date)
				&&  datatoxml.setData("bond_curc_code", bond_curc_code)
				&&  datatoxml.setData("bond_penl_amnt", bond_penl_amnt)
				&&  datatoxml.setData("bond_oper_code", bond_oper_code)
				&&  datatoxml.setData("bond_appl_code", bond_appl_code)
				/* End of 보험계약정보 */

				/* Begin of 주요계약정보 */
				&&  datatoxml.setData("cont_numb_text", cont_numb_text)
				&&  datatoxml.setData("cont_name_text", cont_name_text)
				&&  datatoxml.setData("cont_proc_type", cont_proc_type)
				&&  datatoxml.setData("cont_type_iden", cont_type_iden)
				//&&  datatoxml.setData("cont_asgn_rate", cont_asgn_rate)
				&&  datatoxml.setData("cont_news_divs", cont_news_divs)
				&&  datatoxml.setData("cont_plan_date", cont_plan_date)
				&&  datatoxml.setData("cont_main_date", cont_main_date)
				&&  datatoxml.setData("cont_curc_code", cont_curc_code)
				&&  datatoxml.setData("cont_main_amnt", cont_main_amnt)
				//&&  datatoxml.setData("forn_curc_code", forn_curc_code)
				//&&  datatoxml.setData("forn_main_amnt", forn_main_amnt)
				&&  datatoxml.setData("hist_bond_numb", hist_bond_numb)
				/* End of 주요계약정보 */

				/* Begin of 선급정보 */
				&&  datatoxml.setData("morg_begn_date", morg_begn_date)
				&&  datatoxml.setData("morg_fnsh_date", morg_fnsh_date)
				&&  datatoxml.setData("morg_term_text", morg_term_text)
				&&  datatoxml.setData("morg_pric_rate", morg_pric_rate)
				/* End of 계약정보 */

				/* Begin of 채권자 정보 */
				//&&  datatoxml.setData("cred_exst_code", cred_exst_code)
				&&  datatoxml.setData("cred_orga_name", cred_orga_name)
				&&  datatoxml.setData("cred_orps_divs", cred_orps_divs)
				&&  datatoxml.setData("cred_orga_numb", cred_orga_numb)
				&&  datatoxml.setData("cred_orps_iden", cred_orps_iden)
				&&  datatoxml.setData("cred_ownr_numb", cred_ownr_numb)
				&&  datatoxml.setData("cred_ownr_name", cred_ownr_name)
				&&  datatoxml.setData("cred_bond_hold", cred_bond_hold)
				&&  datatoxml.setData("cred_addn_name", cred_addn_name)
				&&  datatoxml.setData("cred_orga_post", cred_orga_post)
				&&  datatoxml.setData("cred_orga_addr", cred_orga_addr)
				&&  datatoxml.setData("cred_chrg_name", cred_chrg_name)
				&&  datatoxml.setData("cred_dept_name", cred_dept_name)
				&&  datatoxml.setData("cred_phon_numb", cred_phon_numb)
				&&  datatoxml.setData("cred_cell_phon", cred_cell_phon)
				&&  datatoxml.setData("cred_send_mail", cred_send_mail)
				&&  datatoxml.setData("cred_user_iden", cred_user_iden)
				&&  datatoxml.setData("cred_user_type", cred_user_type)
				/* End of 채권자 정보 */

				/* Begin of 계약자 정보 */
				&&  datatoxml.setData("appl_orga_name", appl_orga_name)
				&&  datatoxml.setData("appl_orps_divs", appl_orps_divs)
				&&  datatoxml.setData("appl_orga_numb", appl_orga_numb)
				&&  datatoxml.setData("appl_orps_iden", appl_orps_iden)
				&&  datatoxml.setData("appl_ownr_numb", appl_ownr_numb)
				&&  datatoxml.setData("appl_ownr_name", appl_ownr_name)
				&&  datatoxml.setData("appl_addn_name", appl_addn_name)
				&&  datatoxml.setData("appl_orga_post", appl_orga_post)
				&&  datatoxml.setData("appl_orga_addr", appl_orga_addr)
				&&  datatoxml.setData("appl_chrg_name", appl_chrg_name)
				&&  datatoxml.setData("appl_dept_name", appl_dept_name)
				&&  datatoxml.setData("appl_offc_phon", appl_offc_phon)
				&&  datatoxml.setData("appl_cell_phon", appl_cell_phon)
				&&  datatoxml.setData("appl_send_mail", appl_send_mail)
				&&  datatoxml.setData("appl_home_post", appl_home_post)
				&&  datatoxml.setData("appl_home_addr", appl_home_addr)
				&&  datatoxml.setData("appl_home_phon", appl_home_phon)
				&&  datatoxml.setData("appl_user_iden", appl_user_iden)
				&&  datatoxml.setData("appl_user_type", appl_user_type)
				/* End of 계약자 정보 */

				/* Begin of 수요자 정보 */
				&&  datatoxml.setData("mang_orga_name", mang_orga_name)
				&&  datatoxml.setData("mang_orps_divs", mang_orps_divs)
				&&  datatoxml.setData("mang_orps_iden", mang_orps_iden)
				&&  datatoxml.setData("mang_ownr_numb", mang_ownr_numb)
				&&  datatoxml.setData("mang_ownr_name", mang_ownr_name)
				&&  datatoxml.setData("mang_addn_name", mang_addn_name)
				&&  datatoxml.setData("mang_orga_post", mang_orga_post)
				&&  datatoxml.setData("mang_orga_addr", mang_orga_addr)
				&&  datatoxml.setData("mang_bond_hold", mang_bond_hold)
				&&  datatoxml.setData("mang_chrg_name", mang_chrg_name)
				&&  datatoxml.setData("mang_dept_name", mang_dept_name)
				&&  datatoxml.setData("mang_phon_numb", mang_phon_numb)
				&&  datatoxml.setData("mang_cell_phon", mang_cell_phon)
				&&  datatoxml.setData("mang_send_mail", mang_send_mail)
				&&  datatoxml.setData("mang_user_iden", mang_user_iden)
				&&  datatoxml.setData("mang_user_type", mang_user_type)
				/* End of 수요자 정보 */
			) {
				return datatoxml.getxmlData();
			} else {
				System.out.println(datatoxml.getErrorMsg());
				return null;
			}
		}
		catch(Exception _e){
			return null;
		}
	}

	/* 최종응답서(계약이행보증)*/
	public String composeXML9(String MASTER_CONT_NO_NEW
							, String CONT_TITLE
							, String CONT_INSU_NUM
							, String VENDOR_NAME_LOC
							, String CEO_NAME_LOC
							, String SYSDATE
							, String SYSTIME
							, String IRS_NO_VENDOR		//공급사 사업자번호
							, String RBONGU_STATUS
							, String INSU_STATUS
							)
	{
		/* 최종응답서(RBONGU) */
		/* HEADER */

		String	head_mesg_send =this.strSGICSenderCode;	/*	[필수]	 전문송신기관[송신자ID]	*/
		String	head_mesg_recv =this.strSGICCode;		/*	[필수]	 전문수신기관[수신자ID]	*/
		String	head_func_code =(RBONGU_STATUS=="RBONGU_AP")?this.strHeadFuncCode:"1";	/*	[필수]	 문서기능코드(계약취소시 strHeadFuncCode=1)로 처리함	*/
		String	head_mesg_type ="RBONGU";				/*	[필수]	 문서코드	*/
		String	head_mesg_name ="최종응답서";				/*	[필수]	 문서명	*/
		String	head_mesg_vers ="1.0";					/*	[선택]	 문서버전	*/
		String	head_docu_numb =CONT_INSU_NUM;			/*	[필수]	 문서번호	CONT_INSU_NUM = 004+상품구분코드(3)+실증권번호(18)+' '+차수 로 구성*/
		String	head_mang_numb =this.strSGICSenderCode + "." + SYSDATE + SYSTIME + ".12345." + CONT_INSU_NUM;	/*	[필수]	 문서관리번호	*/
		String	head_refr_numb =CONT_INSU_NUM;			/*	[필수]	 참조번호	*/
		String	head_titl_name ="최종응답서";				/*	[필수]	 문서개요	*/
		String  head_orga_code ="DMC";             		/*  [필수]   연계기관코드   */

		/* 문서정보 */
		String	docu_numb_text =CONT_INSU_NUM.substring(6, CONT_INSU_NUM.length());	/*	[필수]	 증권번호	*/
		String	docu_kind_code ="002";					/*	[필수]	 보험종목(상품)코드	*/
		String	docu_user_type ="DMC";					/*	[필수]	 발신처 Type	*/

		/* 주요계약정보 */
		String	cont_numb_text =MASTER_CONT_NO_NEW;		/*	[필수]	 계약번호	*/
		String	cont_main_name =CONT_TITLE;				/*	[필수]	 계약명	*/

		/* 계약자 정보 */
		String	appl_orga_name =VENDOR_NAME_LOC;		/*	[필수]	 기관명	*/
		String	appl_orps_divs ="O";					/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	appl_orps_iden =IRS_NO_VENDOR;			/*	[필수]	 사업자/주민번호	*/
		String	appl_ownr_name =CEO_NAME_LOC;			/*	[필수]	 성명(대표자명)	*/

		/* 채권자 정보 */
		String	cred_bond_hold ="서준혁";					/*	[필수]	 채권자명	*/

		/* 응답 정보 */
		String	resp_type_code = "";
		String	resp_type_name = "";
		String	resp_mesg_text = "";
		//최종응답서 보낼때 진행상태 변경
		//거부일 경우 다시 SGI 에서 차수 변경해서 보증서가 전송되며, 최종응답서를 SGI에  재전송해야되므로 진행상태값이 그대로 계약서전송(31)상태로 있어야함)
		if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("SA") ){	//승인후 계약파기
			//status = "31";	//계약서전송
			resp_type_code = "DE";		//계약서 전송하면 계약완료로 봐야함
			resp_type_name = "파기";		/*	[필수]	 응답코드명	*/
			resp_mesg_text = "파기";		/*	[필수]	 응답내용		*/
		}else if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("TA")){ // 승인전 계약취소
			resp_type_code = "DD";		/*	[필수]	 응답 코드 (거부)		*/
			resp_type_name = "취소";		/*	[필수]	 응답코드명	*/
			resp_mesg_text = "취소";		/*	[필수]	 응답내용		*/
		}

		// 매핑 정보 파일, XML 탬플릿 정보 파일
		DataToXml datatoxml = new DataToXml(PropertiesManager.getString("sgic_templates_path"), "RBONGU");
		if(datatoxml.getErrorCode()!=0) {
			System.out.println(datatoxml.getErrorMsg());
			return null;
		}

		/* 최종응답서(RBONGU) */
		/* HEADER */
		try{
			if(
				/* Begin of Header */
					datatoxml.setData("head_mesg_send", head_mesg_send)
				&&	datatoxml.setData("head_mesg_recv", head_mesg_recv)
				&&	datatoxml.setData("head_func_code", head_func_code)
				&&	datatoxml.setData("head_mesg_type", head_mesg_type)
				&&	datatoxml.setData("head_mesg_name", head_mesg_name)
				&&	datatoxml.setData("head_mesg_vers", head_mesg_vers)
				&&	datatoxml.setData("head_docu_numb", head_docu_numb)
				&&	datatoxml.setData("head_mang_numb", head_mang_numb)
				&&	datatoxml.setData("head_refr_numb", head_refr_numb)
				&&	datatoxml.setData("head_titl_name", head_titl_name)
				&&  datatoxml.setData("head_orga_code", head_orga_code)
				/* End of Header */

				/* Begin of 문서정보 */
				&&  datatoxml.setData("docu_numb_text", docu_numb_text)
				&&  datatoxml.setData("docu_kind_code", docu_kind_code)
				&&  datatoxml.setData("docu_user_type", docu_user_type)
				/* End of 문서정보 */

				/* Begin of 주요계약정보 */
				&&  datatoxml.setData("cont_numb_text", cont_numb_text)
				&&  datatoxml.setData("cont_main_name", cont_main_name)
				/* End of 주요계약정보 */

				/* Begin of 계약자 정보 */
				&&  datatoxml.setData("appl_orga_name", appl_orga_name)
				&&  datatoxml.setData("appl_orps_divs", appl_orps_divs)
				&&  datatoxml.setData("appl_orps_iden", appl_orps_iden)
				&&  datatoxml.setData("appl_ownr_name", appl_ownr_name)
				/* End of 계약자 정보 */

				/* Begin of 채권자 정보 */
				&&  datatoxml.setData("cred_bond_hold", cred_bond_hold)
				/* End of 채권자 정보 */

				/* Begin of 응답 정보 */
				&&  datatoxml.setData("resp_type_code", resp_type_code)
				&&  datatoxml.setData("resp_type_name", resp_type_name)
				&&  datatoxml.setData("resp_mesg_text", resp_mesg_text)
				/* End of 응답 정보 */
			) {
				return datatoxml.getxmlData();
			} else {
				System.out.println(datatoxml.getErrorMsg());
				return null;
			}
		}
		catch(Exception _e){
			return null;
		}
	}

	/* 최종응답서(선급)*/
	public String composeXML10(String MASTER_CONT_NO_NEW
							 , String CONT_TITLE
							 , String AMT_INSU_NUM
							 , String VENDOR_NAME_LOC
							 , String CEO_NAME_LOC
							 , String SYSDATE
							 , String SYSTIME
							 , String IRS_NO_VENDOR		//공급사 사업자번호
							 , String RBONGU_STATUS
							 , String INSU_STATUS
							 )
	{
		/* 최종응답서(RBONGU) */
		/* HEADER */
		String	head_mesg_send =this.strSGICSenderCode;	/*	[필수]	 전문송신기관[송신자ID]	*/
		String	head_mesg_recv =this.strSGICCode;		/*	[필수]	 전문수신기관[수신자ID]	*/
		String	head_func_code =(RBONGU_STATUS=="RBONGU_AP")?this.strHeadFuncCode:"1";	/*	[필수]	 문서기능코드(계약취소시 strHeadFuncCode=1)로 처리함	*/
		String	head_mesg_type ="RBONGU";				/*	[필수]	 문서코드	*/
		String	head_mesg_name ="최종응답서";				/*	[필수]	 문서명	*/
		String	head_mesg_vers ="1.0";					/*	[선택]	 문서버전	*/
		String	head_docu_numb =AMT_INSU_NUM;			/*	[필수]	 문서번호	CONT_INSU_NUM = 004+상품구분코드(3)+실증권번호(18)+' '+차수 로 구성*/
		String	head_mang_numb =this.strSGICSenderCode + "." + SYSDATE + SYSTIME + ".12345." + AMT_INSU_NUM;	/*	[필수]	 문서관리번호	*/
		String	head_refr_numb =AMT_INSU_NUM;			/*	[필수]	 참조번호	*/
		String	head_titl_name ="최종응답서";				/*	[필수]	 문서개요	*/
		String  head_orga_code ="DMC";             		/*  [필수]   연계기관코드   */

		/* 문서정보 */
		String	docu_numb_text =AMT_INSU_NUM.substring(6, AMT_INSU_NUM.length());	/*	[필수]	 증권번호	*/
		String	docu_kind_code ="004";					/*	[필수]	 보험종목(상품)코드	*/
		String	docu_user_type ="DMC";					/*	[필수]	 발신처 Type	*/

		/* 주요계약정보 */
		String	cont_numb_text =MASTER_CONT_NO_NEW;		/*	[필수]	 계약번호	*/
		String	cont_main_name =CONT_TITLE;				/*	[필수]	 계약명	*/

		/* 계약자 정보 */
		String	appl_orga_name =VENDOR_NAME_LOC;		/*	[필수]	 기관명	*/
		String	appl_orps_divs ="O";					/*	[필수]	 구분(O:사업자번호 P:주민등록번호)	*/
		String	appl_orps_iden =IRS_NO_VENDOR;			/*	[필수]	 사업자/주민번호	*/
		String	appl_ownr_name =CEO_NAME_LOC;			/*	[필수]	 성명(대표자명)	*/

		/* 채권자 정보 */
		String	cred_bond_hold ="서준혁";					/*	[필수]	 채권자명	*/

		/* 응답 정보 */
		String	resp_type_code = "";
		String	resp_type_name = "";
		String	resp_mesg_text = "";
		//최종응답서 보낼때 진행상태 변경
		//거부일 경우 다시 SGI 에서 차수 변경해서 보증서가 전송되며, 최종응답서를 SGI에  재전송해야되므로 진행상태값이 그대로 계약서전송(31)상태로 있어야함)
		if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("SA") ){	//승인후 계약파기
			//status = "31";	//계약서전송
			resp_type_code = "DE";		//계약서 전송하면 계약완료로 봐야함
			resp_type_name = "파기";		/*	[필수]	 응답코드명	*/
			resp_mesg_text = "파기";		/*	[필수]	 응답내용		*/
		}else if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("TA")){ // 승인전 계약취소
			resp_type_code = "DD";		/*	[필수]	 응답 코드 (거부)		*/
			resp_type_name = "취소";		/*	[필수]	 응답코드명	*/
			resp_mesg_text = "취소";		/*	[필수]	 응답내용		*/
		}

		// 매핑 정보 파일, XML 탬플릿 정보 파일
		DataToXml datatoxml = new DataToXml(PropertiesManager.getString("sgic_templates_path"), "RBONGU");
		if(datatoxml.getErrorCode()!=0) {
			System.out.println(datatoxml.getErrorMsg());
			return null;
		}

		/* 최종응답서(RBONGU) */
		/* HEADER */
		try{
			if(
				/* Begin of Header */
					datatoxml.setData("head_mesg_send", head_mesg_send)
				&&	datatoxml.setData("head_mesg_recv", head_mesg_recv)
				&&	datatoxml.setData("head_func_code", head_func_code)
				&&	datatoxml.setData("head_mesg_type", head_mesg_type)
				&&	datatoxml.setData("head_mesg_name", head_mesg_name)
				&&	datatoxml.setData("head_mesg_vers", head_mesg_vers)
				&&	datatoxml.setData("head_docu_numb", head_docu_numb)
				&&	datatoxml.setData("head_mang_numb", head_mang_numb)
				&&	datatoxml.setData("head_refr_numb", head_refr_numb)
				&&	datatoxml.setData("head_titl_name", head_titl_name)
				&&  datatoxml.setData("head_orga_code", head_orga_code)
				/* End of Header */

				/* Begin of 문서정보 */
				&&  datatoxml.setData("docu_numb_text", docu_numb_text)
				&&  datatoxml.setData("docu_kind_code", docu_kind_code)
				&&  datatoxml.setData("docu_user_type", docu_user_type)
				/* End of 문서정보 */

				/* Begin of 주요계약정보 */
				&&  datatoxml.setData("cont_numb_text", cont_numb_text)
				&&  datatoxml.setData("cont_main_name", cont_main_name)
				/* End of 주요계약정보 */

				/* Begin of 계약자 정보 */
				&&  datatoxml.setData("appl_orga_name", appl_orga_name)
				&&  datatoxml.setData("appl_orps_divs", appl_orps_divs)
				&&  datatoxml.setData("appl_orps_iden", appl_orps_iden)
				&&  datatoxml.setData("appl_ownr_name", appl_ownr_name)
				/* End of 계약자 정보 */

				/* Begin of 채권자 정보 */
				&&  datatoxml.setData("cred_bond_hold", cred_bond_hold)
				/* End of 채권자 정보 */

				/* Begin of 응답 정보 */
				&&  datatoxml.setData("resp_type_code", resp_type_code)
				&&  datatoxml.setData("resp_type_name", resp_type_name)
				&&  datatoxml.setData("resp_mesg_text", resp_mesg_text)
				/* End of 응답 정보 */
			) {
				return datatoxml.getxmlData();
			} else {
				System.out.println(datatoxml.getErrorMsg());
				return null;
			}
		}
		catch(Exception _e){
			return null;
		}
	}

	/* 최종응답서(하자이행보증)*/
	public String composeXML11(String MASTER_CONT_NO_NEW
							 , String CONT_TITLE
							 , String AS_INSU_NUM
							 , String VENDOR_NAME_LOC
							 , String CEO_NAME_LOC
							 , String SYSDATE
							 , String SYSTIME
							 , String IRS_NO_VENDOR		//공급사 사업자번호
							 , String RBONGU_STATUS
							 , String INSU_STATUS
							 )
	{
		/* 최종응답서(RBONGU) */
		/* HEADER */
		String	head_mesg_send =this.strSGICSenderCode;	/*	[필수]	전문송신기관[송신자ID]	*/
		String	head_mesg_recv =this.strSGICCode;		/*	[필수]	전문수신기관[수신자ID]	*/
		String	head_func_code =(RBONGU_STATUS=="RBONGU_AP")?this.strHeadFuncCode:"1";	/*	[필수]	문서기능코드(계약취소시 strHeadFuncCode=1)로 처리함 */
		String	head_mesg_type ="RBONGU";				/*	[필수]	문서코드	*/
		String	head_mesg_name ="최종응답서";				/*	[필수]	문서명	*/
		String	head_mesg_vers ="1.0";					/*	[선택]	문서버전	*/
		String	head_docu_numb =AS_INSU_NUM;			/*	[필수]	문서번호	CONT_INSU_NUM = 004+상품구분코드(3)+실증권번호(18)+' '+차수 로 구성*/
		String	head_mang_numb =this.strSGICSenderCode + "." + SYSDATE + SYSTIME + ".12345." + AS_INSU_NUM;	/*	[필수]	 문서관리번호	*/
		String	head_refr_numb =AS_INSU_NUM;			/*	[필수]	참조번호	*/
		String	head_titl_name ="최종응답서";				/*	[필수]	문서개요	*/
		String  head_orga_code ="DMC";             		/*  [필수]   	연계기관코드   */

		/* 문서정보 */
		String	docu_numb_text =AS_INSU_NUM.substring(6, AS_INSU_NUM.length());	/*	[필수]	 증권번호	*/
		String	docu_kind_code ="003";					/*	[필수]	보험종목(상품)코드	*/
		String	docu_user_type ="DMC";					/*	[필수]	발신처 Type	*/

		/* 주요계약정보 */
		String	cont_numb_text =MASTER_CONT_NO_NEW;		/*	[필수]	계약번호	*/
		String	cont_main_name =CONT_TITLE;				/*	[필수]	계약명	*/

		/* 계약자 정보 */
		String	appl_orga_name =VENDOR_NAME_LOC;		/*	[필수]	기관명	*/
		String	appl_orps_divs ="O";					/*	[필수]	구분(O:사업자번호 P:주민등록번호)	*/
		String	appl_orps_iden =IRS_NO_VENDOR;			/*	[필수]	사업자/주민번호	*/
		String	appl_ownr_name =CEO_NAME_LOC;			/*	[필수]	성명(대표자명)	*/

		/* 채권자 정보 */
		String	cred_bond_hold ="서준혁";					/*	[필수]	채권자명	*/

		/* 응답 정보 */
		String	resp_type_code = "";
		String	resp_type_name = "";
		String	resp_mesg_text = "";

		//최종응답서 보낼때 진행상태 변경
		//거부일 경우 다시 SGI 에서 차수 변경해서 보증서가 전송되며, 최종응답서를 SGI에  재전송해야되므로 진행상태값이 그대로 계약서전송(31)상태로 있어야함)
		if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("SA") ){	//승인후 계약파기
			//status = "31";	//계약서전송
			resp_type_code = "DE";		//계약서 전송하면 계약완료로 봐야함
			resp_type_name = "파기";		/*	[필수]	 응답코드명	*/
			resp_mesg_text = "파기";		/*	[필수]	 응답내용		*/
		}else if(RBONGU_STATUS.equals("RBONGU_RE")&& INSU_STATUS.equals("TA")){ // 승인전 계약취소
			resp_type_code = "DD";		/*	[필수]	 응답 코드 (거부)		*/
			resp_type_name = "취소";		/*	[필수]	 응답코드명	*/
			resp_mesg_text = "취소";		/*	[필수]	 응답내용		*/
		}
		DataToXml datatoxml = new DataToXml(PropertiesManager.getString("sgic_templates_path"), "RBONGU");
		if(datatoxml.getErrorCode()!=0) {
			System.out.println(datatoxml.getErrorMsg());
			return null;
		}

		/* 최종응답서(RBONGU) */
		/* HEADER */
		try{
			if(
				/* Begin of Header */
					datatoxml.setData("head_mesg_send", head_mesg_send)
				&&	datatoxml.setData("head_mesg_recv", head_mesg_recv)
				&&	datatoxml.setData("head_func_code", head_func_code)
				&&	datatoxml.setData("head_mesg_type", head_mesg_type)
				&&	datatoxml.setData("head_mesg_name", head_mesg_name)
				&&	datatoxml.setData("head_mesg_vers", head_mesg_vers)
				&&	datatoxml.setData("head_docu_numb", head_docu_numb)
				&&	datatoxml.setData("head_mang_numb", head_mang_numb)
				&&	datatoxml.setData("head_refr_numb", head_refr_numb)
				&&	datatoxml.setData("head_titl_name", head_titl_name)
				&&  datatoxml.setData("head_orga_code", head_orga_code)
				/* End of Header */

				/* Begin of 문서정보 */
				&&  datatoxml.setData("docu_numb_text", docu_numb_text)
				&&  datatoxml.setData("docu_kind_code", docu_kind_code)
				&&  datatoxml.setData("docu_user_type", docu_user_type)
				/* End of 문서정보 */

				/* Begin of 주요계약정보 */
				&&  datatoxml.setData("cont_numb_text", cont_numb_text)
				&&  datatoxml.setData("cont_main_name", cont_main_name)
				/* End of 주요계약정보 */

				/* Begin of 계약자 정보 */
				&&  datatoxml.setData("appl_orga_name", appl_orga_name)
				&&  datatoxml.setData("appl_orps_divs", appl_orps_divs)
				&&  datatoxml.setData("appl_orps_iden", appl_orps_iden)
				&&  datatoxml.setData("appl_ownr_name", appl_ownr_name)
				/* End of 계약자 정보 */

				/* Begin of 채권자 정보 */
				&&  datatoxml.setData("cred_bond_hold", cred_bond_hold)
				/* End of 채권자 정보 */

				/* Begin of 응답 정보 */
				&&  datatoxml.setData("resp_type_code", resp_type_code)
				&&  datatoxml.setData("resp_type_name", resp_type_name)
				&&  datatoxml.setData("resp_mesg_text", resp_mesg_text)
				/* End of 응답 정보 */
			) {
				return datatoxml.getxmlData();
			} else {
				System.out.println(datatoxml.getErrorMsg());
				return null;
			}
		}
		catch(Exception _e){
			return null;
		}

	}


    public void doGet(EverHttpRequest req, EverHttpResponse res) throws ServletException, IOException {
    	System.err.println("===================get===="+ct0600Service);
        service(req, res) ;
    }

    public void doPost(EverHttpRequest req, EverHttpResponse res) throws ServletException, IOException {
    	System.err.println("===================post===="+ct0600Service);
        service(req, res) ;
    }
}
