<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="/WEB-INF/views/common/init.jsp" %>

<link rel="stylesheet" type="text/css"
	href="${cpath}/resources/css/layout/sub-header.css">

<div class="box"></div>
<div class="header-box">
	<div class="logo" onclick="location.href='${cpath}/user/home'">
		<img src="${cpath}/resources/images/logo.svg" alt="logo" />
	</div>
	<div class="circle">
		<img src="${cpath}/resources/images/circle.svg" alt="circle" />
	</div>
	<div class="page-name">${pageName}</div>
</div>
