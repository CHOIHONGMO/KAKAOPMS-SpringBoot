package com.st_ones.everf.kica_sp;

import com.st_ones.everf.serverside.config.PropertiesManager;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kica.sgic.util.DataToXml;
import kica.sgic.util.SGIxLinker;
import kica.sgic.util.XmlToData;
import signgate.sgic.xmlmanager.util.FileWriteUtil;

import java.io.IOException;
import java.io.UnsupportedEncodingException;

/**
 * 이행계약보증서(CONGUA) 테스트
 * @author hmchoi
 * 2022.10.07
 */
public class TestCONGUA extends HttpServlet {

    public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    	setProc() ;
    }

    public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    	setProc() ;
    }
	
	public void setProc() throws UnsupportedEncodingException {
		
		String docCode = "CONGUA"; // 이행계약보증서
		
		// 전송전문 템플릿 가져오기
		String templatePath = PropertiesManager.getString("sgic_templates_path");
		
		// 전송 템플릿에 기본값 세팅
		String xmlDoc = composeXML(templatePath, docCode);
		System.out.println( xmlDoc );
		
		System.out.println("================> 계약이행보증 Start");
		System.out.println("================> CONGUA SGIxLinker 송신 전");
		
		// 전문 전송
		SGIxLinker xLinker = new SGIxLinker(PropertiesManager.getString("sgic_sendinfo_conf"), "send_jsp", true);
		System.out.println("================> CONGUA SGIxLinker 송신 후");
		
		boolean isOK = xLinker.doSendProcess(xmlDoc, null);
		
		System.out.println("================> 이행계약보증서(CONGUA) 전송 isOK : " + isOK);
		if (!isOK) {
			System.out.println("================> 이행계약보증서(CONGUA) SGIxLinker 에러메시지:" + xLinker.getErrorMsg());
			return;
		}

		String recvXml = xLinker.getRecvXmlData();
		System.out.println("================> 이행계약보증서(CONGUA) 수신전문(recvXml) : " + recvXml);
		
		//if(xmlDoc!=null)
		//	parseXML(templatePath, docCode, xmlDoc);
	}
	
	// 이행계약보증서(CONGUA) 전송 전문에 기본값 세팅
	public static String composeXML(String templatePath, String docCode) throws UnsupportedEncodingException {
		
		/* HEADER */								
		String	head_mesg_send  = "A1018641759";		/*	[필수]	전문송신기관	*/
		String	head_mesg_recv  = "z120811300200";		/*	[필수]	전문수신기관	*/
		String	head_func_code  = "53";					/*	[필수]	문서기능	*/
		String	head_mesg_type  = "CONGUA";				/*	[필수]	문서코드	*/
		String	head_mesg_name  = "이행계약보증서";			/*	[필수]	문서명		*/
		String	head_mesg_vers  = "1.0";				/*	[선택]	전자문서버전	*/
		String	head_docu_numb  = "0043338 2";			/*	[필수]	문서번호	*/
		String	head_mang_numb  = "13.20060227151000.12345.0043338' '2";	/*	[필수]	 문서관리번호	*/
		String	head_refr_numb  = "0043338 2";			/*	[필수]	참조번호	*/
		String	head_titl_name  = "이행계약보증서";			/*	[필수]	문서개요	*/
		String  head_orga_code  = "ABC";            	/*  [필수]   	연계코드   	*/
		
		/* 보증기관 */
		String bond_orga_name ="Test 보증기관";				/*	[선택]	  보증기관명 */
		String bond_orga_iden ="T1";					/*	[선택]	  G2B등록코드*/
		String bond_orga_addn ="g2";					/*	[선택]	  조달청등록코드*/
		String bond_orga_ceo  ="김부자";					/*	[선택]	  대표자성명*/
		
		/* 공공기관 */
		String govn_orga_name ="Test 공공기관";				/*	[선택]	  공공기관명*/
		String govn_orga_iden ="g";						/*	[선택]	  G2B등록코드*/
		String govn_orga_addn ="e";						/*	[선택]	  조달청등록코드*/
		String govn_ownr_name ="김채권";					/*	[선택]	  대표자성명*/
		
		/* 작성일자 */
		String docu_issu_date ="";						/*	[선택]	  작성일자*/
		
		/* 업무구분 */
		String busi_clas_code ="2";						/*	[선택]	  업무구분코드*/
		String busi_clas_name ="업무내용";					/*	[선택]	  업무구분내용*/
		
		/* 보증서(증권) */
		String bond_numb_text ="012345678901234567890123456789";	/*	[선택]	  보증서(증권)번호*/
		
		/* 보증내용 */
		String bond_penl_text ="10000";					/*	[선택]	  보증금액(한글)*/     
		String bond_penl_amnt ="20000";					/*	[선택]	  보증금액(숫자)*/     
		String penl_curc_code ="WON";					/*	[선택]	  보증금액/통화코드*/      
		String bond_begn_date ="20060509";				/*	[선택]	  보증시작일 */     
		String bond_fnsh_date ="20070509";				/*	[선택]	  보증만료일*/      
		String bond_prem_amnt ="1000";					/*	[선택]	  보험료*/     
		String prem_curc_code ="WON";					/*	[선택]	  보험료/통화코드*/      
		String bond_pric_rate ="30";					/*	[선택]	  보증금율	*/
		String appl_orga_name ="김부자";					/*	[선택]	  계약자/상호*/     
		String appl_orps_divs ="1";						/*	[선택]	  계약자/사업자/주민등록번호구분 */
		String appl_orps_iden ="1234567891234";			/*	[선택]	  계약자/사업자/주민등록번호 */     
		String appl_ownr_name ="김채권";					/*	[선택]	  계약자/대표자성명 */     
		String cred_orga_name ="테스트주식회사";				/*	[선택]	  채권자/기관명	*/      
		String cred_orps_divs ="1";						/*	[선택]	  채권자/사업자/주민등록번호구분 */
		String cred_orps_iden ="1234567891234";			/*	[선택]	  채권자/사업자/주민등록번호 */     
		String bond_hold_name ="홍길동";					/*	[선택]	  채권자/채권자명 */  
		
		/* 보증계약(주) */
		String cont_name_text ="테스트계약건명";				/*	[선택]	  계약건명	*/
		String cont_main_amnt ="1000";					/*	[선택]	  계약금액	*/
		String cont_curc_code ="WON";					/*	[선택]	  계약금액/통화코드	*/
		String cont_numb_text ="CT11081800100";					/*	[선택]	  계약번호	*/
		String cont_main_date ="20060509";				/*	[선택]	  계약일자 */
		String cont_begn_date ="20060509";				/*	[선택]	  계약기간/계약시작일   */  
		String cont_fnsh_date ="20070509";				/*	[선택]	  계약기간/계약만료일   */ 
		
		/* 특기사항 */
		String spcl_cond_text ="";						/*	[선택]	  특기사항*/
		
		/* 특별약관 */
		String spcl_prov_text ="";						/*	[선택]	  특별약관*/
		
		/* 보증문 */
		String bond_stat_text ="";						/*	[선택]	  보증문*/
		
		/* 발행자 */
		String issu_addr_txt1 ="서울시 중국 중림동";			/*	[선택]	  주소1*/
		String issu_addr_txt2 ="449-23";				/*	[선택]	  주소2*/
		String issu_orga_name ="테스트상호";				/*	[선택]	  상호*/
		String issu_ownr_name ="김발행";					/*	[선택]	  대표자성명*/
		String issu_dept_name ="테스트대리점";				/*	[선택]	  대리인/부서(대리점*/
		String issu_dept_ownr ="김대리";					/*	[선택]	  대리인/성명 */
		String chrg_name_text ="김담당";					/*	[선택]	  담당자/성명*/
		String chrg_phon_text ="02-222-2222";			/*	[선택]	  담당자/전화 */
		String chrg_faxs_text ="02-222-2224";			/*	[선택]	  담당자/Fax 번호 */
		
		/* 비고 */
		String gene_note_text =""; 						/* 비고   */

		String str1 = "";
		String str2 = "";
		
		// 매핑 정보 파일, XML 탬플릿 정보 파일
		System.out.println("templatePath-------------------------------------" + templatePath);		
		System.out.println("docCode-------------------------------------" + docCode);		
		DataToXml dataToXml = new DataToXml(templatePath, docCode);
		if(dataToXml.getErrorCode() != 0) {
			System.out.println(dataToXml.getErrorMsg());
			return null;
		}

		/* 계약정보통보서(CONINF) */								
		/* HEADER */								
		String xmlDoc = null;
		try{
			if(		
				/* Begin of Header */
					dataToXml.setData("head_mesg_send", head_mesg_send)
				&&	dataToXml.setData("head_mesg_recv", head_mesg_recv) 
				&&	dataToXml.setData("head_func_code", head_func_code) 
				&&	dataToXml.setData("head_mesg_type", head_mesg_type) 
				&&	dataToXml.setData("head_mesg_name", head_mesg_name) 
				&&	dataToXml.setData("head_mesg_vers", head_mesg_vers) 
				&&	dataToXml.setData("head_docu_numb", head_docu_numb) 
				&&	dataToXml.setData("head_mang_numb", head_mang_numb) 
				&&	dataToXml.setData("head_refr_numb", head_refr_numb) 
				&&	dataToXml.setData("head_titl_name", head_titl_name) 
				/* End of Header */				
				/* Begin of 보증기관 */
				&&  dataToXml.setData("bond_orga_name", bond_orga_name)
				&&  dataToXml.setData("bond_orga_iden", bond_orga_iden)
				&&  dataToXml.setData("bond_orga_addn", bond_orga_addn)
				&&  dataToXml.setData("bond_orga_ceo", bond_orga_ceo)
				/* End of 보증기관 */				
				/* Begin of 공공기관 */
				&&  dataToXml.setData("govn_orga_name", govn_orga_name)
				&&  dataToXml.setData("govn_orga_iden", govn_orga_iden)
				&&  dataToXml.setData("govn_orga_addn", govn_orga_addn)
				&&  dataToXml.setData("govn_ownr_name", govn_ownr_name)
				/* End of 공공기관 */
				/* Begin of 작성일자 */
				//&&  dataToXml.setData("docu_issu_date", docu_issu_date)
				/* End of 작성일자 */		
				/* Begin of 업무구분 */
				&&  dataToXml.setData("busi_clas_code", busi_clas_code)
				&&  dataToXml.setData("busi_clas_name", busi_clas_name)
				/* End of 업무구분 */
				/* Begin of 보증서(증권) */
				&&  dataToXml.setData("bond_numb_text", bond_numb_text)
				/* End of 보증서(증권) */				
				/* Begin of 보증내용 */
				&&  dataToXml.setData("bond_penl_text", bond_penl_text)
				&&  dataToXml.setData("bond_penl_amnt", bond_penl_amnt)
				&&  dataToXml.setData("penl_curc_code", penl_curc_code)
				&&  dataToXml.setData("bond_begn_date", bond_begn_date)
				&&  dataToXml.setData("bond_fnsh_date", bond_fnsh_date)
				&&  dataToXml.setData("bond_prem_amnt", bond_prem_amnt)
				&&  dataToXml.setData("prem_curc_code", prem_curc_code)
				&&  dataToXml.setData("bond_pric_rate", bond_pric_rate)
				&&  dataToXml.setData("appl_orga_name", appl_orga_name)
				&&  dataToXml.setData("appl_orps_divs", appl_orps_divs)
				&&  dataToXml.setData("appl_orps_iden", appl_orps_iden)
				&&  dataToXml.setData("appl_ownr_name", appl_ownr_name)
				&&  dataToXml.setData("cred_orga_name", cred_orga_name)
				&&  dataToXml.setData("cred_orps_divs", cred_orps_divs)
				&&  dataToXml.setData("cred_orps_iden", cred_orps_iden)
				&&  dataToXml.setData("bond_hold_name", bond_hold_name)
				/* End of 보증내용 */				
				/* Begin of 보증계약(주) */
				&&  dataToXml.setData("cont_name_text", cont_name_text)
				&&  dataToXml.setData("cont_main_amnt", cont_main_amnt)
				&&  dataToXml.setData("cont_curc_code", cont_curc_code)
				&&  dataToXml.setData("cont_numb_text", cont_numb_text)
				&&  dataToXml.setData("cont_main_date", cont_main_date)
				&&  dataToXml.setData("cont_begn_date", cont_begn_date)
				&&  dataToXml.setData("cont_fnsh_date", cont_fnsh_date)
				/* End of 보증계약(주) */
				/* Begin of 특기사항 */
				//&&  dataToXml.setData("spcl_cond_text", spcl_cond_text)
				/* End of 특기사항 */
				/* Begin of 특별약관 */
				//&&  dataToXml.setData("spcl_prov_text", spcl_prov_text)
				/* End of 특별약관 */
				/* Begin of 보증문 */
				//&&  dataToXml.setData("bond_stat_text", bond_stat_text)
				/* End of 보증문 */               
				/* Begin of 발행자 */
				&&  dataToXml.setData("issu_addr_txt1", issu_addr_txt1)
				&&  dataToXml.setData("issu_addr_txt2", issu_addr_txt2)
				&&  dataToXml.setData("issu_orga_name", issu_orga_name)
				&&  dataToXml.setData("issu_ownr_name", issu_ownr_name)
				&&  dataToXml.setData("issu_dept_name", issu_dept_name)
				&&  dataToXml.setData("issu_dept_ownr", issu_dept_ownr)
				&&  dataToXml.setData("chrg_name_text", chrg_name_text)
				&&  dataToXml.setData("chrg_phon_text", chrg_phon_text)
				&&  dataToXml.setData("chrg_faxs_text", chrg_faxs_text)
				/* End of 발행자 */
				/* Begin of 비고 */
				//&&  dataToXml.setData("gene_note_text", gene_note_text)
				/* End of 비고 */
				)
			{
				xmlDoc = dataToXml.getxmlData();	
				str2 = xmlDoc;
				
				// 계약이행보증 전송전문 생성위치
				FileWriteUtil.genFileCreate( "D:/app/mro/servlet_src/kica_sp/sampleCONGUA.xml", xmlDoc);

				//str1 = new String(xmlDoc.toString().getBytes(), "UTF-8"); //-- UTF-8 로 Decoding
				//System.out.println(str1); 
				//str2 = new String(str1.getBytes("EUC-KR"), "EUC-KR"); 	//-- UTF-8 --> EUC-KR 로 Encoding 				
			} else {
				System.out.println(dataToXml.getErrorMsg());
			}
		} catch(Exception _e) {
			System.out.println(_e.toString());
		}
		
		return str2;
	}
	
	public static void parseXML(String templatePath, String docCode, String xmlDoc) {
		
		try{
			XmlToData xmlToData = new XmlToData(templatePath, docCode, xmlDoc);
			if(xmlToData.getErrorCode() != 0) {
				System.out.println(xmlToData.getErrorMsg());
				return;
			}
			
			/* Begin of Header */
			String head_mesg_send = xmlToData.getData("head_mesg_send");
			String head_mesg_recv = xmlToData.getData("head_mesg_recv"); 
			String head_func_code = xmlToData.getData("head_func_code"); 
			String head_mesg_type = xmlToData.getData("head_mesg_type"); 
			String head_mesg_name = xmlToData.getData("head_mesg_name"); 
			String head_mesg_vers = xmlToData.getData("head_mesg_vers"); 
			String head_docu_numb = xmlToData.getData("head_docu_numb"); 
			String head_mang_numb = xmlToData.getData("head_mang_numb"); 
			String head_refr_numb = xmlToData.getData("head_refr_numb"); 
			String head_titl_name = xmlToData.getData("head_titl_name"); 
			/* End of Header */				
			/* Begin of ??????? */           
			String bond_orga_name = xmlToData.getData("bond_orga_name");
			String bond_orga_iden = xmlToData.getData("bond_orga_iden");
			String bond_orga_addn = xmlToData.getData("bond_orga_addn");
			String bond_orga_ceo  = xmlToData.getData("bond_orga_ceo" );
			/* End of ??????? */				
			/* Begin of ????? */            
			String govn_orga_name = xmlToData.getData("govn_orga_name");
			String govn_orga_iden = xmlToData.getData("govn_orga_iden");
			String govn_orga_addn = xmlToData.getData("govn_orga_addn");
			String govn_ownr_name = xmlToData.getData("govn_ownr_name");
			/* End of ????? */     
			/* Begin of ??????? */   
			String docu_issu_date = xmlToData.getData("docu_issu_date");
			/* End of ??????? */		   
			/* Begin of ???????? */          
			String busi_clas_code = xmlToData.getData("busi_clas_code");
			String busi_clas_name = xmlToData.getData("busi_clas_name");
			/* End of ???????? */             
			/* Begin of ??????(????) */       
			String bond_numb_text = xmlToData.getData("bond_numb_text");
			/* End of ??????(????) */	
			/* Begin of ???????? */       
			String bond_penl_text = xmlToData.getData("bond_penl_text");
			String bond_penl_amnt = xmlToData.getData("bond_penl_amnt");
			String penl_curc_code = xmlToData.getData("penl_curc_code");
			String bond_begn_date = xmlToData.getData("bond_begn_date");
			String bond_fnsh_date = xmlToData.getData("bond_fnsh_date");
			String bond_prem_amnt = xmlToData.getData("bond_prem_amnt");
			String prem_curc_code = xmlToData.getData("prem_curc_code");
			String bond_pric_rate = xmlToData.getData("bond_pric_rate");
			String appl_orga_name = xmlToData.getData("appl_orga_name");
			String appl_orps_divs = xmlToData.getData("appl_orps_divs");
			String appl_orps_iden = xmlToData.getData("appl_orps_iden");
			String appl_ownr_name = xmlToData.getData("appl_ownr_name");
			String cred_orga_name = xmlToData.getData("cred_orga_name");
			String cred_orps_divs = xmlToData.getData("cred_orps_divs");
			String cred_orps_iden = xmlToData.getData("cred_orps_iden");
			String bond_hold_name = xmlToData.getData("bond_hold_name");
			/* End of ???????? */				
			/* Begin of ???????(??) */        
			String cont_name_text = xmlToData.getData("cont_name_text");
			String cont_main_amnt = xmlToData.getData("cont_main_amnt");
			String cont_curc_code = xmlToData.getData("cont_curc_code");
			String cont_numb_text = xmlToData.getData("cont_numb_text");
			String cont_main_date = xmlToData.getData("cont_main_date");
			String cont_begn_date = xmlToData.getData("cont_begn_date");
			String cont_fnsh_date = xmlToData.getData("cont_fnsh_date");
			/* End of ???????(??) */         
			/* Begin of ?????? */           
			String spcl_cond_text = xmlToData.getData("spcl_cond_text");
			/* End of ?????? */              
			/* Begin of ?????? */            
			String spcl_prov_text = xmlToData.getData("spcl_prov_text");
			/* End of ?????? */   
			/* Begin of ?????? */   
			String bond_stat_text = xmlToData.getData("bond_stat_text");
			/* End of ?????? */    
			/* Begin of ?????? */  
			String issu_addr_txt1 = xmlToData.getData("issu_addr_txt1");
			String issu_addr_txt2 = xmlToData.getData("issu_addr_txt2");
			String issu_orga_name = xmlToData.getData("issu_orga_name");
			String issu_ownr_name = xmlToData.getData("issu_ownr_name");
			String issu_dept_name = xmlToData.getData("issu_dept_name");
			String issu_dept_ownr = xmlToData.getData("issu_dept_ownr");
			String chrg_name_text = xmlToData.getData("chrg_name_text");
			String chrg_phon_text = xmlToData.getData("chrg_phon_text");
			String chrg_faxs_text = xmlToData.getData("chrg_faxs_text");
			/* End of ?????? */    
			/* Begin of ??? */    
			String gene_note_text = xmlToData.getData("gene_note_text");
			/* End of ??? */				
			
			System.out.println("head_mesg_send=" + head_mesg_send);
			System.out.println("head_mesg_recv=" + head_mesg_recv); 
			System.out.println("head_func_code=" + head_func_code); 
			System.out.println("head_mesg_type=" + head_mesg_type); 
			System.out.println("head_mesg_name=" + head_mesg_name); 
			System.out.println("head_mesg_vers=" + head_mesg_vers); 
			System.out.println("head_docu_numb=" + head_docu_numb); 
			System.out.println("head_mang_numb=" + head_mang_numb); 
			System.out.println("head_refr_numb=" + head_refr_numb); 
			System.out.println("head_titl_name=" + head_titl_name);    
			System.out.println("bond_orga_name=" + bond_orga_name);
			System.out.println("bond_orga_iden=" + bond_orga_iden);
			System.out.println("bond_orga_addn=" + bond_orga_addn);
			System.out.println("bond_orga_ceo=" + bond_orga_ceo );
			System.out.println("govn_orga_name=" + govn_orga_name);
			System.out.println("govn_orga_iden=" + govn_orga_iden);
			System.out.println("govn_orga_addn=" + govn_orga_addn);
			System.out.println("govn_ownr_name=" + govn_ownr_name);
			System.out.println("docu_issu_date=" + docu_issu_date);
			System.out.println("busi_clas_code=" + busi_clas_code);
			System.out.println("busi_clas_name=" + busi_clas_name);
			System.out.println("bond_numb_text=" + bond_numb_text);
			System.out.println("bond_penl_text=" + bond_penl_text);
			System.out.println("bond_penl_amnt=" + bond_penl_amnt);
			System.out.println("penl_curc_code=" + penl_curc_code);
			System.out.println("bond_begn_date=" + bond_begn_date);
			System.out.println("bond_fnsh_date=" + bond_fnsh_date);
			System.out.println("bond_prem_amnt=" + bond_prem_amnt);
			System.out.println("prem_curc_code=" + prem_curc_code);
			System.out.println("bond_pric_rate=" + bond_pric_rate);
			System.out.println("appl_orga_name=" + appl_orga_name);
			System.out.println("appl_orps_divs=" + appl_orps_divs);
			System.out.println("appl_orps_iden=" + appl_orps_iden);
			System.out.println("appl_ownr_name=" + appl_ownr_name);
			System.out.println("cred_orga_name=" + cred_orga_name);
			System.out.println("cred_orps_divs=" + cred_orps_divs);
			System.out.println("cred_orps_iden=" + cred_orps_iden);
			System.out.println("bond_hold_name=" + bond_hold_name);
			System.out.println("cont_name_text=" + cont_name_text);
			System.out.println("cont_main_amnt=" + cont_main_amnt);
			System.out.println("cont_curc_code=" + cont_curc_code);
			System.out.println("cont_numb_text=" + cont_numb_text);
			System.out.println("cont_main_date=" + cont_main_date);
			System.out.println("cont_begn_date=" + cont_begn_date);
			System.out.println("cont_fnsh_date=" + cont_fnsh_date);
			System.out.println("spcl_cond_text=" + spcl_cond_text);
			System.out.println("spcl_prov_text=" + spcl_prov_text);
			System.out.println("bond_stat_text=" + bond_stat_text);
			System.out.println("issu_addr_txt1=" + issu_addr_txt1);
			System.out.println("issu_addr_txt2=" + issu_addr_txt2);
			System.out.println("issu_orga_name=" + issu_orga_name);
			System.out.println("issu_ownr_name=" + issu_ownr_name);
			System.out.println("issu_dept_name=" + issu_dept_name);
			System.out.println("issu_dept_ownr=" + issu_dept_ownr);
			System.out.println("chrg_name_text=" + chrg_name_text);
			System.out.println("chrg_phon_text=" + chrg_phon_text);
			System.out.println("chrg_faxs_text=" + chrg_faxs_text);
			System.out.println("gene_note_text=" + gene_note_text);			
		}
		catch(Exception _e) {
			System.out.println(_e.toString());
		}		
	}
}
