package com.st_ones.evermp.buyer.cont;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

/**
 * <pre>
 ******************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 St-Ones CORP., ALL RIGHTS RESERVED | Confidential)
 ******************************************************************************
 * </pre>
 * @File Name : PDF_Mapper.java
 * @author
 * @date 2020. 12. 10.
 * @version 1.0
 * @see
 */

@Repository
public interface PdfMapper {

    // 계약서 주서식, 부서식 html 생성여부 변경
    //int doUpdateHtmlCreateFlag(Map<String, String> param);

    // 계약서 주서식정보 가져오기
    List<Map<String, Object>> getContractListForPDF(Map<String, String> param);

    // 계약서 부서식정보 가져오기
    List<Map<String, Object>> getContractSubListForPDF(Map<String, Object> param);

    // 파트너사에서 계약서 최종확인시 주서식 하단에 안내문구를 삽입한다.
    int putSignOnMainForm(Map<String, String> param);

}