package com.st_ones.common.util.clazz;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;

public class EverFile {

	private static Logger logger = LoggerFactory.getLogger(EverFile.class);

	/**
	 * 전체 파일을 읽어 파일의 내용을 String 으로 반환
	 * return contents of file as string 
	 * @param filename
	 * @return String
	 * @throws IOException
	 */
	public static String fileReadByOffset(String filename) throws IOException {
		File file = null;
		BufferedReader in = null;
		StringWriter out = null;
		String contents = "";
		char[] buf = new char[1024];
		int len = 0;

		try {
			file = new File(filename);

			if (file.exists()) {
				in = new BufferedReader(new FileReader(file));
				out = new StringWriter();

				while ((len = in.read(buf, 0, buf.length)) != -1) {
					out.write(buf, 0, len);
				}

				contents = out.toString();
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(in != null) {
				in.close();
			}
		}

		return contents;
	}

	/**
	 * 파일 복사
	 * fileCopy
	 * @param sourceFileName
	 * @param targetFileName
	 * @throws Exception
	 */
	public static void copyFile(String sourceFileName, String targetFileName) throws Exception {

		byte[] buf = new byte[1000];
		FileInputStream fis = null;
		FileOutputStream fos = null;

		try {
			fis = new FileInputStream(sourceFileName);
			fos = new FileOutputStream(targetFileName);

			int intFileSize = 0;
			int intMaxFileSize = 1000 * 10; //10Mbyte
			while (((fis.read(buf, 0, 1000)) > 0) && (intFileSize < intMaxFileSize)) {
				fos.write(buf, 0, 1000);
				intFileSize++;
			}
		} catch (IOException e) {
			logger.error(e.getMessage(), e);
			throw e;
		} finally {
			if(fos != null) {
				fos.close();
			}
			if(fis != null) {
				fis.close();
			}
		}
	}

	/**
	 * 한글 처리 관련 추가
	 * @param filename
	 * @param encoding
	 * @return String
	 * @throws IOException
	 */
	public static String fileReadByOffsetByEncoding(String filename, String encoding) throws IOException {

		File file;
		BufferedReader bufferedReader = null;
		FileInputStream fileInputStream = null;
		StringWriter out;
		String contents = "";
		char[] buf = new char[1024];
		int len;

		try {

			file = new File(filename);
			fileInputStream = new FileInputStream(file);

			if (file.exists()) {
				bufferedReader = new BufferedReader(new InputStreamReader(fileInputStream, encoding));
				out = new StringWriter();

				while ((len = bufferedReader.read(buf, 0, buf.length)) != -1) {
					out.write(buf, 0, len);
				}

				contents = out.toString();
			}
		} catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(bufferedReader != null) {
				bufferedReader.close();
			}
			if(fileInputStream != null) {
				fileInputStream.close();
			}
		}

		return contents;
	}

	/**
	 * 파일에 내용을 Write
	 * @param filename
	 * @param contents
	 * @return boolean
	 * @throws IOException
	 */
	public static boolean fileWrite(String filename, StringBuffer contents) throws IOException {

		boolean rtn = true;
		FileWriter fw = null;

		try {
			fw = new FileWriter(filename);
			fw.write(contents.toString());
		} catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(fw != null) {
				fw.close();
			}
		}

		return rtn;
	}

	/**
	 * 파일에 내용을 Write
	 * @param filename
	 * @param contents
	 * @return boolean
	 * @throws IOException
	 */
	public static boolean fileWrite(String filename, String contents) throws IOException {

		boolean rtn = true;
		FileWriter fw = null;

		try {
			fw = new FileWriter(filename);
			fw.write(contents.toString());
		} catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(fw != null) {
				fw.close();
			}
		}
		
		return rtn;
	}

	/**
	 * 파일에 내용을 주어진 인코딩으로 Write
	 * @param filename
	 * @param contents
	 * @param encoding
	 * @throws IOException
	 */
	public void fileWriteByEncoding(String filename, String contents, String encoding) throws IOException {

		BufferedWriter bw = null;
		try {
			bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(new File(filename), false), encoding));
			bw.write(contents);
		} catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(bw != null) {
				bw.close();
			}
		}
	}

	/**
	 * 파일의 전체 내용을 읽어 String buffer로 반환
	 * @param fileName
	 * @return StringBuffer
	 * @throws IOException
	 */
	public StringBuffer fileReadByAll(String fileName) throws IOException {
		
		StringBuffer sb = new StringBuffer();
		File fi = new File(fileName);
		BufferedReader in = null;
		FileReader fr = null;

		try {
			if (fi.exists()) {
				fr = new FileReader(fi);
				in = new BufferedReader(fr);

				String aaa = "";

				while ((aaa = in.readLine()) != null) {
					sb.append(aaa + "\n");
				}
			}
		} catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(in != null) in.close();
			if(fr != null) fr.close();
		}

		return sb;
	}

	/**
	 * 파일 삭제
	 * delete File
	 * @param filename
	 */
	public static void deleteFile(String filename) {
		
		File fi = new File(filename);
		if (fi.exists()) {
			fi.delete();
		}
	}

	/**
	 * 파일 끝에 내용을 추가
	 * append to file
	 * @param fileName
	 * @param Contents
	 * @throws IOException
	 */
	public void appendFile(String fileName, String Contents) throws IOException {

		BufferedWriter bw = null;
		try {
			bw = new BufferedWriter(new FileWriter(fileName, true));
			bw.write(Contents, 0, Contents.length());
		} catch(Exception e) {
			logger.error(e.getMessage(), e);
		} finally {
			if(bw != null) {
				bw.close();
			}
		}
	}
	
	/**
	 * 파일 정보를 해쉬값으로 변환
	 * @param filePath
	 * @param fileNm
	 * @throws IOException
	 */
	public static String fileToHash(File file) throws Exception {

		String hashData = "";
		BufferedInputStream fis = new BufferedInputStream(new FileInputStream(file));
		hashData = DigestUtils.sha256Hex(fis);
		
		IOUtils.closeQuietly(fis);
		return hashData;
	}

}
