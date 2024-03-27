package com.st_ones.evermp.buyer.cont.service;

import com.itextpdf.html2pdf.ConverterProperties;
import com.itextpdf.html2pdf.HtmlConverter;
import com.itextpdf.html2pdf.resolver.font.DefaultFontProvider;
import com.itextpdf.io.font.FontProgramFactory;
import com.itextpdf.kernel.events.Event;
import com.itextpdf.kernel.events.IEventHandler;
import com.itextpdf.kernel.events.PdfDocumentEvent;
import com.itextpdf.kernel.font.PdfFont;
import com.itextpdf.kernel.geom.PageSize;
import com.itextpdf.kernel.geom.Rectangle;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfPage;
import com.itextpdf.kernel.pdf.PdfReader;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.canvas.PdfCanvas;
import com.itextpdf.layout.Canvas;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.IBlockElement;
import com.itextpdf.layout.element.IElement;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.font.FontProvider;
import com.itextpdf.layout.layout.LayoutArea;
import com.itextpdf.layout.layout.LayoutContext;
import com.itextpdf.layout.layout.LayoutResult;
import com.itextpdf.layout.renderer.DocumentRenderer;
import com.itextpdf.layout.renderer.TableRenderer;
import com.st_ones.common.util.ContStringUtil;
import com.st_ones.common.util.clazz.EverString;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.service.BaseService;
import com.st_ones.evermp.buyer.cont.PdfMapper;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;


/**
 * <pre>
 * *****************************************************************************
 * 상기 프로그램에 대한 저작권을 포함한 지적재산권은 ㈜에스티원즈에 있으며,
 * ㈜에스티원즈가 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
 * ㈜에스티원즈의 지적재산권 침해에 해당됩니다.
 * (Copyright ⓒ 2013 St-Ones CORP., ALL RIGHTS RESERVED | Confidential)
 * *****************************************************************************
 * </pre>
 *
 * @author
 * @version 1.0
 * @File Name : PDF_Service.java
 * @date 2020. 12. 10.
 * @see
 */
@Service(value = "pdfUtil")
public class makeHtmlService extends BaseService {

    @Autowired private PdfMapper pdfMapper;

    private static String HTML_OUTPUT_PATH  = PropertiesManager.getString("html.output.path"); // HTML 생성 경로
    private static String NANUM_FONT1  = PropertiesManager.getString("html.output.pdf.font1"); // 나눔폰트경로
    private static String NANUM_FONT2  = PropertiesManager.getString("html.output.pdf.font2"); // 나눔폰트경로
    private static String NANUM_FONT3  = PropertiesManager.getString("html.output.pdf.font3"); // 나눔폰트경로
    private static String NANUM_FONT4  = PropertiesManager.getString("html.output.pdf.font4"); // 나눔폰트경로




    @Autowired private CT0300Service ct0300service;

//    private static String SOURCE_FILE_PATH  = PropertiesManager.getString("source.file.path"); // HTML 생성 경로
//    private static String PDF_OUTPUT_PATH = PropertiesManager.getString("pdf.output.path"); // PDF 생성 경로

