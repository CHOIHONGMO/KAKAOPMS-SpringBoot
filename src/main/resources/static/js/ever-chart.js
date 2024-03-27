/**
 * @class
 * @constructor
 * @desc Chart API
 * @since 1.0.0
 */
var chart = function() {};

/**
 * @desc Chart를 생성한다.
 * @this {EVF.Check}
 * @returns {boolean}
 */
chart.makeHighChart_Column = function(id, obj, option) {

    var categories = [];
    var dataSet = [];
    var datas = [];
    var data;
    //var colNames = [];
    var xAxis = {};

    // 선택 된 차트의 갯수만큼 돌면서 value 값을 받아온다.
    $.each(obj, function (k, v) {

        var cnt = 0;

        $.each(v, function (k2, v2) {

            if(cnt == 0) {
                // 반복문을 돌면서 X 축 categorie를 담는다.
                categories.push(v2);

                data = [];
                // colNames = new Array();
            } else {
                // 데이터 값을 담는다.
                data.push(v2);
                // colNames.push(k2);
            }

            cnt++;
        });
        datas.push(data);
    });

    // 싱글 컬러, 멀티컬러 지정
    var singleColor = [];
    var multiColor = ['#7cb5ec', '#434348', '#90ed7d', '#f7a35c', '#8085e9', '#f15c80', '#e4d354', '#2b908f', '#f45b5b', '#91e8e1'];

    for(var i in categories) {

        // single Chart true 일 경우 동작
        if(option.singleFlag) {
            // Single 데이터는 X 축 값과
            dataSet.push([categories[i], datas[i][0]]);

            // x 축 설정 type 디폴트 category
            xAxis = {"type": "category", "crosshair": true};

            // Color Setting
            var defaultColor = '#7cb5ec';
            var colorMaxMin = parseInt(i) + 1;

            if(colorMaxMin == option.min) {
                singleColor.push(option.minColor);
            } else if(colorMaxMin == option.max) {
                singleColor.push(option.maxColor);
            } else {
                singleColor.push(defaultColor);
            }
        // single Chart false 일 경우 동작
        } else {
            dataSet.push({"name:": categories[i], "data": datas[i], tooltip: {valueSuffix: ""}});

            // x 축 설정 categories 값 셋팅
            xAxis = {"categories" : categories, "crosshair": true};
        }
    }

    var singleData = [{'name': '', 'colorByPoint': true, 'data': dataSet}];

    // chartType
    var chart = [];
    chart[option.chartType] = option.chartNm;
    var chartObj = $.extend({}, chart);

    $('#'+id).highcharts({
        colors: option.singleFlag ? singleColor : multiColor,
        title: {
            text: EVF.componentManager.getWindow().title,
            x: -20
        },
        subtitle: {
            text: "",
            x: -20
        },
        xAxis: xAxis,
        yAxis: [{
            title: {
                text: ''
            },
            labels: {
                format: '{value} $'
            }
        }],
        tooltip: {
            shared: true // 한 로우에 여러 컬럼의 값을 표시
        },
        legend: {
            enabled : false
        },
        series: option.singleFlag ? singleData : dataSet,
        chart: chartObj
    });

    /*chart: {
        type: chartType,
            events: {
            load: function () {
                var chart = $("#highChart_"+that.gridID).highcharts();
                $.each(chart.series, function () {
                    // Row의 컬럼 색상 변경
                    /!*var index = that._gvo.getCurrent();
                     var col = that._gvo.columnByField(index.fieldName);
                     col.styles = { background: this.color.replace("#", "#39") };
                     that._gvo.setColumn(col);*!/
                });
            },
            click: function (e) {
                console.log(e);
            }
        }
    }*/
};

/**
 * @desc Chart를 생성한다.
 * @this {EVF.Check}
 * @returns {boolean}
 */
