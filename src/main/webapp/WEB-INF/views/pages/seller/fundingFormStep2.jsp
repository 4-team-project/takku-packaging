<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<link rel="stylesheet" href="/resources/css/funding_edit.css" />
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
<link rel="stylesheet"
	href="https://cdn.jsdelivr.net/npm/flatpickr/dist/themes/material_blue.css">
<script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
<script src="https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/ko.js"></script>
<c:set var="isNotReadyStatus"
	value="${empty tempFunding.status || tempFunding.status ne '준비중'}" />

<div class="page-container">
	<div class="edit-funding-container">
		<c:set var="price" value="${product.price}" />
		<c:set var="sale" value="${tempFunding.salePrice}" />
		<c:set var="discountRate" value="${(price - sale) * 100 / price}" />
		<c:set var="discountRateInt"
			value="${discountRate - (discountRate % 1)}" />

		<c:choose>
			<c:when test="${!isNotReadyStatus}">
				<h2>펀딩 정보 입력</h2>
			</c:when>
			<c:when test="${isNotReadyStatus}">
				<h2>펀딩 정보</h2>
			</c:when>
		</c:choose>

		<form action="${cpath}/seller/store/edit/step2" method="post">
			<input type="hidden" id="fundingId" name="fundingId"
				value="${tempFunding.fundingId}"> <input type="hidden"
				id="currentProcessingUserId" name="currentProcessingUserId"
				value="${currentProcessingUserId}">
			<c:forEach var="img" items="${tempFunding.images}" varStatus="status">
				<input type="hidden" name="images[${status.index}].imageUrl"
					value="${img.imageUrl}" />
			</c:forEach>
			<div class="form-group">
				<c:choose>
					<c:when test="${isNotReadyStatus && tempFunding.status eq '진행중'}">
						<p class="disabled-message">
							<span class="fundingName">${tempFunding.fundingName} 펀딩</span>은
							지금 진행되고 있어요.<br>진행 중인 펀딩은 <span class="editordelete">수정이나
								삭제가 어렵습니다.</span>
						</p>
					</c:when>
					<c:when
						test="${isNotReadyStatus && tempFunding.status eq '성공' || tempFunding.status eq '실패'}">
						<p class="disabled-message">
							<span class="fundingName">${tempFunding.fundingName} 펀딩</span>은
							지금 종료 되었어요.<br>종료된 펀딩은 <span class="editordelete">수정이나
								삭제가 어렵습니다.</span>
						</p>
					</c:when>
					<c:otherwise>
						<p class="disabled-message">
							<span class="fundingName">${tempFunding.fundingName} 펀딩</span>은
							아직 펀딩이 시작 전입니다.<br>펀딩 시작 전까지는 <span class="editordelete">언제든지
								수정이나 삭제가 가능합니다!</span>
						</p>
					</c:otherwise>
				</c:choose>
			</div>

			<%-- 판매 가격 필드 --%>
			<div class="form-group">
				<label for="fundingSalePrice">판매 가격</label>
				<div
					class="input-with-unit-wrapper ${isNotReadyStatus ? 'disabled-wrapper' : ''}">
					<div class="input-and-unit">
						<input type="text" id="salePrice" name="salePrice"
							value="${tempFunding.salePrice}" placeholder="판매 가격을 입력하세요"
							oninput="validateNumber(this)"
							${isNotReadyStatus ? 'disabled' : ''}> <span
							class="unit-text">원</span>
						<%-- '원' 단위 추가 (필요 시) --%>
					</div>
				</div>
			</div>

			<%-- 할인율 필드 --%>
			<div class="form-group">
				<label for="discountRate">할인율</label>
				<div
					class="input-with-unit-wrapper ${isNotReadyStatus ? 'disabled-wrapper' : ''}">
					<div class="input-and-unit">
						<input type="text" id="discountRate" name="discountRate"
							value="${discountRateInt}" placeholder="할인율을 입력하세요"
							oninput="validateNumber(this)"
							${isNotReadyStatus ? 'disabled' : ''}> <span
							class="discount-unit-text">%</span>
					</div>
					<span class="price-info-text">(원가 : ${price})</span>
				</div>
			</div>

			<%-- 목표 수량 필드 --%>
			<div class="form-group">
				<label for="fundingTargetQty">목표 수량</label>
				<div
					class="input-with-unit-wrapper ${isNotReadyStatus ? 'disabled-wrapper' : ''}">
					<div class="input-and-unit">
						<input type="text" id="targetQty" name="targetQty"
							value="${tempFunding.targetQty}" placeholder="목표 수량을 입력하세요"
							oninput="validateNumber(this)"
							${isNotReadyStatus ? 'disabled' : ''}> <span
							class="unit-text">개</span>
					</div>
				</div>
			</div>

			<%-- 최대 수량 필드 --%>
			<div class="form-group">
				<label for="fundingMaxQty">최대 수량</label>
				<div
					class="input-with-unit-wrapper ${isNotReadyStatus ? 'disabled-wrapper' : ''}">
					<div class="input-and-unit">
						<input type="text" id="maxQty" name="maxQty"
							value="${tempFunding.maxQty}" placeholder="최대 수량을 입력하세요"
							oninput="validateNumber(this)"
							${isNotReadyStatus ? 'disabled' : ''}> <span
							class="unit-text">개</span>
					</div>
				</div>
			</div>

			<%-- 1인당 구매 가능 수량 필드 --%>
			<div class="form-group">
				<label for="fundingPerQty">1인당 구매 가능 수량</label>
				<div
					class="input-with-unit-wrapper ${isNotReadyStatus ? 'disabled-wrapper' : ''}">
					<div class="input-and-unit">
						<input type="text" id="perQty" name="perQty"
							value="${tempFunding.perQty}" placeholder="1인당 구매 가능 수량을 입력하세요"
							oninput="validateNumber(this)"
							${isNotReadyStatus ? 'disabled' : ''}> <span
							class="unit-text">개</span>
					</div>
				</div>
			</div>

			<div class="form-group">
				<label for="dateRangePicker">기간</label>
				<%-- isNotReadyStatus가 false일 때만 캘린더 기능을 활성화 --%>
				<c:choose>
					<c:when test="${isNotReadyStatus}">
						<%-- 비활성화 상태: 단순 텍스트 필드로 표시 --%>
						<input type="text" id="dateRangePicker"
							value="${tempFunding.startDate} ~ ${tempFunding.endDate}"
							disabled>
					</c:when>
					<c:otherwise>
						<%-- 활성화 상태: Flatpickr 적용될 필드 --%>
						<input type="text" id="dateRangePicker"
							placeholder="시작일 ~ 종료일을 선택하세요"
							value="${tempFunding.startDate != null && tempFunding.endDate != null ? tempFunding.startDate : ''}, ${tempFunding.startDate != null && tempFunding.endDate != null ? tempFunding.endDate : ''}"
							data-start-date="${tempFunding.startDate}"
							data-end-date="${tempFunding.endDate}">
						<%-- 실제 서버로 전송될 숨겨진 필드 --%>
						<input type="hidden" id="startDate" name="startDate"
							value="${tempFunding.startDate}">
						<input type="hidden" id="endDate" name="endDate"
							value="${tempFunding.endDate}">
					</c:otherwise>
				</c:choose>
			</div>
			<div class="btn-container">
				<button type="button"
					onclick="location.href='${cpath}/seller/store/edit/step1'"
					class="btn">이전</button>
				<c:choose>
					<c:when test="${!isNotReadyStatus}">
						<button type="submit" class="btn filled">펀딩 저장</button>
					</c:when>
					<c:when test="${isNotReadyStatus}">
						<button type="submit" class="btn filled">확인 완료</button>
					</c:when>
				</c:choose>
			</div>
		</form>
	</div>
