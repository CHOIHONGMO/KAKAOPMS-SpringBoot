package com.st_ones.common.generator.web;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.st_ones.common.cache.data.ScrnCache;
import com.st_ones.common.generator.domain.GridMeta;
import com.st_ones.common.generator.service.GridGenService;
import com.st_ones.common.login.domain.UserInfo;
import com.st_ones.common.util.excel.down.ExcelExportHandler;
import com.st_ones.common.util.excel.upload.ExcelImportHandler;
import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.info.UserInfoManager;
import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import com.st_ones.everf.serverside.web.wrapper.EverHttpResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

@Controller
@Scope("prototype")
@RequestMapping(value = "/grid/generator")
public class GeneratorController {

	private Logger logger = LoggerFactory.getLogger(GeneratorController.class);
	@Autowired
	private GridGenService gridGenService;
	@Autowired
	private ScrnCache scrnCache;

	@RequestMapping(value = "/ExcelDown.so")
	public void excelDown(HttpServletRequest req, HttpServletResponse res) throws IOException {

		String fileType = req.getParameter("fileType");
		String fileName = req.getParameter("fileName");

		res.setContentType( fileType );
		fileName = fileName + "." + fileType;
		res.setContentType("application/octet-stream;");
		res.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\";");

		Map columnDefMap = new ObjectMapper().readValue(req.getParameter("columnDef"), Map.class);

