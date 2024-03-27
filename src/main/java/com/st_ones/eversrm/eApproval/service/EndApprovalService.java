package com.st_ones.eversrm.eApproval.service;

import com.st_ones.common.message.service.MessageService;
import com.st_ones.everf.serverside.exception.ApprovalException;
import com.st_ones.evermp.BOD1.service.BOD103_Service;
import com.st_ones.evermp.BS01.service.BS0101_Service;
import com.st_ones.evermp.BS03.service.BS0301_Service;
import com.st_ones.evermp.IM01.service.IM0101_Service;
import com.st_ones.evermp.IM03.service.IM0301_Service;
import com.st_ones.evermp.OD01.service.OD0101_Service;
import com.st_ones.evermp.OD01.service.PO0310_Service;
import com.st_ones.evermp.RQ01.service.RQ0102_Service;
import com.st_ones.evermp.buyer.cn.service.CN0100Service;
import com.st_ones.evermp.buyer.cont.service.CT0300Service;
import com.st_ones.evermp.buyer.rq.service.RQ0300Service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;


/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2014 ST-Ones CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : EndApprovalService.java
 * @author  St-Ones(st-ones@st-ones.com)
 * @date 2018. 2. 06.
 * @version 1.0
 * @see
 */
@Service(value = "endApprovalService")
public class EndApprovalService {

	private enum DOC_TYPE{ VENDOR, VENBLOCK, CPO, PO, EXEC, INFOCH, CUST, RFQ, INFOCHUP ,INFONEWUP ,POCH,EXEP ,DOCH, EC,CC}

    @Autowired private MessageService msg;