    // PDF 저장
    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public void doMakePDF(Map<String, String> param) throws Exception {

    	String locBuyerNm = param.get("PR_BUYER_NM");

//    	if("".equals(locBuyerNm)) {
//    		throw new Exception("구매사명이 부적합 합니다.");
//    	}


        // 1. 계약서 주서식, 부서식을 html 파일로 생성하여 경로에 저장하기
        int successCnt = 0;
        int failCnt    = 0;
        String failMsg = "";

        // 1. 일반계약서 HTML 만들기
        // 주서식, 부서식 내용 가져와서 HTML 파일로 만들기
        List<Map<String, Object>> mainList = pdfMapper.getContractListForPDF(param);

        String contNum = "";
        String mainContractForm = "";
        for (Map<String, Object> mainMap : mainList) {
            contNum = (String)mainMap.get("CONT_NUM");
            StringBuffer mainContents = new StringBuffer();
            mainContents.setLength(0);

            // 1-1. 주서식 html로 가져오기
            mainContractForm = String.valueOf(mainMap.get("CONTRACT_TEXT"));

            // 파트너사에서 계약서 최종확인시 주서식 하단에 안내문구를 삽입한다. 전자계약은 contType = 0
            String callType = EverString.nullToEmptyString(param.get("APAR_TYPE"));
            String contType = EverString.nullToEmptyString(param.get("MANUAL_CONT_FLAG"));


        	String noticeStr = "";
            if ("0".equals(contType)) {
                noticeStr = "<br><table class=\"table\" style=\"width: 100%;\"><tbody><tr>";
                noticeStr = noticeStr + "<td style=\"height: 25px; text-align:left; font-family:굴림체; font-size:13px; color:red;\">본 계약서는 (주)대명소노시즌 에서 전자서명하고 "+mainMap.get("VENDOR_NM")+"이(가) 전자서명한 전자서명법에 근거하여  체결된 전자계약서 입니다. 본 계약서에 대한 문의는 (주)대명소노시즌 담당부서에 문의하시기 바랍니다.</td>";
                noticeStr = noticeStr + "</tr></tbody></table>";
            }

            if (mainContractForm.indexOf("NOTICE") > -1 && EverString.isNotEmpty(param.get("SIGN_FLAG"))) {
                mainContractForm = mainContractForm.replaceAll("<p id=\"NOTICE\" style=\"height: 0px;\">&nbsp;</p>", noticeStr);
                mainContents.append(ContStringUtil.getHtmlContents(mainContractForm, true));
                // 변경된 주석식을 Update한다.

                param.put("FORM_NUM", (String)mainMap.get("FORM_NUM"));
                param.put("CONTRACT_TEXT", mainContents.toString());
                pdfMapper.putSignOnMainForm(param);
            } else {
                mainContents.append(ContStringUtil.getHtmlContents(mainContractForm, true));
            }

            // 1-2. 부서식 html로 가져오기
            List<Map<String, Object>> subList = pdfMapper.getContractSubListForPDF(mainMap);
            String subContractForm = "";
            for (Map<String, Object> subMap : subList) {
                subContractForm  = "<div style='page-break-after: always; page-break-inside: avoid;'></div>";
                subContractForm += String.valueOf(subMap.get("CONTRACT_TEXT"));
                mainContents.append(ContStringUtil.getHtmlContents(subContractForm, true));
            }



            // 구매사가 첨부한 파일을 추가한다.
            String fileListStr = ct0300service.getOttogiFileInformation(param);
            if(!StringUtils.isEmpty(fileListStr)) {
            	mainContents.append(ContStringUtil.getHtmlContents("<div style='page-break-after: always; page-break-inside: avoid;'></div>"+fileListStr, true));
            }


            StringBuffer t_mainContents = new StringBuffer(mainContents.toString());
            while (t_mainContents.indexOf("<textarea") > -1) {
            	int idxT = t_mainContents.indexOf("<textarea");
            	int idxE = t_mainContents.indexOf("</textarea>", idxT);
                t_mainContents = t_mainContents.replace(idxE, idxE + 11, "</div>");
                t_mainContents = t_mainContents.replace(idxT, idxT + 9, "<div style=\"white-space:pre-wrap;\"");
            }
            // 1-3. 계약서 주서식, 부서식 html 파일로 만들기
            mainMap.put("CONTRACT_TEXT", t_mainContents);




            // 파트너사(S)에서 PDF를 만드는 경우, callback method에서 PROGRESS_CD를 변경해야 한다. [계약서 최종확인 > 협력사 서명대기]
            mainMap.put("CALL_TYPE", (EverString.nullToEmptyString(param.get("CALL_TYPE")).equals("") ? "B" : param.get("CALL_TYPE")));




            try {
                // 계약서별 주서식, 부서식 합쳐 서 html 파일 생성
                int fileCnt = this.writeToHtmlFile(mainMap);
                if (fileCnt > 0) {
                    successCnt++;
                } else {
                    failMsg += (failCnt > 0 ? ", " : "") + contNum;
                    failCnt++;
                }
            } catch (Exception ex) {
            	ex.printStackTrace();
                failMsg += (failCnt > 0 ? ", " : "") + contNum;
                failCnt++;
                System.out.println("계약번호[" + contNum + "]를 HTML 파일 생성시 오류 : " + ex.getMessage());
            }






        }


    }