		try{
			new ExcelExportHandler(req.getParameter("rows"), columnDefMap,
					fileType, req.getParameter("url"), req.getParameter("excelOptions"), req.getParameter("groupColDef"),
					req.getParameter("frozenColIndex")).write(res.getOutputStream());
		}catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			res.getOutputStream().close();
		}
	}

	/**
	 * 리얼그리드용 엑셀업로드
	 * @param req
	 * @param res
	 * @throws IOException
	 */
	@RequestMapping(value = "/uploadExcel.so", method = RequestMethod.POST)
	public void uploadExcel(HttpServletRequest req, HttpServletResponse res) throws IOException {

		res.setCharacterEncoding("UTF-8");
		res.setContentType("text/html; charset=UTF-8");

		List<FileItem> fileItems;

		PrintWriter writer = res.getWriter();
		Map<String, Object> resultMap = new HashMap<String, Object>();
		ServletFileUpload fileUpload = new ServletFileUpload(new DiskFileItemFactory());

		try {

			fileItems = fileUpload.parseRequest((javax.servlet.http.HttpServletRequest) req);

		} catch (FileUploadException fue) {

			resultMap.put("errorMessage", fue.getMessage());
			writer.println(new ObjectMapper().writeValueAsString(resultMap));
			logger.error(fue.getMessage(), fue);
			return;
		}

		FileItem excelFile = null;
		for(FileItem fileItem : fileItems) {

			if(fileItem.getFieldName().equals("file-0")) {
				excelFile = fileItem;
			}
		}

		String gridData = null;
		try {

			if(excelFile != null) {
				gridData = new ExcelImportHandler(excelFile.getName()).read2(excelFile.getInputStream());
			}

		} catch(Exception e) {

			resultMap.put("errorMessage", e.getMessage());
			writer.println(new ObjectMapper().writeValueAsString(resultMap));
			logger.error(e.getMessage(), e);
			return;
		}

		resultMap.put("gridData", gridData);
		writer.println(new ObjectMapper().writeValueAsString(resultMap));

	}

	@RequestMapping(value = "/ExcelUpload.so", method = RequestMethod.POST)
	public void excelUpload(HttpServletRequest req, HttpServletResponse res) throws IOException {

		res.setCharacterEncoding("UTF-8");
		res.setContentType("text/html; charset=UTF-8");

		List<FileItem> fileItems;
		String colInfo = "";
		PrintWriter writer = res.getWriter();
		Map<String, Object> resultMap = new HashMap<String, Object>();
		ServletFileUpload fileUpload = new ServletFileUpload(new DiskFileItemFactory());

		try {
			fileItems = fileUpload.parseRequest((javax.servlet.http.HttpServletRequest) req);
		} catch (FileUploadException e) {
			resultMap.put("errorMessage", e.getMessage());
			writer.println(new ObjectMapper().writeValueAsString(resultMap));
			logger.error(e.getMessage(), e);
			return;
		}

		FileItem excelFile = null;
		for (FileItem fileItem : fileItems){
			if(fileItem.getFieldName().equals("fileInput")) {
				excelFile = fileItem;
			}
			if(fileItem.getFieldName().equals("colInfo")) {
				colInfo = fileItem.getString("UTF-8");
			}
		}

		assert excelFile != null;
		List<Map<String, String>> gridData;

		try{
			gridData = new ExcelImportHandler(excelFile.getName(), colInfo).read(excelFile.getInputStream());
		} catch (Exception e){
			resultMap.put("errorMessage", e.getMessage());
			writer.println(new ObjectMapper().writeValueAsString(resultMap));
			logger.error(e.getMessage(), e);
			return;
		}

		resultMap.put("gridData", gridData);
		LoggerFactory.getLogger(getClass()).debug(" ========================== excelData ========================== : " + new ObjectMapper().writeValueAsString(gridData));
		writer.println(new ObjectMapper().writeValueAsString(resultMap));
	}

	@RequestMapping(value = "/gridGen.so")
	public void gridGen (
			EverHttpRequest req,
			EverHttpResponse resp) throws Exception {

		String gridId = req.getParameter("gridID");
		String screenId = req.getParameter("screenID");
		boolean detailView = Boolean.parseBoolean(req.getParameter("detailView"));

		UserInfo baseInfo = UserInfoManager.getUserInfo();
		String numberFormat = baseInfo.getNumberFormat();
		String dateFormat = baseInfo.getDateFormat();
		String langCode = StringUtils.defaultIfEmpty(baseInfo.getLangCd(), PropertiesManager.getString("eversrm.langCd.default"));

		gridGenService.init(screenId, gridId, langCode, dateFormat, numberFormat);
		gridGenService.getEssential();

		List<GridMeta> columnInfos = gridGenService.getColumnInfos();

		// 버튼 이미지 정보 가져오기
		List<Map<String, Object>> btnImageInfo = gridGenService.getBtnImageInfos(screenId);

		List<Object> list = new ArrayList<Object>();
		Map<Object, Object> rtnData = new LinkedHashMap<Object, Object>();

		for (GridMeta data : columnInfos) {

			String colType = data.getColumnType();
			Map<Object, Object> defData = new LinkedHashMap<Object, Object>();
			Map<Object, Object> tempData = new LinkedHashMap<Object, Object>();

			tempData.put("columnId", data.getColumnId());
			tempData.put("columnType", colType);
			tempData.put("commonId", data.getCommonId());
			tempData.put("text", data.getText());
			tempData.put("width", data.getWidth());
			tempData.put("maxLength", data.getMaxLength());
			tempData.put("editable", detailView ? "false" : data.getEditable());
			tempData.put("align", data.getAlign());
			tempData.put("frozen", data.isFrozeFlag());
			tempData.put("textWrap", data.getTextWrap());
			tempData.put("decimalYn", data.isDecimalYn());
			tempData.put("maskType", data.getMaskType());
			tempData.put("btnImage", btnImageInfo);

			if ("E".equals(data.getEssential())) {
				tempData.put("required", "true");
				tempData.put("defStyle", "E");
			} else {
				if ("D".equals(data.getEssential())) {
					tempData.put("defStyle", "D");
				} else if ("O".equals(data.getEssential())) {
					tempData.put("defStyle", "O");
				} else ;

				tempData.put("required", "false");
			}

			if ("imagetext".equals(data.getColumnType())) {
				if (data.getImageName() == null) {
					defData.put("src", "");
				} else {
					defData.put("src", data.getImageName());
				}

				defData.put("text", "");
				tempData.put("defData", defData);
			} else if ("combo".equals(data.getColumnType())) {
				List<Map<String, String>> comboData = data.getCombos();

				if (comboData != null) {
					for (Map<String, String> tmp : comboData) {
						tmp.put(tmp.get("value"), tmp.get("text"));
					}
					tempData.put("defData", comboData);
				}
			} else if ("date".equals(data.getColumnType())) {
				tempData.put("defData", "yyyy/MM/dd");
			} else if ("number".equals(data.getColumnType())) {
				tempData.put("defData", data.getDataFormat());
			}

			list.add(tempData);
		}

		rtnData.put("gridColData", list);
		rtnData.put("detailView", detailView);

		resp.setContentType("application/json");
		resp.getWriter().write(new ObjectMapper().writeValueAsString(rtnData));
	}
}