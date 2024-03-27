package com.st_ones.filter;


import com.st_ones.everf.serverside.web.wrapper.EverHttpRequest;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;

import java.io.IOException;

public final class RequestWrapper extends EverHttpRequest {

    public RequestWrapper(HttpServletRequest servletRequest) throws IOException,ServletException {
        super(servletRequest);
    }

    public String[] getParameterValues(String parameter) {

      String[] values = super.getParameterValues(parameter);
      if (values==null)  {
                  return null;
          }
      int count = values.length;
      String[] encodedValues = new String[count];
      for (int i = 0; i < count; i++) {
                 encodedValues[i] = cleanXSS(values[i]);
       }
      return encodedValues;
    }

    public String getParameter(String parameter) {
          String value = super.getParameter(parameter);
          if (value == null) {
                 return null;
                  }
          return cleanXSS(value);
    }

    public String getHeader(String name) {
        String value = super.getHeader(name);
        if (value == null)
            return null;
        return cleanXSS(value);

    }

    private String cleanXSS(String value) {
    	
        value = value.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");
        value = value.replaceAll("(?i)script", "ＪＡＶＡＳＣＲＩＰＴ");
        value = value.replaceAll("(?i)prompt", "ＰＲＯＭＰＴ");
        value = value.replaceAll("(?i)function", "ＦＵＮＣＴＩＱＮ");
        value = value.replaceAll("(?i)alert", "ＡＬＥＲＴ");
        //value = value.replaceAll("(?i)eval", "ＥＶＡＬ");
        //value = value.replaceAll("(?i)open", "ＯＰＥＮ");
        return value;
    }
}