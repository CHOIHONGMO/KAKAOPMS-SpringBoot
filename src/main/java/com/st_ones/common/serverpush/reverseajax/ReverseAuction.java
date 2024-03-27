package com.st_ones.common.serverpush.reverseajax;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.directwebremoting.Browser;
import org.directwebremoting.ScriptSessions;
import org.directwebremoting.annotations.RemoteProxy;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Map;

//import com.st_ones.eversrm.solicit.rAuction.rAuctionMgt.SSOR_Mapper; 

@Service
@RemoteProxy
public class ReverseAuction {

	public void clientCall() throws IOException {
//		setData(null, null);
	}

	@SuppressWarnings("rawtypes")
	public void pushData(Map auctionData) throws IOException {

		final String auctionDataString = new ObjectMapper().writeValueAsString(auctionData);
		Browser.withAllSessions(new Runnable() {
			public void run() {
				ScriptSessions.addFunctionCall("serverPushCallback", auctionDataString);
			}
		});
	}
}
