/*
 Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
 For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
    // Define changes to default configuration here. For example:
    // config.docType = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
    config.font_defaultLabel = '굴림';
    config.font_names = '굴림/Gulim;돋움/Dotum;바탕/Batang;궁서/Gungsuh;맑은 고딕/맑은 고딕;Arial/Arial;Tahoma/Tahoma;Verdana/Verdana;';
    config.fontSize_defaultLabel = '13';
    config.fontSize_sizes = '8/8px;9/9px;10/10px;11/11px;12/12px;13/13px;14/14px;16/16px;18/18px;20/20px;22/22px;24/24px;26/26px;28/28px;36/36px;48/48px;';
    config.defaultLanguage = "ko";
    config.language = "ko";
    config.contentsLanguage  = "ko";
    config.lineheight_sizes ='normal;80%;90%;100%;110%;120%;130%;140%;150%;160%;170%;180%;190%;200%;210%;220%;250%;300%;400%;500%';
    config.resize_enabled = false;
    config.forceEnterMode = false;
    config.startupFocus = false;
    config.extraPlugins = 'econtInfo';
    config.removePlugins = 'elementspath';
    config.uiColor = '#f3f8fc';
    config.toolbarCanCollapse = true;
    config.menu_subMenuDelay = 0;
    config.forcePasteAsPlainText = false;
    config.allowedContent = true;
    config.contentsCss = ["/js/everuxf/lib/ckeditor/default_contents.css"];
    config.toolbar = [
        ['Source','-','Preview'],
        ['PasteFromWord','NumberedList','BulletedList','-','Outdent','Indent'],
        ['JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
        ['Bold','Italic','Underline','Strike','Table', 'Styles','Format','Font','FontSize','lineheight','TextColor','BGColor'],
        ['PageBreak','Maximize', 'Print'],
        '/',
        ['defaultInfo', 'supplyInfo', 'buyerInfo']
    ];
    config.stylesSet = [
        { name: 'Input', element: 'input', styles: { 'background-color': '#ffd9ff', 'outline': '1px dashed #dc2c34', 'border': '0' } },
        { name: 'TextArea', element: 'textarea', styles: { 'background-color': '#ffd9ff', 'outline': '1px dashed #dc2c34', 'border': '0' } }
    ];
};