chart.makeHighChart_LineCharts = function(id, obj, option) {

    var categories = [];
    var dataSet = [];
    var datas = [];
    var data;
    //var colNames = [];
    var xAxis = {};
    var singleColor = [];

    // 선택 된 차트의 갯수만큼 돌면서 value 값을 받아온다.
    $.each(obj, function (k, v) {

        var cnt = 0;

        $.each(v, function (k2, v2) {

            if(cnt == 0) {
                // 반복문을 돌면서 X 축 categorie를 담는다.
                categories.push(v2);

                data = [];
                // colNames = new Array();
            } else {
                // 데이터 값을 담는다.
                data.push(v2);
                // colNames.push(k2);
            }

            cnt++;
        });
        datas.push(data);
    });

    for(var i in categories) {

    	// Single 데이터는 X 축 값과
        dataSet.push([datas[i][0]]);

        // x 축 설정 type 디폴트 category
        xAxis = { "categories": categories, "crosshair": true };

        // Color Setting
        var defaultColor = '#7cb5ec';
        var colorMaxMin = parseInt(i) + 1;

        if(colorMaxMin == option.min) {
            singleColor.push(option.minColor);
        } else if(colorMaxMin == option.max) {
            singleColor.push(option.maxColor);
        } else {
            singleColor.push(defaultColor);
        }
    }

    var singleData = [{'name': '', 'data': dataSet}];

    // chartType
    var chart = [];
    chart[option.chartType] = option.chartNm;

    $('#'+id).highcharts({
    	title: {
            text: option.title,
            align: 'center',
            style: {color: '#333366', fontSize: '24px', fontWeight: 'bold'},
            x: -20
        },
    	chart: {
            type: 'line',
            zoomType: 'x',
            backgroundColor: 'rgb(255, 255, 255)'
        },
    	subtitle: {
            text: "",
            x: -20
        },
        xAxis: xAxis,
        yAxis: {
        	min: option.yMin,
            max: option.yMax,
        	title: {
                text: ''
            },
            plotLines: [{
                value: option.maxVal,
                width: 1.5,
                color: '#666633',
                dashStyle: 'Solid'
            },{
                value: option.avgVal,
                width: 1,
                color: '#000099',
                dashStyle: 'LongDash'
            }]
        },
        tooltip: {
        	valueSuffix: ''
        },
        legend: '',
        series: singleData
    });
};


/**
 * @desc Chart를 생성한다.
 * @this {EVF.Check}
 * @returns {boolean}
 */
chart.makeHighChart_xBarCharts = function(id, obj, option) {

    var categories = [];
    var dataSet = [];
    var datas = [];
    var data;
    //var colNames = [];
    var xAxis = {};
    var singleColor = [];

    // 선택 된 차트의 갯수만큼 돌면서 value 값을 받아온다.
    $.each(obj, function (k, v) {

        var cnt = 0;

        $.each(v, function (k2, v2) {

            if(cnt == 0) {
                // 반복문을 돌면서 X 축 categorie를 담는다.
                categories.push(v2);

                data = [];
                // colNames = new Array();
            } else {
                // 데이터 값을 담는다.
                data.push(v2);
                // colNames.push(k2);
            }

            cnt++;
        });
        datas.push(data);
    });

    var xMax = eval(option.xMax);

    for(var i in categories) {

    	// Single 데이터는 X 축 값과
        dataSet.push([datas[i][0]]);

        // x 축 설정 type 디폴트 category
        xAxis = { max: xMax, "categories": categories, "crosshair": true };

        // Color Setting
        var defaultColor = '#7cb5ec';
        var colorMaxMin = parseInt(i) + 1;

        if(colorMaxMin == option.min) {
            singleColor.push(option.minColor);
        } else if(colorMaxMin == option.max) {
            singleColor.push(option.maxColor);
        } else {
            singleColor.push(defaultColor);
        }
    }

    var singleData = [{'name': option.yBarTitle, 'data': dataSet, 'color': '#FF6666'}];

    // chartType
    var chart = [];
    chart[option.chartType] = option.chartNm;

    $('#'+id).highcharts({
    	title: {
            text: option.title,
            align: 'center',
            style: {color: '#333366', fontSize: '24px', fontWeight: 'bold'},
            x: -20
        },
        subtitle: {
            text: "",
            x: -20
        },
        xAxis: xAxis,
        yAxis: {
            min: option.yMin,
            max: option.yMax,
        	title: {
                text: ''
            },
            plotLines: [{
                value: option.maxVal,
                width: 1.5,
                color: '#666633',
                dashStyle: 'Solid'
            },{
                value: option.avgVal,
                width: 1.5,
                color: '#000099',
                dashStyle: 'LongDash'
            },{
                value: option.minVal,
                width: 1.5,
                color: '#6666FF',
                dashStyle: 'Solid'
            }]
        },
        tooltip: {
        	valueSuffix: ''
        },
        legend: '',
        series: singleData
    });
};


