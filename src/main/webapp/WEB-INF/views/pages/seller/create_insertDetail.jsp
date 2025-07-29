<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<input type="hidden" id="productId" value="${productDTO.productId}" />

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<link rel="stylesheet"
	href="${pageContext.request.contextPath}/resources/css/pages/seller/createFunding_insertDetail.css">

<div class="step-progress">
	<div class="step">
		<div class="circle">1</div>
		<div class="label">상품 정보</div>
	</div>
	<div class="line"></div>
	<div class="step active">
		<div class="circle">2</div>
		<div class="label">기간 및 이미지</div>
	</div>
	<div class="line"></div>
	<div class="step">
		<div class="circle">3</div>
		<div class="label">상세 내용</div>
	</div>
</div>

<h3>기간 및 이미지를 입력해주세요.</h3>
<div class="fundingDate">
<div class="menu-label">펀딩 시작일과 종료일을 입력해 주세요.</div>
	<p> 달력 사진(
  	<img src="${pageContext.request.contextPath}/resources/images/icons/calendar.svg"
       alt="달력 아이콘"
       id="calendarIcon"
       style="width:24px; height:24px; cursor:pointer; vertical-align:middle;" />
       )을 누르면 달력이 나와요.
</p>
	<div id="dateArea">
		<span>시작일</span> <input type="date" id="startDate" required
			class="form-input" /> <span>종료일</span> <input type="date"
			id="endDate" required class="form-input" />
		<button type="button" class="btn-check" onclick="submitDate()">확인</button>
	</div>
	<div id="dateInfo"
		style="margin-top: 10px; font-size: 20px; color: #ff9670; font-weight: bold;"></div>
</div>

<div class="menuPicture">
	<div class="menu-label">펀딩 사진을 선택해 주세요.</div>
	<p>
		<strong>최대 2개까지</strong> 사진을 업로드할 수 있어요.<br> <strong>펀딩
			사진 추가하기</strong> 버튼을 누르고, 필요 시 삭제해 주세요.
	</p>
	<div class="pictureBtn">
		<button type="button" id="btnAddPhoto">펀딩 사진 추가하기</button>
		<input type="file" id="inputPhoto" accept="image/*" multiple
			style="display: none" />
		<button type="button" id="btnDefaultPhoto">메뉴 사진과 동일</button>
	</div>
	<div id="previewContainer" class="preview-container"></div>
</div>

<div class="btn-container">
	<c:set var="type" value="${sessionScope.fundingType}" />
	<button class="btn" type="button"
		onclick="location.href='${pageContext.request.contextPath}/seller/fundings/create-step2?type=${type}'">이전</button>
	<button class="btn" type="button" onclick="submitFunding()">다음</button>
</div>

<div id="resultModal">
	<p id="modalMsg"></p>
	<button id="closeModalBtn">확인</button>
</div>
<div id="modalBackdrop"></div>

<script>
const productImages = [
	  <c:forEach var="img" items="${productDTO.images}" varStatus="loop">
	    {
	      imageId: ${img.imageId},
	      imageUrl: "${pageContext.request.contextPath}${img.imageUrl}"
	    }<c:if test="${!loop.last}">,</c:if>
	  </c:forEach>
	];
	
let isDateConfirmed = false;
const imageList = []; // { type: "file" | "url", value: File | string }
const imageLimit = 2;

// productDTO.images를 JSTL로 넘겨받아 JS 배열로 만듦


function showModalMessage(message) {
	$("#modalMsg").text(message);
	$("#resultModal, #modalBackdrop").fadeIn();
}

$(function () {
	$("#closeModalBtn").on("click", function () {
		$("#resultModal, #modalBackdrop").fadeOut();
	});

	$("#btnAddPhoto").on("click", () => $("#inputPhoto").click());
});

