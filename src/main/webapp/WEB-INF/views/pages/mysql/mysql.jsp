<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>MySQL 유저 관리</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f9f9f9;
            padding: 30px;
        }

        h2, h3 {
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }

        th, td {
            padding: 12px 15px;
            text-align: left;
        }

        th {
            background-color: #4CAF50;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        form {
            display: inline-block;
            margin: 0;
        }

        input[type="text"] {
            padding: 6px 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        button {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            margin-left: 5px;
            cursor: pointer;
            background-color: #2196F3;
            color: white;
        }

        button:hover {
            background-color: #1976D2;
        }

        .add-user-form {
            background-color: #fff;
            padding: 20px;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            max-width: 400px;
        }

        .add-user-form input[type="text"] {
            width: calc(100% - 100px);
        }
    </style>
</head>
<body>
    <h2>📋 유저 목록</h2>
    <table>
        <tr><th>ID</th><th>Name</th><th>수정</th><th>삭제</th></tr>
        <c:forEach var="u" items="${users}">
            <tr>
                <td>${u.id}</td>
                <td>
                    <form action="${pageContext.request.contextPath}/mysql/update" method="post">
                        <input type="hidden" name="id" value="${u.id}" />
                        <input type="text" name="name" value="${u.name}" />
                </td>
                <td>
                        <button type="submit">수정</button>
                    </form>
                </td>
                <td>
                    <form action="${pageContext.request.contextPath}/mysql/delete" method="post">
                        <input type="hidden" name="id" value="${u.id}" />
                        <button type="submit" style="background-color: #f44336;">삭제</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
    </table>

    <h3>➕ 새 유저 추가</h3>
    <form class="add-user-form" action="${pageContext.request.contextPath}/mysql/insert" method="post">
        <input type="text" name="name" placeholder="이름 입력" required />
        <button type="submit" style="background-color: #4CAF50;">추가</button>
    </form>
</body>
</html>
