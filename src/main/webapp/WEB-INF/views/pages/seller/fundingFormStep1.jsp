<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>
<link rel="stylesheet" href="${cpath}/resources/css/funding_edit.css" />
<c:set var="isNotReadyStatus"
	value="${empty tempFunding.status || tempFunding.status ne '준비중'}" />
<script>
  const contextPath = "<%=request.getContextPath()%>";
</script>
<%-- 전체 페이지 컨테이너 (옵션: 중앙 정렬 및 여백 부여) --%>
<div class="page-container">
	<div class="edit-funding-container">
		<c:choose>
			<c:when test="${!isNotReadyStatus}">
				<h2>펀딩 정보 입력</h2>
			</c:when>
			<c:when test="${isNotReadyStatus}">
				<h2>펀딩 정보</h2>
			</c:when>
		</c:choose>
		<input type="hidden" id="productId" value="${product.productId}" /> <input
			type="hidden" id="fundingId" name="fundingId"
			value="${tempFunding.fundingId}"> <input type="hidden"
			id="currentProcessingUserId" name="currentProcessingUserId"
			value="${currentProcessingUserId}">

		<div class="form-group">
			<c:choose>
				<c:when test="${isNotReadyStatus && tempFunding.status eq '진행중'}">
					<p class="disabled-message">
						<span class="fundingName">${tempFunding.fundingName} 펀딩</span>은 지금
						진행되고 있어요.<br>진행 중인 펀딩은 <span class="editordelete">수정이나
							삭제가 어렵습니다.</span>
					</p>
				</c:when>
				<c:when
					test="${isNotReadyStatus && tempFunding.status eq '성공' || tempFunding.status eq '실패'}">
					<p class="disabled-message">
						<span class="fundingName">${tempFunding.fundingName} 펀딩</span>은 지금
						종료 되었어요.<br>종료된 펀딩은 <span class="editordelete">수정이나
							삭제가 어렵습니다.</span>
					</p>
				</c:when>
				<c:otherwise>
					<p class="disabled-message">
						<span class="fundingName">${tempFunding.fundingName} 펀딩</span>은 아직
						펀딩이 시작 전입니다.<br>펀딩 시작 전까지는 <span class="editordelete">언제든지
							수정이나 삭제가 가능합니다!</span>
					</p>
				</c:otherwise>
			</c:choose>
			<label for="fundingName">펀딩 이름</label> <input type="text"
				id="fundingName" name="fundingName"
				value="${tempFunding.fundingName}" placeholder="펀딩 이름을 입력하세요"
				${isNotReadyStatus ? 'disabled' : ''}>
		</div>

		<div class="form-group">
			<label for="fundingType">펀딩 종류</label> <select id="fundingType"
				name="fundingType" ${isNotReadyStatus ? 'disabled' : ''}>
				<option value="한정"
					${tempFunding.fundingType eq '한정' ? 'selected' : ''}>한정 펀딩</option>
				<option value="일반"
					${tempFunding.fundingType eq '일반' ? 'selected' : ''}>일반 펀딩</option>
			</select>
		</div>

		<div class="form-group">
			<label for="fundingDesc">펀딩에 대한 설명</label>
			<c:choose>
				<c:when test="${isNotReadyStatus}">
					<!-- 수정 불가능한 경우: HTML 해석만 -->
					<div class="funding-desc-readonly">
						<c:out value="${tempFunding.fundingDesc}" escapeXml="false" />
					</div>
				</c:when>
				<c:otherwise>
					<!-- 수정 가능한 경우: contenteditable -->
					<div id="fundingDescEditable" class="funding-desc-editable"
						contenteditable="true">
						<c:out value="${tempFunding.fundingDesc}" escapeXml="false" />
					</div>
					<input type="hidden" id="fundingDesc" name="fundingDesc" />
				</c:otherwise>
			</c:choose>
		</div>

		<c:if test="${!isNotReadyStatus}">
			<!-- 사진 추가 -->
			<div class="menuPicture">
				<div class="menu-label">펀딩 사진을 선택해 주세요.</div>
				<p>
					<strong>최대 2개까지</strong> 메뉴 사진을 넣어주세요! <strong>사진 추가하기</strong> 버튼을
					누르면 사진을 선택할 수 있어요. <br> 사진을 삭제하려면, 사진 밑에 있는 <strong>취소하기</strong>
					버튼을 눌러주세요.
				</p>

				<div class="pictureBtn">
					<button type="button" id="btnAddPhoto">펀딩 사진 추가하기</button>
					<input type="file" id="inputPhoto" accept="image/*" multiple
						style="display: none" />
					<!-- 업로드된 이미지 url을 담을 hidden input -->
					<div id="hiddenImageInputs"></div>

					<button type="button" id="btnDefaultPhoto">메뉴 사진과 동일</button>
				</div>
				<!-- 사진 미리보기 -->
				<div id="previewContainer" class="preview-container"></div>

			</div>
		</c:if>
	</div>
</div>

<div class="btn-container">
	<button type="button"
		onclick="location.href='${cpath}/seller/store/funding/stats?fundingId=${tempFunding.fundingId}'"
		class="btn">이전</button>
	<button type="button" class="btn" onclick="submitFunding()">다음</button>
</div>
<script>
let isDateConfirmed = false;
const imageList = []; // { type: "file" | "url", value: File | string }
const imageLimit = 2;

// productDTO.images를 JSTL로 넘겨받아 JS 배열로 만듦
const productImages = [
	<c:forEach var="img" items="${product.images}" varStatus="loop">
		"${img.imageUrl}"<c:if test="${not loop.last}">,</c:if>
	</c:forEach>
];

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


async function submitFunding() {
	document.getElementById("fundingDesc").value = document.getElementById("fundingDescEditable").innerHTML;

    const funding = {
        fundingId: parseInt(document.getElementById("fundingId").value),
        fundingName: document.getElementById("fundingName").value,
        productId: parseInt(document.getElementById("productId").value),
        fundingDesc: document.getElementById("fundingDesc").value,
        fundingType: document.getElementById("fundingType").value,
        images: []
    };
    // 이미지 업로드 처리
    for (const img of imageList) {
        if (img.type === "file") {
            const formData = new FormData();
            formData.append("file", img.value);
            const res = await fetch(`${contextPath}/image/upload`, {
                method: "POST",
                body: formData
            });
            if (!res.ok) {
                alert("이미지 업로드 실패");
                return;
            }
            const imageUrl = await res.text();
            funding.images.push({ imageUrl });
            console.log("imageUrl", imageUrl);
        } else if (img.type === "url") {
            const fileName = img.value.split("/").pop();
            funding.images.push({ imageUrl: fileName });
        }
    }

    // 펀딩 정보 JSON 전송
    
    const res = await fetch(`${cpath}/seller/store/edit/step1`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(funding)
    });

    if (res.ok) {
        location.href = `${cpath}/seller/store/edit/step2`;
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

	productImages.forEach(url => {
		const wrapper = document.createElement("div");
		wrapper.className = "preview-image";

		const img = document.createElement("img");
		img.src = url;

		const btn = document.createElement("button");
		btn.textContent = "취소하기";
		btn.className = "btn-cancel";
		btn.onclick = () => {
			const idx = imageList.findIndex(v => v.type === "url" && v.value === url);
			if (idx !== -1) imageList.splice(idx, 1);
			wrapper.remove();
		};

		imageList.push({ type: "url", value: url });
		wrapper.appendChild(img);
		wrapper.appendChild(btn);
		preview.appendChild(wrapper);
	});
});
</script>