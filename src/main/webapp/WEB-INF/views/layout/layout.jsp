<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<html>
<head>
<title><tiles:getAsString name="title" /></title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="icon" href="${cpath}/resources/images/favicon.ico" type="image/x-icon" />
</head>
<body>
	<div id="header">
		<tiles:insertAttribute name="header" />
	</div>
	<div class="container">
		<div id="content">
			<tiles:insertAttribute name="body" />
		</div>
	</div>
	<div id="footer">
			<tiles:insertAttribute name="footer" />
		</div>
</body>
</html>