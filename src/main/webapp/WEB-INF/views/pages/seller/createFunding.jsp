<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/createFunding_main.css">

<h3>어떤 펀딩을 만들고 싶으신가요?</h3>
<form id="fundingForm"
	action="${pageContext.request.contextPath}/seller/fundings/create-step2" onsubmit="return validateSelection();">
	<input type="hidden" id="fundingTypeInput" name="type" value="">

	<div class="funding-type-select">
		<!-- 버튼 클릭 시 hidden input 값 설정 -->
		<button type="button" id="btnLimited" class="funding-btn" onclick="selectFundingType('limited')">
			<p>한정 상품 펀딩</p><br>
			<span class="description"><strong>딱쿠에서만</strong> 만나볼 수 있는 메뉴에 대한 펀딩이에요.</span>
		</button>
		<button type="button" id="btnGeneral" class="funding-btn" onclick="selectFundingType('general')">
			<p>일반 펀딩</p><br>
			<span class="description"><strong>상시 판매</strong> 되는 메뉴에 대한 펀딩이에요.</span>
		</button>
	</div>

	<!-- submit 버튼 -->
	<button type="submit" class = "btn-next">다음</button>
</form>
<script>

 	function validateSelection() {
		const selected = document.getElementById('fundingTypeInput').value;
		if (!selected) {
		alert("펀딩 종류를 선택해주세요");
			return false;
		}
		return true;
	} 
 	
	function selectFundingType(type) {
		  const btnLimited = document.getElementById('btnLimited');
		  const btnGeneral = document.getElementById('btnGeneral');

		  // 모든 버튼 초기화
		  btnLimited.classList.remove('selected-limited', 'selected-general');
		  btnGeneral.classList.remove('selected-limited', 'selected-general');

		  // 선택한 버튼에만 스타일 추가
		  if (type === 'limited') {
		    btnLimited.classList.add('selected-limited');
		  } else if (type === 'general') {
		    btnGeneral.classList.add('selected-general');
		  }

		// 버튼 클릭 시 hidden input 값 설정
			document.getElementById('fundingTypeInput').value = type;
		}

</script>
