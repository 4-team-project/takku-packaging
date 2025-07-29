<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<link rel="stylesheet" href="/resources/css/sellerFundingDetail.css" />
<div class="container">
	<input type="hidden" id="originalPrice" value="${product.price}">
	<c:set var="discountRate"
		value="${(product.price - funding.salePrice) * 100 / product.price}" />
	<span class="all"> <c:choose>
			<c:when test="${funding.status eq '진행중'}">
				<span class="highlight">${funding.fundingName} 펀딩</span>은 지금 진행되고 있어요. <br>현재 진행중인 펀딩은 <span
					class="hi">수정하거나 삭제할 수 없습니다.</span>
			</c:when>
			<c:when test="${funding.status eq '성공' || funding.status eq '실패'}">
			종료된 펀딩은 <span class="hi">수정하거나 삭제할 수 없습니다.</span>
			</c:when>
		</c:choose>
	</span>
	<form action="/seller/funding/create/step1" method="post"
		enctype="multipart/form-data">
		<%-- 펀딩 수정/저장 시 사용할 URL --%>
		<input type="hidden" name="fundingId" value="${funding.fundingId}">

		<div class="form-group">
			<label for="fundingName">펀딩 이름</label> <input type="text"
				id="fundingName" name="fundingName" value="${funding.fundingName}"
				${isEditable ? '' : 'readonly'}>
		</div>

		<div class="form-group">
			<label for="fundingType">펀딩 종류</label> <select id="fundingType"
				name="fundingType" ${isEditable ? '' : 'disabled'}>
				<option value="한정" ${funding.fundingType eq '한정' ? 'selected' : ''}>한정</option>
				<option value="일반" ${funding.fundingType eq '일반' ? 'selected' : ''}>일반</option>
			</select>
		</div>

		<div class="form-group">
			<label for="fundingDesc">펀딩에 대한 설명</label>
			<c:choose>
				<c:when test="${(empty funding.fundingDesc) || !isEditable}">
					<textarea id="fundingDesc"
						placeholder="상품 설명은 비워도 괜찮아요.&#13;&#10;꼭 작성하지 않아도 등록할 수 있어요."
						name="fundingDesc" ${isEditable ? '' : 'readonly'}>${funding.fundingDesc}</textarea>
				</c:when>
				<c:otherwise>
					<textarea id="fundingDesc" name="fundingDesc"
						${isEditable ? '' : 'readonly'}>${funding.fundingDesc}</textarea>
				</c:otherwise>
			</c:choose>
		</div>

		<div class="form-group">
			<label for="menuPhoto">메뉴 사진</label>
			<c:if test="${not empty funding.fundingName}">
				<label>가능 하면 메뉴 사진</label>
			</c:if>
			<input type="file" id="menuPhoto" name="menuPhoto"
				${isEditable ? '' : 'disabled'}>
			<%-- 이미지 파일 업로드 필드 --%>
		</div>
		<button type="submit">다음</button>
	<!-- </form> -->
	<div class="form-group">
		<label for="salePrice">판매 가격</label> <input type="number"
			id="salePrice" name="salePrice" value="${funding.salePrice}"
			${isEditable ? '' : 'readonly'}>
	</div>

	<div class="form-group">
		<label for="discountRate">할인율 (%)</label> <input type="number"
			id="discountRate" name="discountRate"
			value="${discountRate - (discountRate%1) }"
			${isEditable ? '' : 'readonly'}>
		<div id="discountRateWarning"
			style="color: red; font-size: 0.85em; margin-top: 5px;"></div>
	</div>

	<div class="form-group">
		<label for="targetQty">목표 수량</label> <input type="number"
			id="targetQty" name="targetQty" value="${funding.targetQty}"
			${isEditable ? '' : 'readonly'}>
	</div>

	<div class="form-group">
		<label for="maxQty">최대 수량</label> <input type="number" id="maxQty"
			name="maxQty" value="${funding.maxQty}"
			${isEditable ? '' : 'readonly'}>
	</div>

	<div class="form-group">
		<label for="perQty">1인당 구매 가능 수량</label> <input type="number"
			id="perQty" name="perQty" value="${funding.perQty}"
			${isEditable ? '' : 'readonly'}>
	</div>

	<div class="form-group">
		<label for="startDate">시작일</label> <input type="date" id="startDate"
			name="startDate"
			value="<fmt:formatDate value="${funding.startDate}" pattern="yyyy-MM-dd"/>"
			${isEditable ? '' : 'readonly'}>
	</div>

	<div class="form-group">
		<label for="endDate">종료일</label> <input type="date" id="endDate"
			name="endDate"
			value="<fmt:formatDate value="${funding.endDate}" pattern="yyyy-MM-dd"/>"
			${isEditable ? '' : 'readonly'}>
	</div>

	<div class="action-buttons">
		<c:if test="${isEditable}">
			<button type="submit" class="primary">수정 저장</button>
			<button type="button" class="danger" onclick="confirmDelete()">펀딩
				삭제</button>
		</c:if>
		<button type="button" onclick="window.history.back()"
			class="secondary">뒤로 가기</button>
	</div>
	</form>
