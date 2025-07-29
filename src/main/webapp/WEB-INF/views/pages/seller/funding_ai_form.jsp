<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/pages/seller/funding_ai_input.css" />
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 모달 스크립트 (AI 3회 초과 시) -->
<script>
	$(function() {
		const aiRetryCount = ${aiRetryCount};

		if (aiRetryCount >= 3) {
			$("#createAi").on("click", function (e) {
				e.preventDefault();
				$("#resultModal, #modalBackdrop").fadeIn();
			});
		}

		$("#closeModalBtn").on("click", function () {
			$("#resultModal, #modalBackdrop").fadeOut();
		});
	});
</script>

<div class="step-progress">
  <div class="step">
    <div class="circle">1</div>
    <div class="label">상품 정보</div>
  </div>
  <div class="line"></div>
  <div class="step">
    <div class="circle">2</div>
    <div class="label">기간 및 이미지</div>
  </div>
  <div class="line"></div>
  <div class="step active">
    <div class="circle">3</div>
    <div class="label">상세 내용</div>
  </div>
</div>

<form action="${cpath}/ai/ai-generate" method="post">
	<h3>
		<strong style="color: #ff9670">${product.productName}</strong> 메뉴는 어떤 느낌인가요? <br>
		<h2>(AI 자동 생성은 3회만 가능합니다!!)</h2>
	</h3>
	<p class="example">예: 푸짐한 한 끼, 집밥 느낌, 인기 메뉴</p>

	<div class="input-group">
		<input type="text" name="keywords" placeholder="떠오르는 단어를 적어주세요" required class="form-input" />
	</div>

	<div class="menu-label" name="fundingName">원하시는 타겟층을 입력해주세요.</div>
	<div class="input-group">
		<input type="text" name="target" placeholder="예: 20대 여성, 직장인, 커플" required class="form-input"/>
	</div>

	<div class="btn-group">
		<button class="btn" type="button" onclick="history.back()">이전</button>
		<button class="btn" type="submit" id="createAi">AI 생성</button>
	</div>
</form>

<!-- 모달 -->
<div id="resultModal">
	<p id="modalMsg">AI 생성 기회를 모두 사용하셨습니다.<br>더 이상 생성이 불가능합니다.</p>
	<button id="closeModalBtn">확인</button>
</div>

<!-- 모달 배경 -->
<div id="modalBackdrop"></div>
