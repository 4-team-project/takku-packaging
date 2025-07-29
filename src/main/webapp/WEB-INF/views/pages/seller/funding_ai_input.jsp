<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/funding_ai_input.css">
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
	$(function() {
		const content = `${aiResponse != null ? aiResponse.content : ''}`;
		$("#htmlContent").html(content);
		$("#fundingContentHidden").val(content);
		
		// '다시 생성' 버튼 클릭 시
		$("#regenerateBtn").on("click", function(e) {
			
			const aiRetryCount = ${aiRetryCount};
			if (aiRetryCount >= 3) {
				e.preventDefault();
				$("#resultModal, #modalBackdrop").fadeIn();
				return; // submit 막기
			}
			
			// 기존 input 값 유지한 채로 재요청
			const keywords = $("input[name='keywords']").val()
					|| "${param.keywords}";
			const target = $("input[name='target']").val()
					|| "${param.target}";

			const form = $(
					'<form>',
					{
						method : 'POST',
						action : '${pageContext.request.contextPath}/ai/ai-generate'
					}).append($('<input>', {
				type : 'hidden',
				name : 'keywords',
				value : keywords
			}), $('<input>', {
				type : 'hidden',
				name : 'target',
				value : target
			}));
			$('body').append(form);
			form.submit();
		});
		
		// 모달 닫기
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

	<h3>
		아래는 AI가 자동으로 만든 펀딩 제목과 설명, 관련 단어입니다.<br> 원하는 문장이 아니라면 아래 [다시 생성]
		버튼으로 다시 요청해보세요!
	</h3>
	<div class="ai-info-bar">
		<p class="ai-chance">※ AI 생성 기회: ${3 - sessionScope.aiRetryCount} / 3 남음</p>
		<button class="btn" type="button" id="regenerateBtn">다시 생성</button>
	</div>

	<form action="${cpath}/seller/fundings/submit-funding" method="post">
		<div class="input-group">
			<label for="title">펀딩 제목</label> <input type="text" id="title"
				name="fundingName" placeholder="예: 불고기 정식 펀딩"
				value="${aiResponse.title}" required class="form-input" />
		</div>

		<div class="input-group">
			<label for="htmlContent">펀딩 설명</label>
			<div id="htmlContent" class="content-viewer"></div>
			<textarea id="fundingContentHidden" name="fundingDesc"
				style="display: none;" required></textarea>
		</div>

		<div class="input-group">
			<label for="keywords">관련 단어</label> <input type="text" id="keywords"
				name="keywords" placeholder="예: 불고기, 정식, 든든한한끼"
				value="${aiResponse.hashtags}" required class="form-input"/>
		</div>

		<div class="btn-group">
			<button class="btn" type="button" onclick="history.back()">
				이전
			</button>
			<button class="btn filled" type="submit">등록</button>
		</div>
	</form>

<!-- 모달 영역 -->
<div id="resultModal">
	<p id="modalMsg">AI 생성 기회를 모두 사용하셨습니다. <br> 더 이상 생성이 불가능합니다.</p>
	<button id="closeModalBtn">확인</button>
</div>

<!-- 모달 배경 -->
<div id="modalBackdrop"></div>