    public void makepdfFile(String sourceSrc, String dest) throws IOException {
    	//src = "D:/EC202103000011@1.html";
    	//한국어를 표시하기 위해 폰트 적용
        //ConverterProperties : htmlconverter의 property를 지정하는 메소드인듯
        ConverterProperties properties = new ConverterProperties();
        FontProvider fontProvider = new DefaultFontProvider(false, false, false);
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT1));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT2));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT3));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT4));
        properties.setFontProvider(fontProvider);

    	//pdf 페이지 크기를 조정. convertToElements의 매개변수 부분만 다름.

        FileInputStream fis = new FileInputStream(sourceSrc);

    	List<IElement> elements = HtmlConverter.convertToElements( fis , properties);
        PdfDocument pdf = new PdfDocument(new PdfWriter(dest));


        Document document = new Document(pdf);

    	//setMargins 매개변수순서 : 상, 우, 하, 좌
        document.setMargins(50, 30, 50, 30);



        for (IElement element : elements) {

        	if(element instanceof com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) {
        		document.add(((com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) element).setLineThrough());
        	} else {
                document.add((IBlockElement) element);
        	}

        }

        document.close();
        fis.close();
    }

    public void makepdfStr(String BODY, String dest) throws IOException {
    	//한국어를 표시하기 위해 폰트 적용
        //ConverterProperties : htmlconverter의 property를 지정하는 메소드인듯
        ConverterProperties properties = new ConverterProperties();
        FontProvider fontProvider = new DefaultFontProvider(false, false, false);
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT1));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT2));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT3));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT4));

        properties.setFontProvider(fontProvider);

    	//pdf 페이지 크기를 조정
    	List<IElement> elements = HtmlConverter.convertToElements(BODY, properties);
        PdfDocument pdf = new PdfDocument(new PdfWriter(dest));
        Document document = new Document(pdf,PageSize.A4);
    	//setMargins 매개변수순서 : 상, 우, 하, 좌
    	document.setMargins(50, 30, 50, 30);

    	document.getPdfDocument().setDefaultPageSize(PageSize.A4.rotate());


        for (IElement element : elements) {
        	if(element instanceof com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) {
        		document.add(((com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) element).setLineThrough());
        	} else {
                document.add((IBlockElement) element);
        	}
        }
        document.close();
    }



    public void makepdfStrPO(String BODY, String dest) throws IOException {
        /*//한국어를 표시하기 위해 폰트 적용
        String FONT = NANUM_FONT;
        //ConverterProperties : htmlconverter의 property를 지정하는 메소드인듯
        ConverterProperties properties = new ConverterProperties();
        FontProvider fontProvider = new DefaultFontProvider(false, false, false);
        FontProgram fontProgram = FontProgramFactory.createFont(FONT);
        fontProvider.addFont(fontProgram);
        properties.setFontProvider(fontProvider);

        //pdf 페이지 크기를 조정
        List<IElement> elements = HtmlConverter.convertToElements(BODY, properties);
        PdfDocument pdf = new PdfDocument(new PdfWriter(dest));
        Document document = new Document(pdf,PageSize.A4);
        //setMargins 매개변수순서 : 상, 우, 하, 좌
        document.setMargins(0, 0, 0, 0);

        document.getPdfDocument().setDefaultPageSize(PageSize.A4.rotate());


        for (IElement element : elements) {
			if(element instanceof com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) {
        		document.add(((com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) element).setLineThrough());
        	} else {
                document.add((IBlockElement) element);
        	}
        }

        document.close();*/
        //String FONT = "D:\\malgun.ttf";

        ConverterProperties properties = new ConverterProperties();
        FontProvider fontProvider = new DefaultFontProvider(false, false, false);
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT1));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT2));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT3));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT4));

        properties.setFontProvider(fontProvider);

        PdfDocument pdf = new PdfDocument(new PdfWriter(dest));
        //pdf.setDefaultPageSize(PageSize.A4.rotate());
        //Document document = new Document(pdf,PageSize.A4);
        Document document = new Document(pdf);
        document.setMargins(0, 0, 0, 0);

        document.getPdfDocument().setDefaultPageSize(PageSize.A4.rotate());;

/*        int numberOfPages = pdf.getNumberOfPages() + 1;
        for (int i = 1; i <= numberOfPages; i++) {
            document.showTextAligned(new Paragraph(String.format("page %s of %s", i, numberOfPages)),
                    0, 0, i, TextAlignment.LEFT, VerticalAlignment.TOP, 0);
        }*/