	@Autowired private BS0301_Service bs0301_service;		// 협력업체등록
	@Autowired private RQ0102_Service rq0102_Service;		// 업체선정 품의
	@Autowired private BOD103_Service bod103_Service;		// 고객사주문요청
	@Autowired private OD0101_Service od0101_service;		// 운영사주문변경(대행)
	@Autowired private IM0301_Service im0301Service;		// (품목)계약단가등록/변경
	@Autowired private BS0101_Service bs0101Service;
	@Autowired private RQ0300Service  rQ0300Service;		//견적의뢰작성
	@Autowired private IM0101_Service im0101Service;		//견적의뢰작성
	@Autowired private CN0100Service  cn0100Service;		//품의작성
	@Autowired private OD0101_Service od0101Service;		//견적의뢰작성
	@Autowired private PO0310_Service po0310Service;		//출하
	@Autowired private CT0300Service  ct0300Service;	    //계약작성



	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doAfterApprove(String docTypeString, String appDocNum, String appDocCnt) throws Exception {

		DOC_TYPE docType = DOC_TYPE.valueOf(docTypeString);
		String message = null;

		/* @formatter:off */
		switch (docType) {
			// 공급사 등록
			case VENDOR    : message = bs0301_service.endApproval(appDocNum, appDocCnt, "E"); break;
			// 공급사 BLOCK 해제
			case VENBLOCK  : message = bs0301_service.vendorBlockendApproval(appDocNum, appDocCnt, "E"); break;
			// 공급사 선정품의
			case EXEC      : message = rq0102_Service.endApproval(appDocNum, appDocCnt, "E"); break;
			// 품목 등록 및 단가변경
			case INFOCH    : message = im0301Service.endApproval(appDocNum, appDocCnt, "E"); break;

			case INFOCHUP  : message = im0301Service.endApproval(appDocNum, appDocCnt, "E"); break;

			case INFONEWUP : message = im0101Service.endApproval(appDocNum, appDocCnt, "E"); break;
			// 고객사 주문하기
			case CPO       : message = bod103_Service.endApproval(appDocNum, appDocCnt, "E"); break;
			// 운영사 주문변경(대행)
			case PO        : message = od0101_service.endApproval(appDocNum, appDocCnt, "E"); break;
			// 고객사 등록
			case CUST      : message = bs0101Service.endApproval(appDocNum, appDocCnt, "E"); break;
			// 견적 등록
			case RFQ       : message = rQ0300Service.endApproval(appDocNum, appDocCnt, "E"); break;
			// 품의 등록
			case EXEP      : message = cn0100Service.endApproval(appDocNum, appDocCnt, "E"); break;

			case POCH      : message = od0101Service.endApprovalPoCh(appDocNum, appDocCnt, "E"); break;

			case DOCH      : message = po0310Service.endApprovalDoCh(appDocNum, appDocCnt, "E"); break;
			//계약 결재
			case EC        : message = ct0300Service.endApproval(appDocNum, appDocCnt, "E"); break;
			//계약철회
			case CC        : message = ct0300Service.ECOA0020_doCancelRemoveCont2(appDocNum, appDocCnt, "E"); break;


			default        :
				throw new ApprovalException(msg.getMessageForService(this, "no_matched_doc"));
		}
		/* @formatter:on */
		// 결재 승인 이후 메일 발송
		// ===> 각 업무의 endApproval에서 처리하도록 함

		return message;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doAfterReject(String docTypeString, String appDocNum, String appDocCnt) throws Exception {

		DOC_TYPE docType = DOC_TYPE.valueOf(docTypeString);
		String message = null;

		/* @formatter:off */
		switch (docType) {
			// 공급사등록
			case VENDOR    : message = bs0301_service.endApproval(appDocNum, appDocCnt, "R"); break;
			// 공급사block해제
			case VENBLOCK  : message = bs0301_service.vendorBlockendApproval(appDocNum, appDocCnt, "R"); break;
			// 업체선정 품의
			case EXEC      : message = rq0102_Service.endApproval(appDocNum, appDocCnt, "R"); break;
			// 품목등록_단가변경
			case INFOCH    : message = im0301Service.endApproval(appDocNum, appDocCnt, "R"); break;
			case INFOCHUP  : message = im0301Service.endApproval(appDocNum, appDocCnt, "R"); break;
			case INFONEWUP : message = im0101Service.endApproval(appDocNum, appDocCnt, "R"); break;
			// 고객사 주문하기
			case CPO       : message = bod103_Service.rejectApproval(appDocNum, appDocCnt, "R"); break;
			// 운영사 주문변경 (대행)
			case PO        : message = od0101_service.endApproval(appDocNum, appDocCnt, "R"); break;
			// 고객사 등록
			case CUST      : message = bs0101Service.endApproval(appDocNum, appDocCnt, "R"); break;
			// 견적 등록
			case RFQ       : message = rQ0300Service.endApproval(appDocNum, appDocCnt, "R"); break;
			// 품의 등록
			case EXEP      : message = cn0100Service.endApproval(appDocNum, appDocCnt, "R"); break;

			case POCH      : message = od0101Service.endApprovalPoCh(appDocNum, appDocCnt, "R"); break;

			case DOCH      : message = po0310Service.endApprovalDoCh(appDocNum, appDocCnt, "R"); break;
            //계약신청
			case EC        : message = ct0300Service.endApproval(appDocNum, appDocCnt, "R"); break;
			//계약철회
			case CC        : message = ct0300Service.ECOA0020_doCancelRemoveCont2(appDocNum, appDocCnt, "R"); break;

			default        :
				throw new ApprovalException(msg.getMessageForService(this, "no_matched_doc"));
		}
		/* @formatter:on */
		// 결재 반려 이후 메일 발송
		// ===> 각 업무의 endApproval에서 처리하도록 함

		return message;
	}

	@Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
	public String doAfterCancel(String docTypeString, String appDocNum, String appDocCnt) throws Exception {

		DOC_TYPE docType = DOC_TYPE.valueOf(docTypeString);
		String message = null;

		/* @formatter:off */
		switch (docType) {
			// 공급사등록
			case VENDOR    : message = bs0301_service.endApproval(appDocNum, appDocCnt, "C"); break;
			// 공급사block해제
			case VENBLOCK  : message = bs0301_service.vendorBlockendApproval(appDocNum, appDocCnt, "C"); break;
			// 업체선정 품의
			case EXEC      : message = rq0102_Service.endApproval(appDocNum, appDocCnt, "C"); break;
			// 품목등록_단가변경
			case INFOCH    : message = im0301Service.endApproval(appDocNum, appDocCnt, "C"); break;
			case INFOCHUP  : message = im0301Service.endApproval(appDocNum, appDocCnt, "C"); break;
			case INFONEWUP : message = im0101Service.endApproval(appDocNum, appDocCnt, "C"); break;
			// 주문
			case CPO       : message = bod103_Service.cancelApproval(appDocNum, appDocCnt, "C"); break;
			// 운영사 주문변경 (대행)
			case PO        : message = od0101_service.endApproval(appDocNum, appDocCnt, "C"); break;
			// 고객사 등록
			case CUST      : message = bs0101Service.endApproval(appDocNum, appDocCnt, "C"); break;
			// 견적 등록
			case RFQ       : message = rQ0300Service.endApproval(appDocNum, appDocCnt, "C"); break;
			// 품의 등록
			case EXEP      : message = cn0100Service.endApproval(appDocNum, appDocCnt, "C"); break;

			case POCH      : message = od0101Service.endApprovalPoCh(appDocNum, appDocCnt, "C"); break;

			case DOCH      : message = po0310Service.endApprovalDoCh(appDocNum, appDocCnt, "C"); break;
			//계약신청
			case EC        : message = ct0300Service.endApproval(appDocNum, appDocCnt, "C"); break;
			//계약철회
			case CC        : message = ct0300Service.ECOA0020_doCancelRemoveCont2(appDocNum, appDocCnt, "C"); break;

			default        :
				throw new ApprovalException(msg.getMessageForService(this, "no_matched_doc"));
		}
		/* @formatter:on */

		return message;
	}

}
