/*
 Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
 For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function (config) {
    // Define changes to default configuration here. For example:
    // config.docType = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
    config.font_defaultLabel = '굴림';
    config.font_names = '굴림/Gulim;Dotum/Dotum;Batang/Batang;Gungsuh/Gungsuh;Arial/Arial;Tahoma/Tahoma;Verdana/Verdana;헤드라인/헤드라인;맑은 고딕/맑은 고딕;';
    config.fontSize_defaultLabel = '10';
    config.fontSize_sizes = '8/8px;9/9px;10/10px;11/11px;12/12px;13/13px;14/14px;16/16px;18/18px;20/20px;22/22px;24/24px;26/26px;28/28px;36/36px;48/48px;';
    config.defaultLanguage = "ko";
    config.language = "ko";
    config.contentsLanguage = "ko";
    config.contentsCss = 'ul { font-size:12px; margin-top: 0px; margin-bottom: 0px; list-style: none; padding: 0px; } li a { color: black; text-decoration: none; cursor: default; } td { font-size: 8pt; font-family:굴림; height:25px; }';
    config.lineheight_sizes = 'normal;80%;90%;100%;110%;120%;130%;140%;150%;160%;170%;180%;190%;200%;210%;220%;250%;300%;400%;500%';
    config.resize_enabled = false;
    config.forceEnterMode = false;
    config.startupFocus = false;
    config.removePlugins = 'elementspath';
    config.uiColor = '#f3f8fc';
    config.toolbarCanCollapse = false;
    config.menu_subMenuDelay = 0;
    config.forcePasteAsPlainText = false;
    config.allowedContent = true;
    config.removeButtons = 'Subscript,Superscript';
    config.toolbar = [
        { name: 'document', items: [ 'Bold','Italic','Underline','Strike','Table','Font','FontSize','lineheight','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','Preview', 'Print', 'Find', 'Maximize'] },
    ];
};