document.getElementById("inputPhoto").addEventListener("change", function () {
	const files = Array.from(this.files);
	if (imageList.length + files.length > imageLimit) {
		alert("최대 2장까지 업로드 가능합니다.");
		return;
	}

	files.forEach(file => {
		if (!file.type.startsWith("image/")) {
			alert("유효하지 않은 이미지입니다.");
			return;
		}

		const reader = new FileReader();
		reader.onload = e => {
			const wrapper = document.createElement("div");
			wrapper.className = "preview-image";

			const img = document.createElement("img");
			img.src = e.target.result;

			const btn = document.createElement("button");
			btn.textContent = "취소하기";
			btn.className = "btn-cancel";
			btn.onclick = () => {
				const idx = imageList.findIndex(v => v.type === "file" && v.value === file);
				if (idx !== -1) imageList.splice(idx, 1);
				wrapper.remove();
			};

			wrapper.appendChild(img);
			wrapper.appendChild(btn);
			document.getElementById("previewContainer").appendChild(wrapper);
		};

		imageList.push({ type: "file", value: file });
		reader.onerror = () => {
			console.error("이미지 로딩 실패", reader.error);
			alert("이미지 미리보기에 실패했습니다.");
		};

		reader.readAsDataURL(file);
	});

	this.value = '';
});

function submitDate() {
	const start = document.getElementById("startDate").value;
	const end = document.getElementById("endDate").value;
	if (!start || !end) {
		showModalMessage("시작일과 종료일을 모두 입력해 주세요.");
		return;
	}
	const startDateObj = new Date(start);
	const endDateObj = new Date(end);
	if (endDateObj < startDateObj) {
		showModalMessage("종료일은 시작일보다 이후여야 합니다.");
		return;
	}

	const formattedStart = `\${startDateObj.getFullYear()}년 \${startDateObj.getMonth() + 1}월 \${startDateObj.getDate()}일`;
	const formattedEnd = `\${endDateObj.getFullYear()}년 \${endDateObj.getMonth() + 1}월 \${endDateObj.getDate()}일`;
	document.getElementById("dateInfo").innerText =
		`\${formattedStart} 0시 ~ \${formattedEnd} 23시 59분까지 펀딩이 진행됩니다.`;
	isDateConfirmed = true;
	showModalMessage("날짜가 확인되었습니다!");
}

async function submitFunding() {
	if (!isDateConfirmed) {
		showModalMessage("날짜 확인 버튼을 먼저 눌러주세요.");
		return;
	}

	const funding = {
		startDate: document.getElementById("startDate").value,
		endDate: document.getElementById("endDate").value,
		productId: parseInt(document.getElementById("productId").value),
		images: []
	};

	for (const img of imageList) {
		if (img.type === "file") {
			const formData = new FormData();
			formData.append("file", img.value);

			const res = await fetch("${pageContext.request.contextPath}/image/upload", {
				method: "POST",
				body: formData
			});

			if (!res.ok) {
				alert("이미지 업로드 실패");
				return;
			}

			const imageUrl = await res.text(); 
			funding.images.push({ imageUrl: "/image/tmp/" + imageUrl });
		} else if (img.type === "url") {
			// 이미지 ID가 존재하면 함께 전달
			const fileName = img.value.split("/").pop(); // ex) abc.jpg
			funding.images.push({
				imageId: img.imageId ?? null,
				imageUrl: fileName // 서버에서는 /image/ 붙여서 저장함
			});
		}
	}

	console.log("전송할 funding 객체:", funding);

	const res = await fetch("${pageContext.request.contextPath}/seller/fundings/create-step4", {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify(funding)
	});

	if (res.ok) {
		location.href = "${pageContext.request.contextPath}/seller/fundings/create-step5";
	} else {
		alert("펀딩 전송 실패");
	}
}

document.getElementById("btnDefaultPhoto").addEventListener("click", () => {
	const preview = document.getElementById("previewContainer");
	preview.innerHTML = '';
	imageList.length = 0;
	if (productImages.length === 0) {
		alert("등록된 메뉴 이미지가 없습니다.");
		return;
	}

	productImages.forEach(imgData => {
		const wrapper = document.createElement("div");
		wrapper.className = "preview-image";

		const img = document.createElement("img");
		img.src = imgData.imageUrl;

		const btn = document.createElement("button");
		btn.textContent = "취소하기";
		btn.className = "btn-cancel";
		btn.onclick = () => {
			const idx = imageList.findIndex(v => v.type === "url" && v.value === imgData.imageUrl);
			if (idx !== -1) imageList.splice(idx, 1);
			wrapper.remove();
		};

		imageList.push({
			type: "url",
			value: imgData.imageUrl,
			imageId: imgData.imageId
		});

		wrapper.appendChild(img);
		wrapper.appendChild(btn);
		preview.appendChild(wrapper);
	});
});
</script>
