<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/funding_complete.css">

<div class="funding-complete-container">
<div class="funding-complete-box">
    <h2>“<span>${fundingName}</span>” 등록 완료!</h2>

    <p>
        펀딩은 <strong>
        <fmt:formatDate value="${startDate}" pattern="yyyy년 M월 d일 '자정(밤 12시)'"/>
        </strong>부터 자동으로 시작됩니다.<br>
        이제 기다리기만 하면 돼요.
    </p>

    <div class="btn-group">
        <a href="${cpath}/seller/home" class="btn-filled">홈으로 가기</a>
    </div>
</div>
</div>