</div>

<script>
	// DOMContentLoaded는 HTML 문서가 완전히 로드되고 파싱되었을 때 실행
	document
			.addEventListener(
					'DOMContentLoaded',
					function() {
						const salePriceInput = document
								.getElementById('salePrice');
						const discountRateInput = document
								.getElementById('discountRate');
						const originalPriceInput = document
								.getElementById('originalPrice'); // hidden 필드의 원가
						const isEditable = $
						{
							isEditable
						}
						; // JSP EL 변수를 JavaScript로 가져옴

						// 원가(originalPrice)가 없거나 0이면 계산 불가
						const originalPrice = parseFloat(originalPriceInput ? originalPriceInput.value
								: 0);

						if (isEditable) {
							// 판매 가격 변경 시 할인율 계산
							salePriceInput
									.addEventListener(
											'input',
											function() {
												const salePrice = parseFloat(this.value); // 현재 판매 가격 값
												if (!isNaN(salePrice)
														&& originalPrice > 0) {
													const discountRate = ((originalPrice - salePrice) / originalPrice) * 100;
													if (discountRate < 0) {
														discountRate = 0; // 음수 할인율은 0으로
													} else if (discountRate > 100) {
														discountRate = 100; // 100 초과는 100으로 제한
													}

													discountRateInput.value = Math
															.floor(discountRate); // 정수 부분만
													discountRateWarning.textContent = ''; // 경고 메시지 지움
												} else if (originalPrice === 0) {
													discountRateInput.value = '0';
													discountRateWarning.textContent = '';
												} else {
													discountRateInput.value = '';
													discountRateWarning.textContent = '';
												}
											});

							// 할인율 변경 시 판매 가격 계산 및 유효성 검사
							discountRateInput
									.addEventListener(
											'input',
											function() {
												let discountRate = parseFloat(this.value); // 입력된 할인율 값

												if (isNaN(discountRate)) { // 숫자가 아닐 경우
													salePriceInput.value = '';
													discountRateWarning.textContent = '';
													return;
												}

												// 0 미만 또는 100 초과 값에 대한 경고 및 자동 조정
												if (discountRate < 0) {
													discountRateWarning.textContent = '할인율은 0% 미만이 될 수 없습니다.';
													discountRate = 0; // 0으로 자동 조정
												} else if (discountRate > 100) {
													discountRateWarning.textContent = '할인율은 100%를 초과할 수 없습니다. 100 이하의 숫자를 입력해주세요.';
													discountRate = 100; // 100으로 자동 조정
												} else {
													discountRateWarning.textContent = ''; // 유효한 값일 경우 경고 메시지 지움
												}

												// 할인율 필드 값도 조정된 값으로 업데이트 (선택 사항, 경고와 함께 조정)
												this.value = Math
														.floor(discountRate);

												if (originalPrice > 0) {
													const salePrice = originalPrice
															* (1 - (discountRate / 100));
													salePriceInput.value = Math
															.round(salePrice);
												} else {
													salePriceInput.value = '0';
												}
											});

							// 초기 로드 시 할인율 유효성 검사 (필요하다면)
							// discountRateInput.dispatchEvent(new Event('input')); 
						}
					});
	function confirmDelete() {
		if (confirm("정말로 이 펀딩을 삭제하시겠습니까?")) {
			// 삭제 로직 (예: 폼 제출 또는 AJAX 요청)
			// 현재는 예시이므로, 실제 삭제 URL과 로직을 여기에 구현해야 합니다.
			alert("펀딩 삭제 기능은 아직 구현되지 않았습니다.");
			// window.location.href = "/seller/funding/delete?fundingId=${funding.fundingId}";
		}
	}
</script>