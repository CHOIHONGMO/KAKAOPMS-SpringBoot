package com.st_ones.common.util.clazz;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 11. 20 오후 3:28
 */

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class RunCommand {

	/**
	 * 콘솔 명령어 실행
	 * excute console command
	 * @param cmd
	 * @return C:\Users\Administrator\Downloads
	 * @throws IOException
	 */
	Escape escape = new Escape();
	
	public static String runCommand(String cmd) throws IOException {
		Escape.setEscape(cmd);
		Process p = Runtime.getRuntime().exec(cmd);
		InputStream in = p.getInputStream();
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		String s = "";
		String temp = "";

		while ((temp = br.readLine()) != null) {
			s += (temp + "n");
		}

		br.close();
		in.close();
		return s;
	}
}
