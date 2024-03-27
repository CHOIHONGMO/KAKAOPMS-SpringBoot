package com.st_ones.common.util.clazz;

import com.st_ones.everf.serverside.config.PropertiesManager;
import com.st_ones.everf.serverside.exception.EnumerationNotFoundException;
import org.junit.Test;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.UnsupportedEncodingException;
import java.security.*;
import java.util.Base64;
import java.util.List;
import java.util.Map;

public class EverEncryption {

	/**
	 * Decryption is not available.
	 */
	public enum OneWayAlgorithmType {
		SHA_1("SHA-1"), MD5("MD5"), SHA_256("SHA-256");
		
		String algorithmType;
		OneWayAlgorithmType(String _algorithmType) {
			this.algorithmType = _algorithmType;
		}
		public static OneWayAlgorithmType fromString(String algorithmType) throws EnumerationNotFoundException {
			if(algorithmType != null) {
				for(OneWayAlgorithmType o : OneWayAlgorithmType.values()) {
					if (algorithmType.equals(o.algorithmType)) {
						return o;
					}
				}
			}
			throw new EnumerationNotFoundException(algorithmType);
		}
		public String getString() {
			return this.algorithmType;
		}
	}
	
	/**
	 * Decryption is available.
	 */
	public enum TwoWayAlgorithmType {
		TripleDES,	// Triple Data Encryption Standard
		AES,		// Advanced Encryption Standard 
		SEED		// KISA
	}
	
	/**
	 * 복호화가 불가능한 암호화방식으로,암호화된 문자열을 리턴한다. 
	 * @param oneWayAlgorithmType
	 * @param password
	 * @return
	 * @throws NoSuchAlgorithmException
	 * @throws UnsupportedEncodingException
	 */
	public static String getEncrypted(OneWayAlgorithmType oneWayAlgorithmType, String password) throws NoSuchAlgorithmException, UnsupportedEncodingException {
		
		String encrypted = null;
		MessageDigest md = null;
		
		switch(oneWayAlgorithmType) {
			case SHA_1:
			case MD5:
				
				/**
				 * 대명소노 MD5 암호화 방식 (2022.10.18) : 비밀번호를 대문자로 변경
				 */
				md = MessageDigest.getInstance(oneWayAlgorithmType.getString());
				md.update(new String(password).toUpperCase().getBytes("UTF-8"));
				byte[] mdData = md.digest();

				java.io.ByteArrayInputStream bin   = new java.io.ByteArrayInputStream(mdData);
				java.io.ByteArrayOutputStream bout = new java.io.ByteArrayOutputStream();

				Base64.Encoder encoder = Base64.getEncoder();
				encrypted = encoder.encodeToString(bin.readAllBytes());

				break;
			case SHA_256:

				md = MessageDigest.getInstance(oneWayAlgorithmType.getString());
				md.update(new String(password).getBytes("UTF-8"));				

				byte[] shaData = md.digest();
				StringBuffer shasb = new StringBuffer(); 
				for(int i = 0 ; i < shaData.length ; i++) {
					shasb.append(Integer.toString((shaData[i]&0xff) + 0x100, 16).substring(1));
				}
				encrypted = Base64Coder.encodeString(shasb.toString());

				break;
			default:
				
		}
				
		return encrypted;
	}
	
	/**
	 * 2022.10.18 (SHA-256으로 변경하는 것을 추천함)
	 * 대명소노시즌 암호화 방식 : 비밀번호를 대문자로 변경 후 MD5로 암호화
	 * @param password
	 * @return
	 * @throws NoSuchAlgorithmException
	 * @throws UnsupportedEncodingException
	 * @throws EnumerationNotFoundException
	 */
	public static String getEncryptedUserPassword(String password) throws NoSuchAlgorithmException, UnsupportedEncodingException, EnumerationNotFoundException {
		String userPasswordEncryptMethod = PropertiesManager.getString("eversrm.userPassword.encryption.method", "MD5");
		System.err.println(userPasswordEncryptMethod);
		return getEncrypted(OneWayAlgorithmType.fromString(userPasswordEncryptMethod), password);
	}

	@Test
	public void testGetEncryptedUserPassword() throws NoSuchAlgorithmException, EnumerationNotFoundException, UnsupportedEncodingException {
		System.err.println("1 : " + getEncryptedUserPassword("1"));
	}

	/**
	 * 복호화가 가능한 암호화방식으로, 암호화된 문자열을 리턴한다.
	 * @param algorithmType
	 * @param password
	 * @return
	 * @throws NoSuchAlgorithmException
	 */
	public static String getEncrypted(TwoWayAlgorithmType algorithmType, String password) throws NoSuchAlgorithmException {
		
//		Key key = getSecretKey(algorithmType);
//		byte[] passwordBytes = password.getBytes();
		
		switch(algorithmType) {
			case AES:

				break;
			case SEED:

				break;
			case TripleDES:

				break;
			default:
		}
		
		return "";
	}

