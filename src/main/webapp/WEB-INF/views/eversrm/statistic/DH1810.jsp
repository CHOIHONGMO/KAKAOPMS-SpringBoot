<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="e" uri="http://www.st-ones.com/eversrm" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<e:ui locale="${ses.countryCd}" lang="${ses.langCd}" dateFmt="${ses.dateFormat}">
    <script src="/js/ever-chart.js"></script>
    <script>

        var baseUrl = '/eversrm/statistic';
        var selRow;

        function init() {
            doSearch();
        }

        // Search
        function doSearch() {

            var store = new EVF.Store();
            if (!store.validate()) return;
            store.load(baseUrl + '/DH1810/doSearch', function () {

                var chartObj = JSON.parse(this.getParameter("chartObj"));
                // ID, 차트타입, 차트명, 값, 싱글/멀티 여부
                var option = {
                    'chartType': 'type',
                    'chartNm': 'column',
                    'singleFlag': true, // single 여부가 false 이면 multi 동작
                    'max': 10,
                    'min': 1,
                    'maxColor': '#ff0000',
                    'minColor': '#0054ff',
                    'leftyNm' : 'LEFT',
                    'RightyNm': '군내',
                    'widhtSize' : 61
                };

                chart.makeHighChart_CombiCharts('Histogram #1','highChart', chartObj, 'column', 'spline', option);  //왼쪽 Y축 타입, 오른쪽 Y축 타입 필수 넘겨줄것.

            });


        }

    </script>

    <e:window id="DH1810" onReady="init" initData="${initData}" title="${fullScreenName}" breadCrumbs="${breadCrumb }">

        <e:panel id="TOP" width="100%">
            <e:panel id="T1" width="270px">
                <e:searchPanel id="form" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%">
                    <br><br>
                    <e:row>
                        <e:field colSpan="2" align="center">
                            <e:text style="font-weight: bold;">공정 데이터</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T1" title="${form_T1_N}" />
                        <e:field>
                            <e:text>11.5</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2" title="${form_T2_N}" />
                        <e:field>
                            <e:text>12</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T3" title="규격 상한" />
                        <e:field>
                            <e:text>12.5</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T4" title="표본 평균" />
                        <e:field>
                            <e:text>11.956</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T4" title="표본 N" />
                        <e:field>
                            <e:text>125</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T4" title="표준 편차(군내)" />
                        <e:field>
                            <e:text>0.0938291</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T4" title="표준 편차(전체)" />
                        <e:field>
                            <e:text>0.0945277</e:text>
                        </e:field>
                    </e:row>
                </e:searchPanel>
            </e:panel>

            <e:panel id="Chart" width="750px">
                <div id="highChart" style="width: 99%; height: 99%;"></div>

            </e:panel>


            <e:panel id="T2" width="270px">
                <e:searchPanel id="form2" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%">
                    <e:row>
                        <e:field colSpan="2" align="center">
                            <e:text style="font-weight: bold;">잠재적(군내) 공정 능력</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_1" title="Cp" />
                        <e:field>
                            <e:text>1.78</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_2" title="CPL" />
                        <e:field>
                            <e:text>1.62</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_3" title="CPU" />
                        <e:field>
                            <e:text>1.93</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_4" title="Cpk" />
                        <e:field>
                            <e:text>1.62</e:text>
                        </e:field>
                    </e:row>
                </e:searchPanel>

                <e:searchPanel id="form4" useTitleBar="false" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%">
                    <br>
                    <e:row>
                        <e:field colSpan="2" align="center">
                            <e:text style="font-weight: bold;">전체 공정 능력</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_5" title="Pp" />
                        <e:field>
                            <e:text>1.76</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_6" title="PPL" />
                        <e:field>
                            <e:text>1.61</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_7" title="PPU" />
                        <e:field>
                            <e:text>1.92</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_8" title="Ppk" />
                        <e:field>
                            <e:text>1.61</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T2_9" title="Cpm" />
                        <e:field>
                            <e:text>1.60</e:text>
                        </e:field>
                    </e:row>
                </e:searchPanel>
            </e:panel>
        </e:panel>


        <br>

        <e:panel id="BOTTON" width="100%">
            <e:panel id="T3" width="240px">
                <e:searchPanel id="form5" useTitleBar="true" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%">
                    <e:row>
                        <e:field colSpan="2" align="center">
                            <e:text style="font-weight: bold;">관측 성능</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T3_1" title="PPM < 규격 하한" />
                        <e:field>
                            <e:text>0.00</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T3_2" title="PPM > 규격 상한" />
                        <e:field>
                            <e:text>0.00</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T3_3" title="PPM 총계" />
                        <e:field>
                            <e:text>0.00</e:text>
                        </e:field>
                    </e:row>
                </e:searchPanel>
            </e:panel>
            <e:panel id="blank1" width="20px">&nbsp; </e:panel>
            <e:panel id="T4" width="240px">
                <e:searchPanel id="form6" useTitleBar="true" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%">
                    <e:row>
                        <e:field colSpan="2" align="center">
                            <e:text style="font-weight: bold;">기대 성능(군내)</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T4_1" title="PPM < 규격 하한" />
                        <e:field>
                            <e:text>0.59</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T4_2" title="PPM > 규격 상한" />
                        <e:field>
                            <e:text>0.00</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T4_3" title="PPM 총계" />
                        <e:field>
                            <e:text>0.59</e:text>
                        </e:field>
                    </e:row>
                </e:searchPanel>
            </e:panel>
            <e:panel id="blank2" width="20px">&nbsp; </e:panel>
            <e:panel id="T5" width="240px">
                <e:searchPanel id="form7" useTitleBar="true" title="${form_CAPTION_N }" labelWidth="${labelWidth}" width="100%">
                    <e:row>
                        <e:field colSpan="2" align="center">
                            <e:text style="font-weight: bold;">기대 성능(전체)</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T5_1" title="PPM < 규격 하한" />
                        <e:field>
                            <e:text>0.70</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T5_2" title="PPM > 규격 상한" />
                        <e:field>
                            <e:text>0.00</e:text>
                        </e:field>
                    </e:row>
                    <e:row>
                        <e:label for="T5_3" title="PPM 총계" />
                        <e:field>
                            <e:text>0.71</e:text>
                        </e:field>
                    </e:row>
                </e:searchPanel>
            </e:panel>
        </e:panel>





    </e:window>
</e:ui>