//        MediaDeviceDescription med = new MediaDeviceDescription(MediaType.ALL);
//        med.setOrientation("LANDSCAPE");
//        properties.setMediaDeviceDescription(med);


        HtmlConverter.convertToPdf(BODY, pdf, properties);

        //HtmlConverter.convertToPdf(BODY, new FileOutputStream(dest));



    }

    public void makepdfStrInvoice(String BODY, String dest) throws Exception {
        //한국어를 표시하기 위해 폰트 적용
        //ConverterProperties : htmlconverter의 property를 지정하는 메소드인듯
        ConverterProperties properties = new ConverterProperties();
        FontProvider fontProvider = new DefaultFontProvider(false, false, false);
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT1));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT2));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT3));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT4));

        properties.setFontProvider(fontProvider);

        //pdf 페이지 크기를 조정
        List<IElement> elements = HtmlConverter.convertToElements(BODY, properties);
        PdfDocument pdf = new PdfDocument(new PdfWriter(dest));
        Document document = new Document(pdf,PageSize.A4);
        //setMargins 매개변수순서 : 상, 우, 하, 좌
        document.setMargins(50, 40, 57, 40);

        document.getPdfDocument().setDefaultPageSize(PageSize.A4.rotate());


        for (IElement element : elements) {
        	if(element instanceof com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) {
        		document.add(((com.itextpdf.html2pdf.attach.impl.layout.HtmlPageBreak) element).setLineThrough());
        	} else {
                document.add((IBlockElement) element);
        	}
        }






        document.close();

       // manipulatePdf(dest, finaldest);

    }

    private static class TableHeaderEventHandler implements IEventHandler {
        private Table table;
        private float tableHeight;
        private Document doc;

        public TableHeaderEventHandler(Document doc) {
            this.doc = doc;
            initTable();

            TableRenderer renderer = (TableRenderer) table.createRendererSubTree();
            renderer.setParent(new DocumentRenderer(doc));

            // Simulate the positioning of the renderer to find out how much space the header table will occupy.
            LayoutResult result = renderer.layout(new LayoutContext(new LayoutArea(0, PageSize.A4)));
            tableHeight = result.getOccupiedArea().getBBox().getHeight();
        }

        @Override
        public void handleEvent(Event currentEvent) {
            PdfDocumentEvent docEvent = (PdfDocumentEvent) currentEvent;
            PdfDocument pdfDoc = docEvent.getDocument();
            PdfPage page = docEvent.getPage();
            PdfCanvas canvas = new PdfCanvas(page.newContentStreamBefore(), page.getResources(), pdfDoc);
            PageSize pageSize = pdfDoc.getDefaultPageSize();
            float coordX = pageSize.getX() + doc.getLeftMargin();
            float coordY = pageSize.getTop() - doc.getTopMargin();
            float width = pageSize.getWidth() - doc.getRightMargin() - doc.getLeftMargin();
            float height = getTableHeight();
            Rectangle rect = new Rectangle(coordX, coordY, width, height);

            new Canvas(canvas, rect)
                    .add(table)
                    .close();
        }

        public float getTableHeight() {
            return tableHeight;
        }

        private void initTable()
        {
            table = new Table(1);
            table.useAllAvailableWidth();
            table.addCell("Header row 1");
            table.addCell("Header row 2");
            table.addCell("Header row 3");
        }
    }


    protected void manipulatePdf(String src, String finaldest) throws Exception {
        PdfDocument pdfDoc = new PdfDocument(new PdfReader(src), new PdfWriter(finaldest));
        Document doc = new Document(pdfDoc);


        int numberOfPages = pdfDoc.getNumberOfPages();
        for (int i = 1; i <= numberOfPages; i++) {

            //doc.showTextAligned(new Paragraph(String.format("< %s / %s >", i, numberOfPages)), 790, 48, i, TextAlignment.RIGHT, VerticalAlignment.TOP, 0);
        }

        doc.close();

        File file = new File(src);
        file.delete();
    }


    public void process(Table table, String line, PdfFont font, int fontSize, boolean isHeader) {

        // Parses csv string line with specified delimiter
        StringTokenizer tokenizer = new StringTokenizer(line, ";");

        while (tokenizer.hasMoreTokens()) {
            Paragraph content = new Paragraph(tokenizer.nextToken()).setFont(font).setFontSize(fontSize);

            if (isHeader) {
                table.addHeaderCell(content);
            } else {
                table.addCell(content);
            }
        }
    }


    public void makepdfStrPO20210809(String BODY, String dest) throws IOException {
        /*//한국어를 표시하기 위해 폰트 적용
        String FONT = "D:\\malgun.ttf";
        //ConverterProperties : htmlconverter의 property를 지정하는 메소드인듯
        ConverterProperties properties = new ConverterProperties();
        FontProvider fontProvider = new DefaultFontProvider(false, false, false);
        FontProgram fontProgram = FontProgramFactory.createFont(FONT);
        fontProvider.addFont(fontProgram);
        properties.setFontProvider(fontProvider);

        //pdf 페이지 크기를 조정
        List<IElement> elements = HtmlConverter.convertToElements(BODY, properties);
        PdfDocument pdf = new PdfDocument(new PdfWriter(dest));
        Document document = new Document(pdf,PageSize.A4);
        //setMargins 매개변수순서 : 상, 우, 하, 좌
        document.setMargins(0, 0, 0, 0);

        document.getPdfDocument().setDefaultPageSize(PageSize.A4.rotate());


        for (IElement element : elements) {
            document.add((IBlockElement) element);
        }

        document.close();*/
//        String FONT = "D:\\malgun.ttf";

        ConverterProperties properties = new ConverterProperties();
        FontProvider fontProvider = new DefaultFontProvider(false, false, false);
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT1));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT2));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT3));
        fontProvider.addFont(FontProgramFactory.createFont(NANUM_FONT4));

        properties.setFontProvider(fontProvider);

        PdfWriter writer = new PdfWriter(dest);
        PdfDocument pdf = new PdfDocument(writer);
        pdf.setDefaultPageSize(PageSize.A4.rotate());
     //   pdf.setMargins(0, 0, 0, 0);




        HtmlConverter.convertToPdf(BODY,  pdf, properties);

        //HtmlConverter.convertToPdf(BODY, new FileOutputStream(dest));



    }





    public void makepdf2(String src, String dest) throws IOException {
        // IO
        File htmlSource = new File(src);
        File pdfDest = new File(dest);
         // pdfHTML specific code
        ConverterProperties converterProperties = new ConverterProperties();
        HtmlConverter.convertToPdf(new FileInputStream(htmlSource),
       new FileOutputStream(pdfDest), converterProperties);
    }







    // 계약서 주서식 및 주서식으로 파일 생성하기
    public int writeToHtmlFile(Map<String, Object> param) throws Exception {

        int result = 0; // 파일 생성 여부

        // 생성할 파일명 : 계약번호  + "@" + 계약차수 + ".html"
        String htmlFileName = (String) param.get("FILE_NAME") + ".html";
        String pdfFileName = (String) param.get("FILE_NAME") + ".pdf";
        // 파일 전체 경로 및 파일명
        String fileFullPath = HTML_OUTPUT_PATH + htmlFileName;
        String pdffileFullPath = HTML_OUTPUT_PATH + pdfFileName;

        // 익스플로러에서 하단의 utf-8이 사라지는 현상 있음
        String contents = "<meta charset='utf-8'>";
        contents += String.valueOf(param.get("CONTRACT_TEXT"));

        BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(fileFullPath), "utf-8"));
        bw.write(contents);

        // 파일 size = 0 인 경우 파일 삭제
        File newfile = new File(fileFullPath);
        if (newfile.exists()) {
            result = 1;
        }
        bw.close();
        makepdfFile(fileFullPath,pdffileFullPath);

        return result;
    }


    // PDF 변환 요청 XML 문자열을 구성합니다.
    // 이 예제와 같이 문자열을 이어서 만들거나 또는 템플릿 XML 문자열을 미리 정의해놓고 XPath 등으로 필요한 값만 지정할 수도 있습니다.
    private String createPdfConversionRequestXml(String requestID, PdfConversionData data) {

        StringBuffer buffer = new StringBuffer();
        buffer.append("<?xml version='1.0' encoding='utf-8'?>");
        buffer.append("<Message>");
        buffer.append("  <RequestID>" + requestID + "</RequestID>"); // RequestID는 wizPDF Server에서는 사용되지 않지만 Callback단으로 그대로 전달되므로 요청 구분에 사용할 수 있습니다.
        buffer.append("  <SourceFiles>" + data.sourceFiles + "</SourceFiles>");
        buffer.append("  <TargetPath>" + data.outputFolder + "</TargetPath>");
        buffer.append("  <TargetFileName>" + data.outputFileName + "</TargetFileName>");
        buffer.append("  <Priority>" + String.valueOf(data.priority) + "</Priority>");
        buffer.append("  <Flag>");
        buffer.append("    <success_url>" + data.successCallbackUrl + "</success_url>");
        buffer.append("    <failure_url>" + data.failureCallbackUrl + "</failure_url>");
        buffer.append("    <contNum>" + data.contNum + "</contNum>");
        buffer.append("    <contCnt>" + data.contCnt + "</contCnt>");
        buffer.append("    <callType>" + data.callType + "</callType>");
        buffer.append("  </Flag>");
        buffer.append("  <ProcessorTypeBSetting>"); // 워터마크 설정은 매뉴얼을 참고하여 필요한 설정들을 지정하십시오.
        buffer.append("    <Watermark>");
        buffer.append("      <WatermarkText Enabled='" + String.valueOf(data.enableWatermark).toLowerCase() + "' Text='" + data.watermarkText + "' FontSize='30' />");
        buffer.append("    </Watermark>");
        buffer.append("  </ProcessorTypeBSetting>");
        buffer.append("</Message>");
        return buffer.toString();
    }

    // HttpURLConnection을 이용해 HTTP POST 요청을 실행합니다.
    // SSL을 사용할 경우에는 HttpsURLConnection 클래스를 사용하시고 SSL 인증서 경고를 무시하도록 관련 코드를 지정하십시오.
    private BooleanResult executeHttpRequest(String api_uri, String data) {

        try {
            URL url = new URL(api_uri);
            HttpURLConnection uc = (HttpURLConnection)url.openConnection();
            uc.setDoOutput(true);
            uc.setDoInput(true);
            uc.setUseCaches(false);
            uc.setRequestMethod("POST");
            uc.setRequestProperty("Content-type", "application/x-www-form-urlencoded");

            PrintWriter out = new PrintWriter(uc.getOutputStream());
            out.print(data);
            out.close();

            String line = "";
            StringBuffer inStrBuffer = new StringBuffer();

            BufferedReader reader = null;
            if(uc.getResponseCode() == 200) {
                reader = new BufferedReader(new InputStreamReader(uc.getInputStream(), "UTF-8"), 10240);
            } else {
                reader = new BufferedReader(new InputStreamReader(uc.getErrorStream(), "UTF-8"), 10240);
            }

            while((line = reader.readLine()) != null) {
                inStrBuffer.append(line);
            }
            reader.close();

            String response = inStrBuffer.toString();
            return new BooleanResult(true, response,0);

        } catch(Exception e) {
            return  new BooleanResult(false, "Executing HttpRequest failed. url=" + api_uri + ", ErrorMessage=" + e.toString(), -999);
        }
    }

    // PDF 변환 요청 입력 파라미터들을 정의하는 클래스입니다.
    // PDF 변환 요청에 다른 파라미터를 지정하시려면 여기에 해당 속성을 추가하고 XML 생성시 적용하십시오.
    public class PdfConversionData {
        public String contNum = "";
        public String contCnt = "";
        public String callType = "";
        public String sourceFiles = "";
        public String outputFolder ="";
        public String outputFileName = "";
        public int priority = 3;
        public String successCallbackUrl = "";
        public String failureCallbackUrl = "";
        public boolean enableWatermark = true;
        public String watermarkText = "";
    }

    // 작업 결과와 메시지를 전달하기 위한 Helper Class
    public class BooleanResult {

        public boolean result= false;
        public String message="";
        public int code = 0;
        public Object data = null;

        public BooleanResult(boolean ret, String msg, int code) {
            this.result= ret;
            this.message= msg;
            this.code=code;
        }

        public BooleanResult(boolean ret, String msg, int code, Object data) {
            this.result= ret;
            this.message= msg;
            this.code=code;
            this.data= data;
        }
    }

    // 수신한 PDF 변환 결과에 매핑되는 클래스
    // 이 샘플에서는 변환 결과 처리에 필요한 주요 속성만 정의합니다.
    public class PdfServerResult {
        public String contNum = "";
        public String contCnt = "";
        public String callType = "";
        public boolean result = false;
    }



}