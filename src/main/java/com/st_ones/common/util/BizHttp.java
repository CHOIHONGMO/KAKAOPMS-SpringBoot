/*
 *   ____  _     _    _ _   _      
 *  |  _ \(_)   | |  | | | | |        
 *  | |_) |_ ___| |__| | |_| |_ _ __  
 *  |  _ <| |_  /  __  | __| __| '_ \ 
 *  | |_) | |/ /| |  | | |_| |_| |_) |
 *  |____/|_/___|_|  |_|\__|\__| .__/ 
 *                             | |    
 *                             |_|    
 */

package com.st_ones.common.util;

import org.apache.http.HttpEntity;
import org.apache.http.client.methods.*;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.protocol.HTTP;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * @author jmkim9@gmail.com
 * @version v0.1	초기 개발 (GET, POST 테스트 완료)
 * @version v0.1.1	JSON 관련 Method 추가
 * 
 * @sample
 * <PRE>
 * >>>>> Http GET
 * ExHttp exHttp = new ExHttp("http://localhost/api/test/get.do");
 * exHttp.setMethod(ExHttp.HttpMethod.GET);
 * exHttp.addHeader("token", "12345678");
 * exHttp.addBody("apikey",	"4bcc4dd49b729caa1248a7c5ff547874");
 * exHttp.addBody("q",			"귀향");
 * exHttp.addBody("output",	"json");
 * String result = exHttp.getHttpString();
 * System.out.println(result);
 * 
 * 
 * >>>>> Http POST
 * BizHttp bizHttp = new BizHttp("http://localhost/api/test/post.do", HttpMethod.POST);
 * bizHttp.addHeader("token",	"12345678");
 * 
 * bizHttp
 * 	.addHeader("token",	"12345678")
 * 	.addBody("apikey",	"4bcc4dd49b729caa1248a7c5ff547874")
 * 	.addBody("q",		"귀향")
 * 	.addBody("output",	"json")
 * 	.addBody("test",	"abcdefg")
 * 	.addFile(new File("C:\\Users\\jmkim\\Desktop\\1.jpg"));
 * 
 * String result = bizHttp.getHttpString();
 * System.out.println(result);
 *</PRE>
 */
public class BizHttp {
	public enum HttpMethod{
		GET, POST, PUT, DELETE;
	}
	
	
	HttpMethod mMethod;
	String mURL;
	HashMap<String, String> mHeader = new HashMap<String, String>();
	HashMap<String, String> mBody = new HashMap<String, String>();
	ArrayList<File> mFiles = new ArrayList<File>();
	
	public BizHttp(String url,HttpMethod method) {
		mURL = url;
		mMethod = method;
	}
	
	
	
	////////////////////////////////////////////////////////////////////////////
	//                                Setter                                  //
	////////////////////////////////////////////////////////////////////////////
	public BizHttp addHeader(String name, String value) {
		mHeader.put(name, value);

		return this;
	}

	public BizHttp addBody(String name, String value) {
		mBody.put(name, value);

		return this;
	}
	
	public BizHttp addFile(File file) {
		mFiles.add(file);

		return this;
	}

	
	
	////////////////////////////////////////////////////////////////////////////
	//                             Public  Method                             //
	////////////////////////////////////////////////////////////////////////////
	/**
	 * HTTP 요청 응답을 String으로 Return
	 * 
	 * @return String
	 */
	public String getString() {
		HttpRequestBase request;
		String strResult = null;
		
		// Make Request
		request = getRequest();
		// Add request header
		setHeader(request);
		// Add request body
		if ((mMethod == HttpMethod.POST) || (mMethod == HttpMethod.PUT))
			setParam(request);
		
		// Send Request
		CloseableHttpResponse response = null;
		try {
			CloseableHttpClient client = HttpClientBuilder.create().build();
			response = client.execute(request);
//			System.out.println("Response Code : " + response.getStatusLine().getStatusCode());
			BufferedReader rd = new BufferedReader(new InputStreamReader(response.getEntity().getContent(), "UTF-8"));
			StringBuffer result = new StringBuffer();
			String line = "";
			while ((line = rd.readLine()) != null) {
				result.append(line);
			}
			strResult = result.toString();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
            try {
				response.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }

		return strResult;
	}
	
	/**
	 * HTTP 요청 응답을 JSONObject로 Return
	 * 요청 응답이 JSON이 아닌 경우 null Return
	 * 
	 * @return
	 */
	public JSONObject getJSONObject() {
		String strResult = getString();
		System.out.println("[SAP resonse Data] : "+strResult);
		JSONObject json = null;
		try {
			json = new JSONObject(strResult);
		} catch (JSONException e) {
		}
		
		return json;
	}
	
//	public JSONArray getJSONArray() {
//		String strResult = getString();
//		
//		return new JSONArray(strResult);
//	}
	
	
	
	////////////////////////////////////////////////////////////////////////////
	//                             Privete Method                             //
	////////////////////////////////////////////////////////////////////////////
	private HttpRequestBase getRequest() {
		HttpRequestBase request = null;

		URIBuilder builder;
		try {
			builder = new URIBuilder(mURL);
			if ((mMethod == HttpMethod.GET) || (mMethod == HttpMethod.DELETE)) {
				// GET Method인 경우 Query Parameter 추가
		        for(String key : mBody.keySet()){
		        	builder.addParameter(key, URLEncoder.encode(mBody.get(key), HTTP.UTF_8));
		        }
			}
			
			URI uri = builder.build();
			
			switch (mMethod) {
				case POST :
					request = new HttpPost(uri);
					break;
				case PUT :
					request = new HttpPut(uri);
					break;
				case DELETE :
					request = new HttpDelete(uri);
					break;
				default:
					request = new HttpGet(uri);
					break;
			}
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (UnsupportedEncodingException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return request;
	}

	private void setHeader(HttpRequestBase request) {
        for(String key : mHeader.keySet()) {
        	request.addHeader(key, mHeader.get(key));
        }
	}
	
	private void setParam(HttpRequestBase request) {		
		// urlencoded
//		List<NameValuePair> param = new ArrayList<NameValuePair>();
//        for(String key : mBody.keySet()) {
//        	param.add(new BasicNameValuePair(key, mBody.get(key)));
//        }
//
//    	try {
//	        if(request instanceof HttpPost) {
//				((HttpPost) request).setEntity(new UrlEncodedFormEntity(param, HTTP.UTF_8));
//	        } else if(request instanceof HttpPut) {
//				((HttpPut) request).setEntity(new UrlEncodedFormEntity(param, HTTP.UTF_8));
////	        } else if(request instanceof HttpDelete) {
////				((HttpDelete) request).setEntity(new UrlEncodedFormEntity(param));
//	        }
//		} catch (UnsupportedEncodingException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
		
		
		// Multipart
        MultipartEntityBuilder builder = MultipartEntityBuilder.create();

        for(String key : mBody.keySet()) {
	        builder.addTextBody(key, mBody.get(key), ContentType.create("Multipart/related", "UTF-8"));
        }
        
        // File
        for(File file : mFiles) {
    		FileBody body = new FileBody(file);
    		builder.addPart(file.getName(), body);
        }
        
        
        HttpEntity reqEntity = builder.build();
        
        
        if(request instanceof HttpPost) {
			((HttpPost) request).setEntity(reqEntity);
        } else if(request instanceof HttpPut) {
			((HttpPut) request).setEntity(reqEntity);
//        } else if(request instanceof HttpDelete) {
//			((HttpDelete) request).setEntity(new UrlEncodedFormEntity(param));
        }

	}
}