/**
 * @desc Chart를 생성한다.
 * @this {EVF.Check}
 * @returns {boolean}
 */
chart.makeHighChart_rCharts = function(id, obj, option) {

    var categories = [];
    var dataSet = [];
    var datas = [];
    var data;
    //var colNames = [];
    var xAxis = {};
    var singleColor = [];

    // 선택 된 차트의 갯수만큼 돌면서 value 값을 받아온다.
    $.each(obj, function (k, v) {

        var cnt = 0;

        $.each(v, function (k2, v2) {

            if(cnt == 0) {
                // 반복문을 돌면서 X 축 categorie를 담는다.
                categories.push(v2);

                data = [];
                // colNames = new Array();
            } else {
                // 데이터 값을 담는다.
                data.push(v2);
                // colNames.push(k2);
            }

            cnt++;
        });
        datas.push(data);
    });

    var xMax = eval(option.xMax);

    for(var i in categories) {

    	// Single 데이터는 X 축 값과
        dataSet.push([datas[i][0]]);

        // x 축 설정 type 디폴트 category
        xAxis = { max: xMax, "categories": categories, "crosshair": true };

        // Color Setting
        var defaultColor = '#7cb5ec';
        var colorMaxMin = parseInt(i) + 1;

        if(colorMaxMin == option.min) {
            singleColor.push(option.minColor);
        } else if(colorMaxMin == option.max) {
            singleColor.push(option.maxColor);
        } else {
            singleColor.push(defaultColor);
        }
    }

    var singleData = [{'name': option.yBarTitle, 'data': dataSet, 'color': '#003366'}];

    // chartType
    var chart = [];
    chart[option.chartType] = option.chartNm;

    var yMin = option.yMin;
    var yMax = option.yMax;

    $('#'+id).highcharts({
    	title: {
            text: option.title,
            align: 'center',
            style: {color: '#333366', fontSize: '24px', fontWeight: 'bold'},
            x: -20
        },
        subtitle: {
            text: "",
            x: -20
        },
        xAxis: xAxis,
        yAxis: {
            min: yMin,
            max: yMax,
        	title: {
                text: ''
            },
            plotLines: [{
                value: option.maxVal,
                width: 1.5,
                color: '#336600',
                dashStyle: 'Solid'
            },{
                value: option.avgVal,
                width: 1.5,
                color: '#000099',
                dashStyle: 'LongDash'
            }]
        },
        tooltip: {
        	valueSuffix: ''
        },
        legend: '',
        series: singleData
    });
};


/**
 * @desc Chart를 생성한다.
 * @this {EVF.Check}
 * @returns {boolean}
 */
