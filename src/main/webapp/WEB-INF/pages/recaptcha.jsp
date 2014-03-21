<%@ page import="net.tanesha.recaptcha.ReCaptcha" %>
<%@ page import="net.tanesha.recaptcha.ReCaptchaFactory" %>

<html>
<body>
<%
    ReCaptcha c = ReCaptchaFactory.newReCaptcha("6LfiYfASAAAAAJRj-lnARy1ZBA_BYT7i_yKL2wMo", "6LfiYfASAAAAAPhB4kqnU6S3GfBkmkLfaXN1V32f", false);
    out.print(c.createRecaptchaHtml(null, null));
%>
</body>
</html>