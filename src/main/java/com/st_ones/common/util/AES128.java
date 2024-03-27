package com.st_ones.common.util;

import com.st_ones.everf.serverside.config.PropertiesManager;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

/**
 * <pre>
 ****************************************************************************** 
 * 한진물류센터 데이터 함호화/복호화 유틸 정의
 * (Copyright ⓒ 2013 ST-ONES CORP., ALL RIGHTS RESERVED | Confidential)
 ****************************************************************************** 
 * </pre>
 * 
 * @author 이성민
 * @date 2017. 09. 04.
 * @version 1.0
 * @see
 */
public class AES128 {
	
	public static String key = PropertiesManager.getString("siis.aes128.key");


	public static byte[] hexToByteArray(String hex) {
		
		if ((hex == null) || (hex.length() == 0)) {			
			return null;			
		}

		byte[] ba = new byte[hex.length() / 2];

		for (int i = 0; i < ba.length; ++i) {			
			ba[i] = (byte) Integer.parseInt(hex.substring(2 * i, 2 * i + 2), 16);			
		}

		return ba;	
		
	}

	public static String byteArrayToHex(byte[] ba) {
		
		if ((ba == null) || (ba.length == 0)) {			
			return null;			
		}

		StringBuffer sb = new StringBuffer(ba.length * 2);

		for (int x = 0; x < ba.length; ++x) {			
			String hexNumber = "0" + Integer.toHexString(0xFF & ba[x]);			
			sb.append(hexNumber.substring(hexNumber.length() - 2));			
		}

		return sb.toString();

	}

	public static String encrypt(String message) throws Exception {
		
		if( message == null ) message = "";

		SecretKeySpec skeySpec = new SecretKeySpec(key.getBytes(), "AES");

		Cipher cipher = Cipher.getInstance("AES");
		
		cipher.init(1, skeySpec);

		byte[] encrypted = cipher.doFinal(message.getBytes());

		return byteArrayToHex(encrypted);

	}

	public static String decrypt(String encrypted) throws Exception {
		
		if( encrypted == null ) encrypted = "";

		SecretKeySpec skeySpec = new SecretKeySpec(key.getBytes(), "AES");

		Cipher cipher = Cipher.getInstance("AES");
		
		cipher.init(2, skeySpec);

		byte[] original = cipher.doFinal(hexToByteArray(encrypted));

		String originalString = new String(original);

		return originalString;

	}
	
}