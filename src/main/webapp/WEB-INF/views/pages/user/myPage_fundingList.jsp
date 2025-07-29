<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/common/mypage.css">

<c:forEach var="funding" items="${fundingList}">
  <div class="funding-item">
  
    <!-- 구매일 -->
    <div class="funding-purchasedAt">
     구매일: <fmt:formatDate value="${funding.purchasedAt}" pattern="yyyy-MM-dd"/>   
    </div>

    <!-- 이미지와 오른쪽 정보 영역 -->
    <div class="funding-main-row">
    
      <!-- 이미지 -->
      <div class="funding-image">
        <img src="${cpath}${funding.images[0].imageUrl}" alt="펀딩 이미지" />
      </div>

       <!-- 정보 영역 -->
      <div class="funding-info">
      
        <!-- 상단: 펀딩명 + 기간 + 상태 -->
        <div class="funding-top-row">
          <div class="funding-title">${funding.fundingName}</div>
          <div class="funding-period">
            <fmt:formatDate value="${funding.startDate}" pattern="yyyy-MM-dd"/> ~ 
            <fmt:formatDate value="${funding.endDate}" pattern="yyyy-MM-dd"/>
          </div>
          <div class="funding-status">${funding.status}</div>
        </div>

        <!-- 하단: 주소 -->
        <div class="funding-address">${funding.storeAddress}</div>
      </div>
    </div>
  </div>
</c:forEach>
