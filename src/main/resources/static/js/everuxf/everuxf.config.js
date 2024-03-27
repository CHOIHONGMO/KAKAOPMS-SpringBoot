/**
 * Copyright (c) 2013-2023 ST-Ones (http://www.st-ones.com/) All rights reserved.
 * @author ST-Ones Solution Dev Team
 */
var EVF = EVF || {};
EVF.Config = {

    search: {
        iconClickEventMode: ""
    },

    customDate: {
        separator: "-",
        format: {
            form: "yyyy-mm-mm",
            grid: "yyyy-mm-dd",
        }
    },

    excel: {
        import: {

        },
        export : {
            downloadFromServer: false,
            datetimeFormat: "yyyy-MM-dd"
        }
    },

    grid: {

        header: {
            height: 0,                      // 헤더 높이
            showTooltip: true,              // 헤더 툴팁 표시 여부
        },

        row: {
            height: 5,                      // 로우 높이
            showTooltip: false,             // 셀 툴팁 표시 여부
        },
    },

    user_custom: {
        screenId: 'ATTR01_020'              // ATTR01_020: 사용자별 컬럼 정의
    }
};