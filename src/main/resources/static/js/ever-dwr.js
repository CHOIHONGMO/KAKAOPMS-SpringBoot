/**
 * Object wiseDWR() Server Push와 관련된 Util을 제공 합니다.<br>
 * Date relate Util
 * 
 * @constructor
 * @extends Object
 */
var everDWR = function() {
};

everDWR.reverseAuction = function(pageParam, auctionData) {
	if(auctionData === undefined){
		return;
	}
	
	if (auctionData.rfxNo === pageParam.rfxNo && auctionData.rfxCnt === pageParam.rfxCnt) {
		pageParam.callbackFunction(auctionData.ranking[pageParam.userId],
				auctionData.currentLowPrice, auctionData.currentTime, auctionData.targetTime);
	}
};
