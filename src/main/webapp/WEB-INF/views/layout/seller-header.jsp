<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${cpath}/resources/css/layout/seller-header.css" />

<div class="box"></div>
<div class="header-box">
	<div style="cursor: pointer" class="logo" onclick="location.href='${cpath}/seller/home'">
		<img src="${cpath}/resources/images/logo.svg" alt="logo" />
	</div>

	<div class="store-dropdown-container">
		<div class="dropdown" style="cursor: pointer" onclick="toggleDropdown(event)">
			<div class="current-store-container">
				<div class="current-store-name">
					<c:choose>
						<c:when test="${not empty currentStore}">
              ${currentStore.storeName}
            </c:when>
						<c:otherwise>상점 없음</c:otherwise>
					</c:choose>
				</div>
				<img id="dropdownIcon" src="${cpath}/resources/images/icons/drop-down.svg"
					class="dropdown-icon" />
			</div>

			<ul class="dropdown-menu" id="storeDropdown" style="display: none;">
				<c:forEach var="store" items="${storeList}">
					<li data-id="${store.storeId}" data-name="${store.storeName}"
						onclick="selectStore(this, event)">${store.storeName}</li>

				</c:forEach>
			</ul>
		</div>

		<div style="cursor: pointer" class="store-change-btn" onclick="changeSelectedStore()">변경</div>
	</div>
</div>

<!-- 모달 영역 -->
<div id="resultModal2">
	<p id="modalMsg2"></p>
	<button id="closeModalBtn2">확인</button>
</div>

<!-- 모달 배경 -->
<div id="modalBackdrop2"></div>

<script>
  const storeList = [
    <c:forEach var="store" items="${storeList}" varStatus="status">
      {
        storeId: ${store.storeId},
        storeName: "${store.storeName}"
      }<c:if test="${!status.last}">,</c:if>
    </c:forEach>
  ];
</script>


<script>
let dropdownVisible = false;
let selectedStoreId = null;

function toggleDropdown(event) {
  event.stopPropagation();
  const dropdown = document.getElementById('storeDropdown');
  const icon = document.getElementById('dropdownIcon');
  dropdownVisible = !dropdownVisible;
  dropdown.style.display = dropdownVisible ? 'block' : 'none';

  if (dropdownVisible) {
	    icon.src = `${cpath}/resources/images/icons/drop-up.svg`; 
	    document.addEventListener("click", handleOutsideClick);
	  } else {
	    icon.src = `${cpath}/resources/images/icons/drop-down.svg`; 
	    document.removeEventListener("click", handleOutsideClick);
	  }
}

function handleOutsideClick(event) {
  const dropdown = document.getElementById("storeDropdown");
  const dropdownArea = document.querySelector(".dropdown");

  if (!dropdownArea.contains(event.target)) {
    dropdown.style.display = "none";
    dropdownVisible = false;
    document.removeEventListener("click", handleOutsideClick);
  }
}

function selectStore(element, event) {
  if (event) event.stopPropagation();

  const storeId = element.getAttribute('data-id');
  const storeName = element.getAttribute('data-name');
  selectedStoreId = storeId;

  // 드롭다운 닫기
  const dropdown = document.getElementById('storeDropdown');
  const icon = document.getElementById('dropdownIcon'); 
  dropdown.style.display = 'none';
  dropdownVisible = false;
  icon.src = `${cpath}/resources/images/icons/drop-down.svg`; 
  document.removeEventListener("click", handleOutsideClick);

  // 이름 반영
  const nameBox = document.querySelector('.current-store-name');
  nameBox.textContent = storeName;

}


function changeSelectedStore() {
  if (!selectedStoreId) {
	  showModalMessage("변경할 상점을 선택해주세요.");
    return;
  }

  fetch(`${cpath}/seller/store/changeStore`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ storeId: selectedStoreId })
  })
    .then(res => res.text())
    .then(msg => {
    	showModalMessage("상점이 변경되었습니다.", () => location.reload());
    })
    .catch(err => {
      console.error("상점 변경 실패:", err);
      showModalMessage("상점 변경 실패: " + err);
    });
}

function showModalMessage(message, callback) {
	  const modal = document.getElementById('resultModal2');
	  const backdrop = document.getElementById('modalBackdrop2');
	  const modalMsg = document.getElementById('modalMsg2');
	  const closeBtn = document.getElementById('closeModalBtn2');

	  modalMsg.textContent = message;
	  modal.style.display = 'flex';
	  backdrop.style.display = 'block';

	  // 확인 버튼 클릭 시 모달 닫고 콜백 실행 (있다면)
	  closeBtn.onclick = function () {
	    modal.style.display = 'none';
	    backdrop.style.display = 'none';
	    if (typeof callback === 'function') callback();
	  };
	} 

</script>
