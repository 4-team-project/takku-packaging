<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="error-box" style="text-align: center; padding: 100px;">
    <h1 style="font-size: 32px; color: #FF9670;">⚠ 오류가 발생했습니다</h1>
    <p style="font-size: 18px; color: #555;">요청하신 페이지를 불러오는 중 문제가 발생했습니다.</p>
    <p style="font-size: 18px; color: #555;">잠시 후 다시 시도하거나, 홈으로 돌아가주세요.</p>
    <a href="${pageContext.request.contextPath}/" 
       style="display: inline-block; margin-top: 30px; padding: 10px 20px; 
              background-color: #FF9670; color: white; text-decoration: none; border-radius: 5px;">
       홈으로 가기
    </a>
</div>
