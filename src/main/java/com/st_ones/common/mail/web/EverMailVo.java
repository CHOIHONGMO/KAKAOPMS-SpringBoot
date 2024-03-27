package com.st_ones.common.mail.web;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : EverMailVo.java
 * @author  Yeon-moo, Lee (yeonmoo_lee@st-ones.com)
 * @date 2013. 09. 10.
 * @version 1.0
 * @see
 */

public class EverMailVo {

	@Override
	public String toString() {
		return "EverMailVo [subject=" + subject + ", contents=" + contents + ", senderNm=" + senderNm + ", senderEmail=" + senderEmail + ", senderUserId=" + senderUserId + ", refNum=" + refNum + ", refModuleCd=" + refModuleCd + ", receiverNm=" + receiverNm + ", receiverEmail="
			+ receiverEmail + ", receiverUserId=" + receiverUserId + ", vendorCd=" + vendorCd + ", attachFileNum=" + attFileNum + ", buyerCd=" + buyerCd + ", smtpServer=" + smtpServer + ", smtpPort=" + smtpPort + ", smtpUser=" + smtpUser + ", smtpPw=" + smtpPw + ", smtpEncoding="
			+ smtpEncoding + ", smtpAuthFlag=" + smtpAuthFlag + ", mailSendFlag=" + mailSendFlag + ", mailTextNum=" + mailTextNum + ", gateCd=" + gateCd + ", interfaceType=" + interfaceType + ", cc=" + cc + ", transactionalStatus=" + transactionalStatus + ", execNum= " + execNum + "]";
	}

	private String subject;
	private String contents;
	private String contentsTemplate;
	private String senderNm;
	private String senderEmail;
	private String senderUserId;
	private String refNum;
	private String execNum;
	private String refModuleCd;
	private String receiverNm;
	private String receiverEmail;
	private String receiverUserId;
	private String vendorCd;
	private String attFileNum;
	private String buyerCd;
	private String smtpServer;
	private String smtpPort;
	private String smtpUser;
	private String smtpPw;
	private String smtpEncoding;
	private String smtpAuthFlag;
	private String mailSendFlag;
	private String mailTextNum;
	private String gateCd;
	private String interfaceType;
	private String cc;

	private String transactionalStatus;

	public String getInterfaceType() {
		return interfaceType;
	}

	public void setInterfaceType(String _interfaceType) {
		this.interfaceType = _interfaceType;
	}

	public String getGateCd() {
		return gateCd;
	}

	public void setGateCd(String _gateCd) {
		this.gateCd = _gateCd;
	}

	public String getMailTextNum() {
		return mailTextNum;
	}

	public void setMailTextNum(String _mailTextNum) {
		this.mailTextNum = _mailTextNum;
	}

	public String getMailSendFlag() {
		return mailSendFlag;
	}

	public void setMailSendFlag(String _mailSendFlag) {
		this.mailSendFlag = _mailSendFlag;
	}

	public String getSubject() {
		return subject;
	}

	public void setSubject(String _subject) {
		this.subject = _subject;
	}

	public String getContents() {
		return contents;
	}

	public void setContents(String _contents) {
		this.contents = _contents;
	}


	public String getContentsTemplate() {
		return contentsTemplate;
	}

	public void setContentsTemplate(String _contentsTemplate) {
		this.contentsTemplate = _contentsTemplate;
	}

	public String getSenderNm() {
		return senderNm;
	}

	public void setSenderNm(String sendNm) {
		this.senderNm = sendNm;
	}

	public String getSenderEmail() {
		return senderEmail;
	}

	public void setSenderEmail(String sendEmail) {
		this.senderEmail = sendEmail;
	}

	public String getSenderUserId() {
		return senderUserId;
	}

	public void setSenderUserId(String sendUserId) {
		this.senderUserId = sendUserId;
	}

	public String getRefNum() {
		return refNum;
	}

	public void setRefNum(String _refNum) {
		this.refNum = _refNum;
	}

	public String getExecNum() {
		return execNum;
	}

	public void setExecNum(String _execNum) { this.execNum = _execNum; }

	public String getRefModuleCd() {
		return refModuleCd;
	}

	public void setRefModuleCd(String _refModuleCd) {
		this.refModuleCd = _refModuleCd;
	}

	public String getReceiverNm() {
		return receiverNm;
	}

	public void setReceiverNm(String recvNm) {
		this.receiverNm = recvNm;
	}

	public String getReceiverEmail() {
		return receiverEmail;
	}

	public void setReceiverEmail(String recvEmail) {
		this.receiverEmail = recvEmail;
	}

	public String getReceiverUserId() {
		return receiverUserId;
	}

	public void setReceiverUserId(String recvUserId) {
		this.receiverUserId = recvUserId;
	}

	public String getVendorCd() {
		return vendorCd;
	}

	public void setVendorCd(String _vendorCd) {
		this.vendorCd = _vendorCd;
	}

	public String getAttFileNum() {
		return attFileNum;
	}

	public void setAttFileNum(String _attFileNum) {
		this.attFileNum = _attFileNum;
	}

	public String getBuyerCd() {
		return buyerCd;
	}

	public void setBuyerCd(String _buyerCd) {
		this.buyerCd = _buyerCd;
	}

	public String getSmtpServer() {
		return smtpServer;
	}

	public void setSmtpServer(String _smtpServer) {
		this.smtpServer = _smtpServer;
	}

	public String getSmtpPort() {
		return smtpPort;
	}

	public void setSmtpPort(String _smtpPort) {
		this.smtpPort = _smtpPort;
	}

	public String getSmtpUser() {
		return smtpUser;
	}

	public void setSmtpUser(String _smtpUser) {
		this.smtpUser = _smtpUser;
	}

	public String getSmtpPw() {
		return smtpPw;
	}

	public void setSmtpPw(String _smtpPw) {
		this.smtpPw = _smtpPw;
	}

	public String getSmtpEncoding() {
		return smtpEncoding;
	}

	public void setSmtpEncoding(String _smtpEncoding) {
		this.smtpEncoding = _smtpEncoding;
	}

	public String getSmtpAuthFlag() {
		return smtpAuthFlag;
	}

	public void setSmtpAuthFlag(String _smtpAuthFlag) {
		this.smtpAuthFlag = _smtpAuthFlag;
	}

	public String getTransactionalStatus() {
		return transactionalStatus;
	}

	public void setTransactionalStatus(String arg0) {
		this.transactionalStatus = arg0;
	}

	public String getCC() {
		return cc;
	}

	public void setCC(String _cc) {
		this.cc = _cc;
	}
}
