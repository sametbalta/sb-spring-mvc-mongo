<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="net.tanesha.recaptcha.ReCaptcha" %>
<%@ page import="net.tanesha.recaptcha.ReCaptchaFactory" %>
<html lang="tr">
<head>
    <meta charset="utf-8">
    <title>jQuery UI Dialog - Modal form</title>
    <script src="//code.jquery.com/jquery-1.9.0.js"></script>
    <script src="//code.jquery.com/jquery-migrate-1.2.1.js"></script>
    <script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
    <script src="http://cloud.github.com/downloads/digitalBush/jquery.maskedinput/jquery.maskedinput-1.3.min.js"
            type="text/javascript"></script>
    <script src="http://cdn.sencha.com/ext/gpl/4.2.0/ext-all.js" type="text/javascript"></script>
    <link href="http://cdn.sencha.io/ext/gpl/4.2.0/resources/css/ext-all-gray.css" rel="stylesheet"/>
    <style>
        #input-field input.text {
            margin-bottom: 12px;
            width: 95%;
            padding: .4em;
        }
    </style>
</head>
<body>

<form id="user-form" style="display: none">
    <fieldset id="input-field" style="border: none">
        <label for="firstName">First Name</label>
        <input type="text" name="firstName" id="firstName" class="text ui-widget-content ui-corner-all">
        <label for="lastName">Last Name</label>
        <input type="text" name="lastName" id="lastName" value="" class="text ui-widget-content ui-corner-all">
        <label for="phone">Phone Number</label>
        <input name="phone" id="phone" value="" class="text ui-widget-content ui-corner-all">
    </fieldset>
    <fieldset id="captcha-field" style="border: none">
        <%
            ReCaptcha c = ReCaptchaFactory.newReCaptcha("6LfiYfASAAAAAJRj-lnARy1ZBA_BYT7i_yKL2wMo", "6LfiYfASAAAAAPhB4kqnU6S3GfBkmkLfaXN1V32f", false);
            out.print(c.createRecaptchaHtml(null, null));
        %>
    </fieldset>
</form>

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

        var lastSelected = undefined;

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
                            lastSelected = undefined;
                            document.getElementById("user-form").reset(); //reset form
                            $('#captcha-field').show();
                            $("#user-form").dialog("open");
                        }
                    }
                ]
            },
            listeners: {
                itemdblclick: function (grid, record) {
                    lastSelected = record;
                    document.getElementById("user-form").reset(); //reset form
                    $('#captcha-field').hide();
                    $('#firstName').val(record.get('firstName'));
                    $('#lastName').val(record.get('lastName'));
                    $('#phone').val(record.get('phone'));
                    $("#user-form").dialog("open");
                }
            },
            renderTo: Ext.getBody()
        });

        $("#user-form").dialog({
            autoOpen: false,
            modal: true,
            title: 'New User',
            width: 400,
            buttons: {
                "Save": function () {

                    if (lastSelected == undefined) {

                        $.post('user/insert/',
                                $('form#user-form').serialize(),
                                function (data) {
                                    if (data.success) {
                                        $("#user-form").dialog("close");
                                        Ext.Msg.alert('Success', data.msg);
                                        //add new record to store
                                        store.add(data.user);
                                    } else {
                                        Ext.Msg.alert('Failure', data.msg);
                                    }
                                },
                                'json'
                        );
                    }
                    else {

                        $.post('user/update/' + lastSelected.get("id"),
                                $('form#user-form').serialize(),
                                function (data) {
                                    if (data.success) {
                                        $("#user-form").dialog("close");
                                        Ext.Msg.alert('Success', data.msg);

                                        var u = data.user;
                                        //updating record
                                        lastSelected.set('firstName', u.firstName);
                                        lastSelected.set('lastName', u.lastName);
                                        lastSelected.set('phone', u.phone);
                                    } else {
                                        Ext.Msg.alert('Failure', data.msg);
                                    }
                                },
                                'json'
                        );

                    }

                    event.preventDefault();
                },
                "Cancel": function () {
                    $(this).dialog("close");
                }
            }
        });

    });

    $("#phone").mask("(999) 999 99 99");
</script>

</body>
</html>