	public static String getSafeDBEncryptedKey(Object key) throws Exception {

//		String safedbuserid = "SAFEPOLICY";
//		String table = "POLICY.POLICY_TB";
//		String col = "RRN_ENCR";
		String return_key = "";

		return return_key;
	}
	
	public static String getSafeDBEncryptedPasswordKey(Object key) throws Exception {

//		String safedbuserid = "SAFEPOLICY";
//		String table = "POLICY.POLICY_TB";
//		String col = "ONEWAY_ENCR";
		String return_key = "";

		return return_key;
	}	

	public static String getSafeDBDecryptedKey(String key) throws Exception {

//		String safedbuserid = "SAFEPOLICY";
//		String table = "POLICY.POLICY_TB";
//		String col = "RRN_ENCR";

		return key;
	}

	public static String getCardDecryptedKey(String cardNo) throws Exception{
		String DecryptedCardNo = "";
		String safeDBDecryptedCardNo = getSafeDBDecryptedKey(cardNo);
		DecryptedCardNo = safeDBDecryptedCardNo.substring(0, 4) + "-"
						+ safeDBDecryptedCardNo.substring(4, 8) + "-"
		//				+ safeDBDecryptedCardNo.substring(8, 12) + "-"
						+ "****" + "-"
						+ safeDBDecryptedCardNo.substring(12, safeDBDecryptedCardNo.length()) ;
		return DecryptedCardNo;
	}
	
	public static void getDBEncryptedColums(Map<String, String> param,String[] targetColumns) throws Exception{
		for(int j = 0 ; j < targetColumns.length ; j++){
			if(param.get(targetColumns[j]) != null && !"".equals(param.get(targetColumns[j])) && !" ".equals(param.get(targetColumns[j]))){
				param.put(targetColumns[j], getSafeDBEncryptedKey(param.get(targetColumns[j])));
			}
		}
	}

	public static void getDBEncryptedObjectColums(Map<String, Object> param,String[] targetColumns) throws Exception{
		for(int j = 0 ; j < targetColumns.length ; j++){
			if(param.get(targetColumns[j]) != null && !"".equals(param.get(targetColumns[j])) && !" ".equals(param.get(targetColumns[j]))){
				param.put(targetColumns[j], getSafeDBEncryptedKey(param.get(targetColumns[j])));
			}
		}
	}

	public static List<Map<String, Object>> getDBDecryptedList(List<Map<String, Object>> datas, String[] targetColumns) throws Exception{
		String data = "";
		String column = "";
		for(int i  = 0 ; i <  datas.size(); i ++){
			Map<String, Object> retrunData = datas.get(i);
			// 복호화 대상 컬럼 확인
			for(int j = 0 ; j < targetColumns.length ; j++){
				column = (String)retrunData.get(targetColumns[j]);
				if(!"".equals(column) && column != null && !" ".equals(column)){
					try{
					data = getSafeDBDecryptedKey((String)retrunData.get(targetColumns[j]));
					// 복호화시 
					if(!"".equals(data) && data != null)
						datas.get(i).put(targetColumns[j],data);
					} catch (Exception e) {
						datas.get(i).put(targetColumns[i], retrunData.get(targetColumns[j]));
					}						
				}
			}
		}
		return datas;
	}

	public static List<Map<String, String>> getDBDecryptedStringList(List<Map<String, String>> datas, String[] targetColumns) throws Exception{
		String data = "";
		String column = "";
		for(int i  = 0 ; i <  datas.size(); i ++){
			Map<String, String> retrunData = datas.get(i);
			// 복호화 대상 컬럼 확인
			for(int j = 0 ; j < targetColumns.length ; j++){
				column = retrunData.get(targetColumns[j]);
				if(!"".equals(column) && column != null && !" ".equals(column)){
					try{
					data = getSafeDBDecryptedKey(retrunData.get(targetColumns[j]));
					// 복호화시 
					if(!"".equals(data) && data != null)
						datas.get(i).put(targetColumns[j],data);
					} catch (Exception e) {
						datas.get(i).put(targetColumns[i], retrunData.get(targetColumns[j]));
					}						
				}
			}
		}
		return datas;
	}	

