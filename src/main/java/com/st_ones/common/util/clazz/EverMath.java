package com.st_ones.common.util.clazz;

/**
 * Copyright (c) 2013 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @LastModified 17. 11. 20 오후 3:28
 */

import java.math.BigDecimal;
import java.text.DecimalFormat;

public final class EverMath {
	public static double getRound(double paramDouble1, double paramDouble2) {
		if (paramDouble2 == 0.0D)
			return paramDouble1;
		if (paramDouble2 == 1.0D) {
			return Math.round(paramDouble1);
		}

		double d2 = Math.pow(10.0D, paramDouble2 - 1.0D);
		BigDecimal localBigDecimal = new BigDecimal(String.valueOf(paramDouble1)).multiply(new BigDecimal(String.valueOf(d2)));
		return (Math.round(localBigDecimal.doubleValue()) / d2);
	}

	public static double getCeil(double paramDouble1, double paramDouble2) {
		if (paramDouble2 == 0.0D)
			return paramDouble1;
		if (paramDouble2 == 1.0D) {
			return Math.ceil(paramDouble1);
		}

		double d2 = Math.pow(10.0D, paramDouble2 - 1.0D);
		BigDecimal localBigDecimal = new BigDecimal(String.valueOf(paramDouble1)).multiply(new BigDecimal(String.valueOf(d2)));
		return (Math.ceil(localBigDecimal.doubleValue()) / d2);
	}

	public static double getFloor(double paramDouble1, double paramDouble2) {
		if (paramDouble2 == 0.0D)
			return paramDouble1;
		if (paramDouble2 == 1.0D) {
			return Math.floor(paramDouble1);
		}

		double d2 = Math.pow(10.0D, paramDouble2 - 1.0D);
		BigDecimal localBigDecimal = new BigDecimal(String.valueOf(paramDouble1)).multiply(new BigDecimal(String.valueOf(d2)));
		return (Math.floor(localBigDecimal.doubleValue()) / d2);
	}

	public static String EverNumberType(double paramDouble, String paramString) {
		String str = "";
		DecimalFormat localDecimalFormat = new DecimalFormat(paramString);
		str = localDecimalFormat.format(paramDouble);
		return str;
	}

	public static String EverNumberType(String paramString1, String paramString2) {
		String str = "";
		try {
			double d2 = Double.parseDouble(paramString1);
			str = EverNumberType(d2, paramString2);
		} catch (NumberFormatException localNumberFormatException) {
			str = paramString1;
		}
		return str;
	}
}
