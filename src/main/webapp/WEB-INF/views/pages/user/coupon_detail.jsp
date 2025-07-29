<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/coupon_detail.css" />
<script
	src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
<script src="https://kit.fontawesome.com/5db5b8890b.js"
	crossorigin="anonymous"></script>

<div class="coupon-card-qr" id="couponCard"
	data-funding-name="${fn:escapeXml(funding.fundingName)}">
	<button class="detail-close-btn" onclick="exitDetail()">✕</button>

	<h1>
		<strong>${funding.storeName}</strong>
	</h1>
	<h2>${product.productName}</h2>

	<!-- QR 코드 이미지 -->
	<img class="qr" src="${qrUrl}" alt="QR 코드" crossorigin="anonymous" />

	<div class="download-icon" onclick="downloadCouponImage()">
		쿠폰 다운로드 <i class="fa-solid fa-download"></i>
	</div>

	<div class="coupon-info">
		<strong>${funding.fundingName}</strong><br /> ${funding.fundingDesc}
	</div>
</div>

<script>
	function sanitizeFileName(name) {
		return name.replace(/[\\/:*?"<>|]/g, '').replace(/\s+/g, '_');
	}
	function ensurePngExtension(name) {
		return name.toLowerCase().endsWith('.png') ? name : name + '.png';
	}
	function downloadCouponImage() {
		const card = document.getElementById('couponCard');
		const downloadBtn = card.querySelector('.download-icon');
		const closeBtn = card.querySelector('.detail-close-btn');
		const qrImg = card.querySelector('img.qr');
		const fileName = ensurePngExtension(sanitizeFileName(card.dataset.fundingName || 'coupon'));

		downloadBtn.style.display = 'none';
		closeBtn.style.display = 'none';

		// 이미지 로드 완료 후 캡처
		if (!qrImg.complete) {
			qrImg.onload = () => capture();
			qrImg.onerror = () => {
				alert("QR 이미지 로딩 실패. 다시 시도해주세요.");
				downloadBtn.style.display = '';
				closeBtn.style.display = '';
			};
		} else {
			capture();
		}

		function capture() {
			html2canvas(card, {
				useCORS: true,
				allowTaint: false,
				backgroundColor: null
			}).then(canvas => {
				const link = document.createElement('a');
				link.download = fileName;
				link.href = canvas.toDataURL('image/png');
				link.click();
			}).catch(err => {
				alert("이미지 저장에 실패했습니다: " + err);
			}).finally(() => {
				downloadBtn.style.display = '';
				closeBtn.style.display = '';
			});
		}
	}
</script>

