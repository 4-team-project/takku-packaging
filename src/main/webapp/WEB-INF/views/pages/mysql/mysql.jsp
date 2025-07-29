<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head><title>MySQL 테스트</title></head>
<body>
    <h1>MySQL Users</h1>
    <table border="1">
        <tr>
            <th>ID</th><th>Name</th>
        </tr>
        <c:forEach var="user" items="${users}">
            <tr>
                <td>${user.id}</td>
                <td>${user.name}</td>
            </tr>
        </c:forEach>
    </table>
</body>
</html>