chart.makeHighChart_xbarRcharts = function(id, obj, option) {

    var categories = [];
    var dataSet = [];
    var datas = [];
    var data;
    //var colNames = [];
    var xAxis = {};
    var singleColor = [];

    // 선택 된 차트의 갯수만큼 돌면서 value 값을 받아온다.
    $.each(obj, function (k, v) {

        var cnt = 0;

        $.each(v, function (k2, v2) {

            if(cnt == 0) {
                // 반복문을 돌면서 X 축 categorie를 담는다.
                categories.push(v2);

                data = [];
                // colNames = new Array();
            } else {
                // 데이터 값을 담는다.
                data.push(v2);
                // colNames.push(k2);
            }

            cnt++;
        });
        datas.push(data);
    });

    var xMax = eval(option.xMax);

    for(var i in categories) {

    	// Single 데이터는 X 축 값과
        dataSet.push([datas[i][0]]);

        // x 축 설정 type 디폴트 category
        xAxis = { max: xMax, "categories": categories, "crosshair": true };

        // Color Setting
        var defaultColor = '#7cb5ec';
        var colorMaxMin = parseInt(i) + 1;

        if(colorMaxMin == option.min) {
            singleColor.push(option.minColor);
        } else if(colorMaxMin == option.max) {
            singleColor.push(option.maxColor);
        } else {
            singleColor.push(defaultColor);
        }
    }

    var singleData = [{'name': option.yBarTitle, 'data': dataSet, 'color': '#003366'}];

    // chartType
    var chart = [];
    chart[option.chartType] = option.chartNm;

    var yMin = option.yMin;
    var yMax = option.yMax;

    $('#'+id).highcharts({
    	title: {
            text: option.title,
            align: 'center',
            style: {color: '#333366', fontSize: '24px', fontWeight: 'bold'},
            x: -20
        },
        subtitle: {
            text: "",
            x: -20
        },
        xAxis: xAxis,
        yAxis: {
            min: yMin,
            max: yMax,
        	title: {
                text: ''
            },
            plotLines: [{
                value: option.maxVal,
                width: 1.5,
                color: '#CC0000',
                dashStyle: 'Solid'
            },{
                value: option.avgVal,
                width: 1.5,
                color: '#99CC00',
                dashStyle: 'Solid'
            },{
                value: option.minVal,
                width: 1.5,
                color: '#CC0000',
                dashStyle: 'Solid'
            }]
        },
        tooltip: {
        	valueSuffix: ''
        },
        legend: '',
        series: singleData
    });
};


/**
 * @desc MULTI Chart를 생성한다. (line + column)
 * @this {EVF.Check}
 * @returns {boolean}
 */
chart.makeHighChart_CombiCharts = function(name, id, obj, LType, RType, option) {

    var categories = [];
    var dataSetL = [];
    var dataSetR = [];
    var datas = [];
    var data;
    var xAxis = {};
    var singleColor = [];

    // 선택 된 차트의 갯수만큼 돌면서 value 값을 받아온다.
    //obj만큼 for 문 :(행의갯수)
    $.each(obj, function (k, v) {

        var cnt = 0;

        //그안의 object만큼 for문
        $.each(v, function (k2, v2) {

            if(cnt == 0) {
                // 반복문을 돌면서 X 축 categorie를 담는다.
                categories.push(v2);
                data = [];
                // colNames = new Array();
            } else {
                // 데이터 값을 담는다.
                data.push(v2);
                // colNames.push(k2);
            }

            cnt++;
        });
        datas.push(data);
    });


    //x축만큼 for
    for(var i in categories) {

        dataSetL.push([datas[i][0]]);  //left
        dataSetR.push([datas[i][1]]);  //right

        //x축 데이터
        xAxis = [{"categories": categories, "crosshair": true}];

        // Color Setting
        var defaultColor = '#7cb5ec';
        var colorMaxMin = parseInt(i) + 1;

        if(colorMaxMin == option.min) {
            singleColor.push(option.minColor);
        } else if(colorMaxMin == option.max) {
            singleColor.push(option.maxColor);
        } else {
            singleColor.push(defaultColor);
        }
    }

    //y축 데이터
    var singleDataL = {'name': option.leftyNm, 'type': LType, 'yAxis': 1, 'data': dataSetL};
    var singleDataR = {'name': option.RightyNm, 'type': RType, 'data': dataSetR};

    // chartType
    var chart = [];
    chart[option.chartType] = option.chartNm;

    $('#'+id).highcharts({
        chart: {
            zoomType: 'xy',
            backgroundColor: 'rgb(255, 255, 255)'
        },
        title: {
            text: EVF.componentManager.getWindow().title,
            x: -20
        },
        subtitle: {
            text: "",
            x: -20
        },
        xAxis: xAxis,
        yAxis: [{ // Primary yAxis
            labels: {
                format: '{value}'
            },

            title: {
                text: option.leftyNm
            }
        }, { // Secondary yAxis
            title: {
                text: option.RightyNm
            },
            labels: {
                format: '{value}'
            },
            opposite: true
        }],

        tooltip: {
            shared: true
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'middle',
            borderWidth: 0
        },
        plotOptions: {
            series: {
                pointWidth: option.widhtSize
            }
        },
        series: [singleDataL,singleDataR]
    });

};
