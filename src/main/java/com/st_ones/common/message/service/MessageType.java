package com.st_ones.common.message.service;

/**
 * User: Azure
 * Date: 13. 11. 18
 * Time: 오후 8:59
 */
public enum MessageType {

    /**
     * 성공적으로 처리되었습니다.
     */
    PROCESSED_SUCCESSFULLY("0001"),
    /**
     * 저장하시겠습니까?
     */
    WILL_YOU_SAVE("0031"),
    /**
     * 성공적으로 저장되었습니다.
     */
    SAVE_SUCCEED("0031"),
    /**
     * 삭제하시겠습니까?
     */
    WILL_YOU_DELETE("0013"),
    /**
     * 성공적으로 삭제되었습니다.
     */
    DELETE_SUCCEED("0017"),
    /**
     * 결재가 상신되었습니다.
     */
    APPROVAL_COMPLETED("0023"),
    /**
     * 권한이 없습니다.
     */
    AUTH_REQUIRED("0037"),
    /*
     * 선택한 데이터가 이미 처리되었습니다.
     */
    PROCESSED_ALREADY("0045");

    private final String code;
    MessageType(String _code) {
        this.code = _code;
    }

    public String getCode() {
        return this.code;
    }
}