	public static Map<String, Object> getDBDecryptedInfo(Map<String, Object> data, String[] targetColumns) throws Exception{
		String column = "";
		String dataInfo = "";
		for(int i  = 0 ; i <  targetColumns.length; i ++){
			column = (String)data.get(targetColumns[i]);
			if(!"".equals(column) && column != null){
				try{
				dataInfo = getSafeDBDecryptedKey((String)data.get(targetColumns[i]));
				// 복호화시 
				if(!"".equals(dataInfo) && dataInfo != null)
					data.put(targetColumns[i],dataInfo);
				} catch (Exception e) {
					data.put(targetColumns[i], data.get(targetColumns[i]));
				}				
			}		
		}
		return data;
	}	

	public static Map<String, String> getDBDecryptedStringInfo(Map<String, String> data, String[] targetColumns) throws Exception{
		String column = "";
		String dataInfo = "";
		for(int i  = 0 ; i <  targetColumns.length; i ++){
			column = data.get(targetColumns[i]);
			if(!"".equals(column) && column != null){
				try{
				dataInfo = getSafeDBDecryptedKey(data.get(targetColumns[i]));
				// 복호화시 
				if(!"".equals(dataInfo) && dataInfo != null)
					data.put(targetColumns[i],dataInfo);					
				} catch (Exception e) {
					data.put(targetColumns[i], data.get(targetColumns[i]));
				}
			}		
		}
		return data;
	}	

//	private static Key getSecretKey(TwoWayAlgorithmType algorithmType) throws NoSuchAlgorithmException {
//		
//		SecretKey key = null;
//		switch(algorithmType) {
//			case AES:
//			case TripleDES:
//			case SEED:
//				
//				KeyGenerator keyGenerator = KeyGenerator.getInstance(algorithmType.toString());
//				key = keyGenerator.generateKey();
//				break;
//		}
//		
//		return key;
//	}

	public static Key retrunKey(String key) throws UnsupportedEncodingException  {
//      this.iv = key.substring(0, 16);
		byte[] keyBytes = new byte[16];
		byte[] b = key.getBytes("UTF-8");
		int len = b.length;
		if(len > keyBytes.length)
        	len = keyBytes.length;
		System.arraycopy(b, 0, keyBytes, 0, len);
		SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
		return keySpec;
	}
  
	// 암호화
	public static String aes256Encode(String key,String str) throws UnsupportedEncodingException, NoSuchAlgorithmException,
                                                   NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, 
                                                   IllegalBlockSizeException, BadPaddingException{
    	Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
      	c.init(Cipher.ENCRYPT_MODE, retrunKey(key), new IvParameterSpec(key.substring(0, 16).getBytes()));

      	byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));

		Base64.Encoder encoder = Base64.getEncoder();
		String enStr = new String(encoder.encode(str.getBytes()));

      	return enStr;
	}

	// 복호화
  	public static String aes256Decode(String key, String str) throws UnsupportedEncodingException, NoSuchAlgorithmException,
                                                   NoSuchPaddingException, InvalidKeyException, InvalidAlgorithmParameterException, 
                                                   IllegalBlockSizeException, BadPaddingException {

		if (str == null || "".equals(str)|| "null".equals(str)) {
			return "0";
	  	}

      	Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
      	c.init(Cipher.DECRYPT_MODE, retrunKey(key), new IvParameterSpec(key.substring(0, 16).getBytes("UTF-8")));

		Base64.Decoder decoder = Base64.getDecoder();
      	byte[] byteStr = decoder.decode(str.getBytes());
      	String numbers = new String(c.doFinal(byteStr),"UTF-8");

      	if (numbers.indexOf(".") > 0   && ".".equals( numbers.substring(numbers.indexOf("."), numbers.length()   )   )) {
    		numbers = numbers.replace(".", "");
      	}
		return numbers;
	}

	public static String encrypt(String key, String str) {
		Cipher cipher;
		byte[] keyBytes = new byte[16];

		try {
			byte[] b = key.getBytes("UTF-8");
			System.arraycopy(b, 0, keyBytes, 0, keyBytes.length);
			SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
			String ips = key.substring(0, 16);

			cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			cipher.init(Cipher.ENCRYPT_MODE, keySpec,
					new IvParameterSpec(ips.getBytes()));

			byte[] encrypted = cipher.doFinal(str.getBytes("UTF-8"));

			Base64.Encoder encoder = Base64.getEncoder();
			String Str = new String(encoder.encode(encrypted));

			return Str;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	public static String decrypt(String key, String str) {

		byte[] keyBytes = new byte[16];


		try {
			byte[] b = key.getBytes("UTF-8");
			System.arraycopy(b, 0, keyBytes, 0, keyBytes.length);
			SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");
			String ips = key.substring(0, 16);

			Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
			cipher.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(ips.getBytes("UTF-8")));

			Base64.Decoder decoder = Base64.getDecoder();
			byte[] byteStr = decoder.decode(str.getBytes());
			String Str = new String(cipher.doFinal(byteStr), "UTF-8");

			return Str;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

}