</div>
<script>
<c:if test="${!isNotReadyStatus}">
document.addEventListener('DOMContentLoaded', function() {
    // Flatpickr 초기화 (기존 코드)
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');
    const dateRangePicker = document.getElementById('dateRangePicker');
    

    flatpickr(dateRangePicker, {
        mode: "range",
        dateFormat: "Y-m-d",
        locale: "ko",
        enableTime: false,
        altInput: true,
        altFormat: "Y년 n월 j일",
        defaultDate: [
            startDateInput.value ? new Date(startDateInput.value) : null,
            endDateInput.value ? new Date(endDateInput.value) : null
        ],
        onChange: function(selectedDates, dateStr, instance) {
            if (selectedDates.length === 2) {
                startDateInput.value = flatpickr.formatDate(selectedDates[0], "Y-m-d");
                endDateInput.value = flatpickr.formatDate(selectedDates[1], "Y-m-d");
            } else if (selectedDates.length === 1) {
                startDateInput.value = flatpickr.formatDate(selectedDates[0], "Y-m-d");
                endDateInput.value = '';
            } else {
                startDateInput.value = '';
                endDateInput.value = '';
            }
        }
    });

    // 펀딩 연동 및 유효성 검사 로직
    const originalPrice = parseFloat('${product.price}');
    const salePriceInput = document.getElementById('salePrice');
    const discountRateInput = document.getElementById('discountRate');
    const targetQtyInput = document.getElementById('targetQty');
    const maxQtyInput = document.getElementById('maxQty');
    const perQtyInput = document.getElementById('perQty');

    // 숫자 입력만 허용하고, 불필요한 문자 제거하는 함수
    window.validateNumber = function(inputElement) {
        // 숫자가 아닌 모든 문자(한글, 영어, 특수문자 등)와 마이너스 부호를 제거
        // 소수점을 허용하려면 /[^0-9.]/g 로 변경
        inputElement.value = inputElement.value.replace(/[^0-9]/g, '');

        // 입력 후 바로 유효성 검사 함수 호출 (각 필드에 맞는 로직)
        // 예를 들어, 판매 가격이나 할인율이 입력되면 관련 필드 업데이트
        // 목표/최대 수량이 입력되면 관련 유효성 검사
        if (inputElement === salePriceInput || inputElement === discountRateInput) {
            // 이 두 필드는 상호 연동되므로, 값이 변경된 쪽의 이벤트 리스너를 강제로 트리거
            // 하지만 직접 이벤트 트리거 대신, 각 필드의 값을 바로 계산하는 함수를 만들어 쓰는 것이 더 깔끔합니다.
            updatePriceAndDiscount();
        } else if (inputElement === targetQtyInput || inputElement === maxQtyInput || inputElement === perQtyInput) {
            validateQuantities();
        }
    };

    // 판매 가격 및 할인율 업데이트 함수 (하나로 통합)
    function updatePriceAndDiscount() {
        let salePrice = getNumericValue(salePriceInput);
        let discountRate = getNumericValue(discountRateInput);

        const activeElement = document.activeElement; // 현재 포커스된 요소 확인

        if (activeElement === salePriceInput) {
            // 판매 가격 입력 중일 때 할인율 계산
            // 판매 가격이 원가를 넘지 못하게 함
            if (salePrice > originalPrice) {
                salePrice = originalPrice;
                salePriceInput.value = originalPrice;
            } else if (salePrice < 0) {
                salePrice = 0;
                salePriceInput.value = 0;
            }
            if (originalPrice > 0) {
                let calculatedDiscountRate = ((originalPrice - salePrice) / originalPrice) * 100;
                discountRateInput.value = Math.floor(calculatedDiscountRate);
            } else {
                discountRateInput.value = 0;
            }
        } else if (activeElement === discountRateInput) {
            // 할인율 입력 중일 때 판매 가격 계산
            // 할인율이 0~100 범위를 벗어나지 못하게 함
            if (discountRate < 0) {
                discountRate = 0;
                discountRateInput.value = 0;
            } else if (discountRate > 100) {
                discountRate = 100;
                discountRateInput.value = 100;
            }
            let calculatedSalePrice = originalPrice - (originalPrice * discountRate / 100);
            salePriceInput.value = Math.round(calculatedSalePrice);
        }
    }

    // 수량 필드 유효성 검사 (모든 수량 필드에 적용)
    function validateQuantities() {
        let targetQty = getNumericValue(targetQtyInput);
        let maxQty = getNumericValue(maxQtyInput);
        let perQty = getNumericValue(perQtyInput);

        // 목표 수량이 최대 수량을 초과하지 못하게
        if (targetQty > maxQty && maxQty > 0) {
            targetQtyInput.value = maxQty;
            targetQty = maxQty; // 조정된 값으로 업데이트
        }
        // 1인당 구매 가능 수량이 목표 수량, 최대 수량을 넘지 못하게 (필요 시)
        if (perQty > targetQty && targetQty > 0) {
             perQtyInput.value = targetQty;
        } else if (perQty > maxQty && maxQty > 0) {
             perQtyInput.value = maxQty;
        }


        // 각 수량이 음수가 되지 않도록
        if (targetQty < 0) { targetQtyInput.value = 0; }
        if (maxQty < 0) { maxQtyInput.value = 0; }
        if (perQty < 0) { perQtyInput.value = 0; }
    }

    // 초기 로드 시 한 번 계산하여 동기화 및 유효성 검사
    // 페이지 로드 시 어떤 필드가 우선권을 가질지 (판매가 vs 할인율) 결정하여 호출
    // 현재는 salePriceInput.value가 있다면 판매가를 기준으로, 없으면 할인율 기준으로 시작
    if (salePriceInput.value) {
        salePriceInput.dispatchEvent(new Event('input')); // 판매 가격 기반으로 할인율 계산
    } else if (discountRateInput.value) {
        discountRateInput.dispatchEvent(new Event('input')); // 할인율 기반으로 판매 가격 계산
    }
    validateQuantities();


    // 판매 가격 및 할인율 필드에 포커스 이벤트 추가
    // 사용자가 해당 필드에 직접 입력했을 때만 계산이 이루어지도록 (이전 input 이벤트 리스너의 대체)
    salePriceInput.addEventListener('input', updatePriceAndDiscount);
    discountRateInput.addEventListener('input', updatePriceAndDiscount);
    targetQtyInput.addEventListener('input', validateQuantities);
    maxQtyInput.addEventListener('input', validateQuantities);
    perQtyInput.addEventListener('input', validateQuantities);

});
</c:if>

//getNumericValue 함수는 window 객체에 직접 추가하여 oninput에서 접근 가능하도록
function getNumericValue(inputElement) {
const value = parseFloat(inputElement.value);
return isNaN(value) ? 0 : value;
}
</script>
