<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<script src="https://cdn.iamport.kr/js/iamport.payment-1.2.0.js"></script>
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

<link rel="stylesheet" type="text/css"
	href="${cpath}/resources/css/pages/user/order.css">

<script>
$(function() {
	const userPoint = parseInt("${loginUser.point}");
    const totalPrice = parseInt("${totalPrice}");
    const fundingId = parseInt("${funding.fundingId}");
    const quantity = parseInt("${quantity}");
    
    const IMP = window.IMP;
    IMP.init("${iamportApiKey}"); // 본인의 가맹점 식별코드

    // 전액 사용 버튼 클릭 시
    $("#useAllPointBtn").click(function () {
        $("#usePoint").val(userPoint);
        updateFinalAmount();
    });

    // 포인트 입력값이 바뀔 때마다 실시간 계산
    $("#usePoint").on("input", function () {
    	let val = parseInt($(this).val()) || 0;

    	if (val > userPoint) {
    		val = userPoint;
    		$(this).val(userPoint); // 입력값을 보유 포인트로 자동 조정
    	} else if (val < 0) {
    		val = 0;
    		$(this).val(0);
    	}
    	
        updateFinalAmount();
    });

    function updateFinalAmount() {
        let usePoint = parseInt($("#usePoint").val()) || 0;

        // 값 제한 처리
        if (usePoint < 0) usePoint = 0;
        if (usePoint > userPoint) usePoint = userPoint;

        // 최종 금액 계산
        const final = totalPrice - usePoint;
        const formatted = final.toLocaleString();
        
        // 화면 업데이트
        $("#finalAmount").text(`\${formatted} 원`);
    }

    $(".buy-button").click(function(e) {
        e.preventDefault();

        const usePoint = parseInt($("#usePoint").val()) || 0;
        const totalPrice = parseInt("${totalPrice}");
        const finalPrice = Math.max(totalPrice - usePoint, 0); // 음수 방지
        
        IMP.request_pay({
            pg: "html5_inicis",
            pay_method: "card",
            merchant_uid: "order_" + new Date().getTime(),
            name: "${funding.fundingName}",
            amount: 200-usePoint, //test
            buyer_email: "takku@songil.com",
            buyer_name: "${loginUser.name}",
            buyer_tel: "${loginUser.phone}"
        }, function(rsp) {
            if (rsp.success) {
                // 서버에 결제 정보 POST 전송
                const form = $('<form>', {
                    method: 'post',
                    action: '${cpath}/order/payment'
                });

                form.append($('<input>', { type: 'hidden', name: 'fundingId', value: fundingId }));
                form.append($('<input>', { type: 'hidden', name: 'quantity', value: quantity }));
                form.append($('<input>', { type: 'hidden', name: 'usePoint', value: usePoint }));
                form.append($('<input>', { type: 'hidden', name: 'totalPrice', value: totalPrice }));
                form.append($('<input>', { type: 'hidden', name: 'imp_uid', value: rsp.imp_uid }));
                form.append($('<input>', { type: 'hidden', name: 'merchant_uid', value: rsp.merchant_uid }));

                $('body').append(form);
                form.submit();
            } else {
                alert("결제에 실패했습니다: " + rsp.error_msg);
            }
        });
    });
});
</script>

<div class="order-container">
	<div class="order-left">
		<div class="info">
			<h3>펀딩 상품 정보</h3>
			<div class="product-info">
				<div class="product-image">
					<img src="${cpath}${funding.images[0].imageUrl}" alt="펀딩 이미지" />
				</div>
				<div class="product-detail">
					<span class="store-name">${store.storeName}</span><br>
					<p class="funding-name">${funding.fundingName}</p>
					<p>수량 ${quantity}개</p>
					<p class="price">
						<fmt:formatNumber value="${totalPrice}" type="number" />
						원
					</p>
				</div>
			</div>
		</div>

		<div class="info">
			<h3>구매자 정보</h3>
			<p>${loginUser.name}</p>
			<p>${loginUser.phone}</p>
			<p>${loginUser.birth}</p>
		</div>
	</div>

	<div class="order-right">
		<div class="info">
			<h3 class="label-row">
				보유 포인트 <span class="right-price"> <fmt:formatNumber
						value="${loginUser.point}" type="number" /> 원
				</span>
			</h3>
			<h3 class="label-row">
				사용할 포인트
				<div class="right-price">
					<input type="number" id="usePoint" name="usePoint" placeholder="0"
						min="0" max="${loginUser.point}" step="100"
						style="width: 100px; height: 30px; font-size: 16px; border: 2px solid #ff9670; background: #fff6f0" /><br>
					<button id="useAllPointBtn">
						전액 사용</button>
				</div>
			</h3>
		</div>

		<div class="info">
			<h3 class="label-row">
				최종 결제 금액 <span class="right-price"> <span id="finalAmount"><fmt:formatNumber
							value="${totalPrice}" type="number" /> 원</span>
				</span>
			</h3>
			<p class="small-text">
				펀딩이 정해진 기간 내 100% 달성되면, 쿠폰이 발급되어 사용하실 수 있습니다.<br> 펀딩이 무산되거나 중단될
				경우, 결제 금액은 자동으로 전액 환불됩니다.
			</p>
			<button type="submit" class="buy-button">결제하기</button>
		</div>
	</div>
</div>
