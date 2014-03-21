<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.tanesha.recaptcha.ReCaptcha" %>
<%@ page import="net.tanesha.recaptcha.ReCaptchaFactory" %>

<html>
<head>
    <title>Spring Mvc, MongoDb, Extjs</title>
    <script src="http://cdn.sencha.com/ext/gpl/4.2.0/ext-all.js" type="text/javascript"></script>
    <script src="http://code.jquery.com/jquery-1.7.2.min.js" type="text/javascript"></script>
    <script src="http://cloud.github.com/downloads/digitalBush/jquery.maskedinput/jquery.maskedinput-1.3.min.js"
            type="text/javascript"></script>
    <link href="http://cdn.sencha.io/ext/gpl/4.2.0/resources/css/ext-all-gray.css" rel="stylesheet"/>
</head>
<body>
<script>

Ext.define('User', {
    extend: 'Ext.data.Model',
    fields: [
        'id',
        'firstName',
        'lastName',
        'phone'
    ]
});


Ext.onReady(function () {

    var lastSeleceted = undefined;

    var store = Ext.create('Ext.data.Store', {
        model: 'User',
        autoLoad: 'true',
        proxy: {
            type: 'ajax',
            url: 'user',
            method: 'GET',
            reader: {
                type: 'json'
            }
        }
    });

    var form = Ext.create('Ext.form.Panel', {
        bodyPadding: 5,
        width: 450,
        layout: 'anchor',
        defaults: {
            anchor: '100350%'
        },
        viewConfig: {
            markDirty: false
        },

        defaultType: 'textfield',
        items: [
            {
                fieldLabel: 'First Name',
                allowBlank: false,
                name: 'firstName'
            },
            {
                fieldLabel: 'Last Name',
                allowBlank: false,
                name: 'lastName'
            },
            {
                fieldLabel: 'Telephone',
                name: 'phone',
                cls: 'phone-field',
                listeners: {
                    afterrender: function () {
                        $("#textfield-1012-inputEl").mask("(999) 999 99 99");
                    }
                }
            }/*,
            {
                xtype: 'box',
                width: 400,
                html: '<iframe src="recaptcha"></iframe>'
            }*/
        ],
        buttons: [
            {
                text: 'Reset',
                handler: function () {
                    this.up('form').getForm().reset();
                }
            },
            {
                text: 'Submit', //Submit Form
                formBind: true,
                handler: function () {
                    var form = this.up('form').getForm();
                    if (form.isValid()) {
                        var config;
                        if (lastSeleceted == undefined) {
                            config = {
                                method: "POST",
                                url: 'user/insert',
                                callback: function (form, action) {
                                    Ext.Msg.alert('Success', action.result.msg);
                                    //add new record to store
                                    store.add(action.result.user);
                                    win.close();
                                }
                            };
                        }
                        else {
                            config = {
                                method: "POST",
                                url: 'user/update/' + lastSeleceted.get("id"),
                                callback: function (form, action) {
                                    Ext.Msg.alert('Success', action.result.msg);
                                    var u = action.result.user;
                                    //updating record
                                    lastSeleceted.set('fistName', u.firstName);
                                    lastSeleceted.set('lastName', u.lastName);
                                    lastSeleceted.set('phone', u.phone);
                                    win.close();
                                }
                            };
                        }

                        form.submit({
                            method: config.method,
                            url: config.url,
                            params: config.extraParams,
                            success: config.callback,
                            failure: function (form, action) {
                                Ext.Msg.alert('Failed', Ext.decode(action.response.responseText).msg);
                            }
                        });
                    }
                }
            }
        ]
    });

    var win = Ext.create('Ext.window.Window', {
        title: 'User Form',
        layout: 'fit',
        autoShow: false,
        modal: true,
        closeAction: 'hide',
        items: [form]
    });

    Ext.Ajax.request({
        url: '/sb-spring-mvc-mongo/recaptcha',
        success: function (response) {
            win.update(response.responseText);
        }
    });

    Ext.create('Ext.grid.Panel', {
        store: store,
        id: 'user',
        title: 'User List',
        columns: [
            {
                header: 'FIRST NAME',
                dataIndex: 'firstName',
                flex: 1
            },
            {
                header: 'LAST NAME',
                dataIndex: 'lastName',
                flex: 1
            },
            {
                header: 'PHONE NUMBER',
                width: 75,
                dataIndex: 'phone',
                flex: 1
            },
            {
                xtype: 'actioncolumn',
                icon: 'http://www.iconsdb.com/icons/preview/color/666666/x-mark-m.png',
                tooltip: 'Delete',
                width: 30,
                handler: function (grid, rowIndex) {
                    var rec = store.getAt(rowIndex);
                    Ext.Msg.show({
                        title: 'Are You Sure?',
                        msg: rec.get('firstName') + ' ' + rec.get('lastName') + ' will be deleted from database.',
                        buttons: Ext.Msg.YESNO,
                        icon: Ext.Msg.QUESTION,
                        fn: function (btn, text) {
                            if (btn == 'yes') {
                                Ext.Ajax.request({
                                    url: 'user/' + rec.get('id'),
                                    method: 'DELETE',
                                    success: function (resp) {
                                        store.remove(rec);
                                        Ext.Msg.alert('Success', Ext.decode(resp.responseText).msg);
                                    },
                                    failure: function (resp) {
                                        Ext.Msg.alert('Failure', Ext.decode(resp.responseText).msg);
                                    }
                                });
                            }
                        }
                    });
                }
            }
        ],
        tbar: {
            xtype: 'toolbar',
            height: 72,
            items: [
                {
                    text: 'New User',
                    icon: 'http://www.iconsdb.com/icons/preview/color/666666/plus-6-m.png',
                    iconAlign: 'top',
                    scale: 'large',
                    handler: function () {
                        lastSeleceted = undefined;
                        form.getForm().reset();
                        win.show();
                    }
                }
            ]
        },
        listeners: {
            itemdblclick: function (grid, record) {
                lastSeleceted = record;
                form.getForm().loadRecord(record);
                win.show();
            }
        },
        renderTo: Ext.getBody()
    });

});
</script>
</body>
</html>
