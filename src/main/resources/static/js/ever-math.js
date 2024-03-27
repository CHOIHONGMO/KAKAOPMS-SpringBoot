/**
 * /** Object everMath() Math에 관련된 Util을 제공 합니다.
 * Math related Util
 * @constructor
 * @extends Object
 */
var everCurrency = {
    price: { roundMode: {}, precision: {} },
    amount: { roundMode: {}, precision: {} },
    qty: { roundMode: {}, precision: {} }
};

everCurrency.price.roundMode.DEF = 'floor';
everCurrency.price.roundMode.KRW = 'floor';
everCurrency.price.roundMode.VND = 'floor';
everCurrency.price.roundMode.USD = 'floor';
everCurrency.price.precision.DEF = 2;
everCurrency.price.precision.KRW = 2;
everCurrency.price.precision.VND = 2;
everCurrency.price.precision.USD = 2;

everCurrency.amount.roundMode.DEF = 'floor';
everCurrency.amount.roundMode.KRW = 'floor';
everCurrency.amount.roundMode.VND = 'floor';
everCurrency.amount.roundMode.USD = 'floor';
everCurrency.amount.precision.DEF = 0;
everCurrency.amount.precision.KRW = 0;
everCurrency.amount.precision.VND = 0;
everCurrency.amount.precision.USD = 0;

everCurrency.qty.roundMode.DEF = 'floor';
everCurrency.qty.roundMode.KRW = 'floor';
everCurrency.qty.roundMode.VND = 'floor';
everCurrency.qty.roundMode.USD = 'floor';
everCurrency.qty.precision.DEF = 2;
everCurrency.qty.precision.KRW = 2;
everCurrency.qty.precision.VND = 2;
everCurrency.qty.precision.USD = 2;

everCurrency.getPrice = function (currency, value) {
    return everCurrency.getValue('price', currency, value);
};

everCurrency.getAmount = function (currency, value) {
    return everCurrency.getValue('amount', currency, value);
};

everCurrency.getQty = function (currency, value) {
    return everCurrency.getValue('qty', currency, value);
};

everCurrency.getValue = function (valueType, currency, value) {
    var roundMode = everCurrency.getCurrencyProperty(valueType, 'roundMode', currency);
    var precision = everCurrency.getCurrencyProperty(valueType, 'precision', currency);

    var convertMethod = everCurrency.getConvertMethod(roundMode);
    return convertMethod(value, precision);
};

everCurrency.getConvertMethod = function (roundMode) {
    if (roundMode === 'round') {
        return everMath.round_float;
    }
    if (roundMode === 'ceil') {
        return everMath.ceil_float;
    }
    if (roundMode === 'floor') {
        return everMath.floor_float;
    }
};

everCurrency.getCurrencyProperty = function (valueType, formatType, currency) {
    var value = everCurrency[valueType][formatType][currency];
    if (value === undefined) {
        value = everCurrency[valueType][formatType]['DEF'];
    }
    return value;
};

var everMath = function () {
};

/**
 * round_float
 * @param x
 * @param n
 * @returns
 */
everMath.round_float = function (x, n) {
    if (!parseInt(n)) {
        n = 0;
    }
    if (!parseFloat(x) && Number(x) !== 0) {
        return false;
    }
    return Math.round(x * Math.pow(10, n)) / Math.pow(10, n);
};

everMath.ceil_float = function (x, n) {
    if (!parseInt(n)) {
        n = 0;
    }
    if (!parseFloat(x) && Number(x) !== 0) {
        return false;
    }
    return Math.ceil(x * Math.pow(10, n)) / Math.pow(10, n);
};

everMath.floor_float = function (x, n) {
    if (!parseInt(n)) {
        n = 0;
    }
    if (!parseFloat(x) && Number(x) !== 0) {
        return false;
    }
    return Math.floor(x * Math.pow(10, n)) / Math.pow(10, n);
};

everMath.getamountbykrw = function (p_cur_code, p_cur_ratio, p_amount) {
    
	let krw_amount = p_amount * p_cur_ratio;
    return (Math.round(krw_amount * 100000) / 100000).toFixed(4);
};

everMath.getamountbycur = function (p_cur_code, p_cur_ratio, p_amount, p_tar_code, p_tar_ratio) {
    
	let krw_amount = p_amount   * p_cur_ratio;
	let cur_amount = krw_amount / p_tar_ratio;
    return (Math.round(cur_amount * 100000) / 100000).toFixed(4);
};
