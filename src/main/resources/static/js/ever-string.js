/**
 * Object everString() 일반적인 Util을 제공 합니다.
 * general Util
 *
 * @constructor
 * @extends Object
 */
var everString = function() {
};

everString.contains = function(str, it){
    return str.indexOf(it) != -1;
};
/**
 * replaceAll
 * @param str
 * @param src
 * @param target
 * @returns replaced String
 */
everString.replaceAll = function (str, src, target) {
    str = str.split(src).join(target);
    return str;
};

/**
 * right trim
 * @param str
 * @returns {String}
 */
everString.rTrim = function (str) {
    return str.replace(/^\s+/,'');
};

/**
 * left trim
 *
 * @param {String}
 *            str
 * @returns {String}
 */
everString.lTrim = function (str) {
    return str.replace(/\s+$/,'');
};

/**
 * lrTrim
 * @param str
 * @returns {String}
 */
everString.lrTrim = function (str) {
    return str.replace(/^\s+/,'').replace(/\s+$/,'');
};

/**
 * Determine whether the number string
 * @param num
 * @returns {Boolean}
 */
everString.isNumber = function (num) {
    var pattern = /^\d+$/;
    return pattern.test(num);
};

/**
 * trim left 0 character
 * @param str
 * @returns {String}
 */
everString.zero_LTrim = function (str) {
    return str.replace(/^0+/g, '');
};

/**
 * delete ch in str
 * @param str
 * @param ch
 * @returns replaced
 */
everString.deleteChar = function (str, ch) {
    return everString.replaceAll(str, ch, '');
};

/**
 * hsaSpace
 * @param str
 * @returns boolean
 */
everString.hsaSpace = function (str) {
    return /\s/g.test(str);
};


/**
 * isEmpty
 * @param str
 * @returns {Boolean}
 */
everString.isEmpty = function (str) {
    return str === undefined || str === null || str === '';
};

everString.isEmptyNum = function (str) {
    return str === undefined || str === null || str === '0' || str === 0;
};


everString.isNotEmpty = function (str) {
    return !everString.isEmpty(str);
};


/**
 * check include korean
 * @param str
 * @returns {Boolean}
 */
everString.hasKoreanChar = function (str) {
    return /[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/.test(str);
};

/**
 * is tel number character
 * @param num
 * @returns {Boolean}
 */
everString.isTel = function (str) {
    var regTel1 = /^(15|16|18)[0-9]{2}-?[0-9]{4}$/;
    var regTel2 = /^(01[016789]{1}|02|0[3-9]{1}[0-9]{1})-?[0-9]{3,4}-?[0-9]{4}$/;

    if (!regTel1.test(str) && !regTel2.test(str)) {
        return false;
    }
    return true;
};

/**
 * isValidEmail
 * @param input
 * @returns regex
 */
everString.isValidEmail = function (input) {
    return /^((\w|[\-\.])+)@((\w|[\-\.])+)\.([A-Za-z]+)$/.test(input);
};

everString.setHyphenNo = function (str) {
    return str.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/,"$1-$2-$3");
}

/**
 * isIrsNo
 * @param input
 * @returns regex
 */
everString.isIrsNo = function(str) {
    var checkID = [1, 3, 7, 1, 3, 7, 1, 3, 5, 1];
    var i, chkSum = 0, c2, remainder;
    var irsNum = everString.lrTrim(str);
    irsNum = irsNum.replace(/-/gi, '');

    for (i = 0; i <= 7; i++)
        chkSum += checkID[i] * irsNum.charAt(i);
        c2 = "0" + (checkID[8] * irsNum.charAt(8));
        c2 = c2.substring(c2.length - 2, c2.length);
        chkSum += Math.floor(c2.charAt(0)) + Math.floor(c2.charAt(1));
        remainder = (10 - (chkSum % 10)) % 10;

    if (Math.floor(irsNum.charAt(9)) == remainder) {
        return true;
    } else {
        return false;
    }
}

/**
 * isValidHome
 * @param input
 */
everString.isValidHome = function (input) {
    return /^((\w|[\-\.])+).((\w|[\-\.])+)\.([A-Za-z]+)$/.test(input);
};

/**
 * isNumAndComma
 * @param str
 * @returns boolean
 */
everString.isNumAndComma = function (str) {
    return /^[\d|,]+$/.test(str);
};

/**
 * commaSet
 * @param str
 * @returns comnaText
 */

everString.commaSet = function (str) {
	
	return str.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
};

/**
 * getMessage
 * @param msg
 * @param obj
 * @returns message
 */
everString.getMessage = function(msg, obj) {
    return msg.replace('@', obj);
};

everString.format = function() {
    var str = arguments[0];
    for (var i = 1; i < arguments.length; i++) {
        str = everString.replaceAll(str, '{' + String(i-1) + '}', arguments[i]);
    }
    return str;
};

/**
 * sortBy 			- sort an array of JSON
 * @param field 	: field to sort
 * @param reverse 	: true - revesed order; false - normal order
 * @param primer 	: function for comparison
 * @returns sortIndex
 */
everString.sortBy = function(field, reverse, primer){
    var _reverse = reverse ? reverse : false;
    var _key = function (x) {return primer ? primer(x[field]) : x[field]};
    return function (a,b) {
        var A = _key(a), B = _key(b);
        return ((A < B) ? -1 : (A > B) ? +1 : 0) * (_reverse ? -1 : 1);
    };
};

/*
 * left 기준으로 자릿수 채울 때 사용 ex) everString.leftPad(value,'0',2)
 * 앞자리 0으로 채움
 */
everString.leftPad = function(str, fillChar, length) {

    if (fillChar.length != 1) {
        alert('fillChar must be a single character');
        return "";
    }

    if (str.length > length)
        return str;

    var returnStr = "";
    var i;
    for (i = str.length; i < length; i++) {
        returnStr = returnStr + fillChar;
    }

    returnStr = returnStr + str;

    return returnStr;
};

/*
 * right 기준으로 자릿수 채울 때 사용 ex) everString.rightPad(value,'0',2)
 * 뒷자리 0으로 채움
 */
everString.rightPad = function(str, fillChar, length) {

    if (fillChar.length != 1) {
        alert('fillChar must be a single character');
        return "";
    }

    if (str.length > length)
        return str;

    var returnStr = str;
    var i;
    for (i = str.length; i < length; i++) {
        returnStr = returnStr + fillChar;
    }

    return returnStr;
};

/*
 * Nan 여부를 파악하여 0이나 원래 값을 리턴한다.
 */
everString.isNanToZero = function(str) {
    if(isNaN(str) || !str || str === "NaN") {
        return 0;
    } else {
        return str;
    }
};