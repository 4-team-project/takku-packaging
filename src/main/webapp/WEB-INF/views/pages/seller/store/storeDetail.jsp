<%@ include file="/WEB-INF/views/common/init.jsp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/sellerAlert.jsp"%>

<script src="${cpath}/resources/js/address.js"></script>
<input type="hidden" id="storeId" value="${storeDTO.storeId}" />
<script
	src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<link rel="stylesheet"
	href="${cpath}/resources/css/pages/seller/productDetail.css">

<div class="main-title-box">
	<div class="main-title" id="formMainTitle">
		새롭게 운영하실 상점의 이름, 주소, 전화번호 등을 입력해 주세요
		<div class="sub-title" id="formSubTitle">모든 정보를 다 입력하신 후 아래
			[등록하기] 버튼을 눌러주시면 등록이 완료됩니다</div>
	</div>
</div>

<div class="content-box">
	<div class="content-text">상점 이름</div>
	<input type="text" id="storeName" placeholder="상점 이름을 입력하세요"
		class="content-input" />
</div>

<div class="content-box">
	<div class="content-text">상점 주소</div>
	<div class="address-section">
		<div class="address-btn-wrapper">
			<button type="button" class="address-btn"
				onclick="execDaumPostcode()">주소 검색</button>
			<button type="button" class="address-btn" id="clearAddressBtn">지우기</button>

		</div>
		<input type="hidden" id="postcode" name="postcode"> <input
			type="hidden" id="sido" name="sido"> <input type="hidden"
			id="sigungu" name="sigungu"> <input type="hidden" id="bname"
			name="bname"> <input type="hidden" id="jibunAddress"
			name="jibunAddress">
		<p>
			<strong>&nbsp&nbsp&nbsp&nbsp&nbsp</strong> <input type="text"
				name="roadAddress" id="roadAddress" class="content-input"
				placeholder="도로명 주소" readonly>
		</p>
		<input type="text" id="detailAddr" class="content-input"
			placeholder="상세 주소를 입력하세요">
	</div>
</div>

<div class="content-box">
	<div class="content-text">상점 소개</div>
	<textarea id="storeDescription" class="content-textarea"
		placeholder="상점 설명은 비워도 괜찮아요&#13;꼭 작성하지 않아도 등록할 수 있어요"></textarea>
</div>

<div class="content-box">
	<div class="content-text">상점 카테고리를 선택해 주세요(한 가지만 선택 가능합니다)</div>
	<div class="category-box" id="storeCategory"></div>
</div>

<div class="content-box">
	<div class="content-text">계좌 번호</div>
	<input type="text" id="accountNumber" placeholder="계좌번호를 입력하세요"
		class="content-input" inputmode="numeric" maxlength="20" />
</div>

<div class="content-box">
	<div class="content-text">사업자등록번호</div>
	<input type="text" id="businessRegistrationNumber"
		placeholder="사업자등록번호를 입력하세요" class="content-input" inputmode="numeric"
		maxlength="12" />
</div>

<div class="complete-back-btn-box">
	<div class="complete-back-btn" style="cursor: pointer"
		onclick="history.back()">이전</div>
	<button id="submitBtn" onclick="submitStore()"
		class="complete-back-btn">수정 완료</button>
</div>

<input type="hidden" id="selectedCategoryId" value="">


<script>
function formatBusinessNumber(value) {
	  return value
	    .replace(/[^0-9]/g, '')        
	    .replace(/^(\d{3})(\d{2})(\d{0,5})$/, '$1-$2-$3') 
	    .replace(/(-)$/, '');            
	}

	function formatAccountNumber(value) {
	  return value
	    .replace(/[^0-9]/g, '')           
	    .replace(/(\d{3})(\d{3})(\d{0,6})/, '$1-$2-$3') 
	    .replace(/(-)$/, '');             
	}

	document.getElementById("businessRegistrationNumber").addEventListener("input", function (e) {
	  e.target.value = formatBusinessNumber(e.target.value);
	});

	document.getElementById("accountNumber").addEventListener("input", function (e) {
	  e.target.value = formatAccountNumber(e.target.value);
	});
</script>

<script>
window.onload = function () {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", "<%=request.getContextPath()%>/resources/data/categories.json", true);
  xhr.onreadystatechange = function () {
    if (xhr.readyState === 4 && xhr.status === 200) {
      var data = JSON.parse(xhr.responseText);
      var container = document.getElementById("storeCategory");
      container.innerHTML = "";

      for (var i = 0; i < data.length; i++) {
        var category = data[i];
        if (category.id === 0) continue; 

        var card = document.createElement("div");
        card.className = "category-card";
        card.setAttribute("data-category-id", category.id);

        var imgDiv = document.createElement("div");
        imgDiv.className = "category-card-img";
        var img = document.createElement("img");
        img.src = "<%=request.getContextPath()%>" + category.image;
        img.alt = category.name;
        imgDiv.appendChild(img);

        var nameDiv = document.createElement("div");
        nameDiv.className = "category-card-name";
        nameDiv.innerText = category.name;

        card.appendChild(imgDiv);
        card.appendChild(nameDiv);

        card.onclick = function () {
          var allCards = document.getElementsByClassName("category-card");
          for (var j = 0; j < allCards.length; j++) {
            allCards[j].classList.remove("selected");
          }
          this.classList.add("selected");

          document.getElementById("selectedCategoryId").value = this.getAttribute("data-category-id");
        };

        container.appendChild(card);
      }
    }
  };
  xhr.send();
};
</script>

<script>

function validateStoreData() {
	  const storeName = document.getElementById('storeName')?.value.trim();
	  const sido = document.getElementById('sido')?.value.trim();
	  const sigungu = document.getElementById('sigungu')?.value.trim();
	  const dong = document.getElementById('bname')?.value.trim();
	  const addressDetail = document.getElementById('detailAddr')?.value.trim();
	  const businessNumber = document.getElementById('businessRegistrationNumber')?.value.trim();
	  const bankAccount = document.getElementById('accountNumber')?.value.trim();
	  const categoryIdStr = document.getElementById('selectedCategoryId')?.value;

	  const missingFields = [];

	  if (!storeName) missingFields.push("상점 이름");
	  if (!sido || !sigungu || !dong) missingFields.push("주소");
	  if (!addressDetail) missingFields.push("상세 주소");
	  if (!businessNumber) missingFields.push("사업자등록번호");
	  if (!bankAccount) missingFields.push("계좌번호");
	  if (!categoryIdStr) missingFields.push("카테고리 선택");

	  return missingFields;
	}
	
function submitStoreData(storeData, storeId) {
	  const url = storeId
	    ? `${cpath}/seller/store/update/${storeId}`
	    : `${cpath}/seller/store/insert`;

	  fetch(url, {
	    method: "POST",
	    headers: { "Content-Type": "application/json" },
	    body: JSON.stringify(storeData)
	  })
	    .then(res => res.text())
	    .then(msg => {
	      if (!isNaN(msg)) {
	    	  const successMessage = storeId
	          ? "상점 정보가 수정되었습니다!"
	          : "상점 등록에 성공했습니다!";
	        showPopupAlert({
	          type: 'success',
	          message: successMessage,
	          onConfirm: () => {
	            location.href = document.referrer;
	          }
	        });
	      } else {
	        showPopupAlert({
	          type: 'error',
	          message: msg,
	        });
	      }
	    })
	    .catch(err => {
	      showPopupAlert({
	        type: 'error',
	        message: '서버 오류입니다',
	      });
	    });
	}
	
function submitStore() {
	  const storeId = document.getElementById("storeId")?.value || null;

	  const missingFields = validateStoreData();
	  if (missingFields.length > 0) {
		  showPopupAlert({
			    type: 'warning',
			    message: "다음 항목을 입력해 주세요:\n- " +missingFields.join("\n- "),
	  })
	    return;
	  }

	  const storeData = {
	    storeId: storeId,
	    storeName: document.getElementById('storeName').value.trim(),
	    sido: document.getElementById('sido').value.trim(),
	    sigungu: document.getElementById('sigungu').value.trim(),
	    dong: document.getElementById('bname').value.trim(),
	    addressDetail: document.getElementById('detailAddr').value.trim(),
	    description: document.getElementById('storeDescription')?.value.trim() || "",
	    businessNumber: document.getElementById('businessRegistrationNumber').value.trim(),
	    bankAccount: document.getElementById('accountNumber').value.trim(),
	    categoryId: parseInt(document.getElementById('selectedCategoryId').value)
	  };

	  submitStoreData(storeData, storeId);
	}


document.addEventListener('DOMContentLoaded', () => {
	  const storeId = document.getElementById("storeId")?.value;
	  const submitBtn = document.getElementById("submitBtn");
	  if (submitBtn) {
	    submitBtn.textContent = storeId ? "수정 완료" : "등록 완료";
	  }
	 
	  const subTitle = document.getElementById("formSubTitle");


	  if (subTitle) {
	    subTitle.textContent = storeId
	      ? "수정할 내용을 입력하신 후 아래 [수정 완료] 버튼을 눌러주세요"
	      : "모든 정보를 다 입력하신 후 아래 [등록 완료] 버튼을 눌러주시면 등록이 완료됩니다";
	  }

	  if (storeId) {
	    fetch(`${cpath}/seller/store/info/${storeId}`)
	      .then(res => res.json())
	      .then(store => {

	        document.getElementById('storeName').value = store.storeName;
	       
	        document.getElementById('roadAddress').value = store.roadAddress;
	        document.getElementById('detailAddr').value = store.addressDetail;
	        document.getElementById('storeDescription').value = store.description;
	        document.getElementById('accountNumber').value = store.bankAccount;
	        document.getElementById('businessRegistrationNumber').value = store.businessNumber;
	        document.getElementById('sido').value = store.sido;
	        document.getElementById('sigungu').value = store.sigungu;
	        document.getElementById('bname').value = store.dong;
	        
	        document.getElementById('roadAddress').value = 
	            [store.sido, store.sigungu, store.dong].filter(Boolean).join(' ');

	        const selectedId = store.categoryId;
	        document.getElementById("selectedCategoryId").value = selectedId;

	        
	        const mainTitle = document.getElementById("formMainTitle");
	        if (mainTitle && mainTitle.firstChild?.nodeType === 3) {
	          mainTitle.firstChild.textContent = `상점의 상세정보입니다`;
	        }
	        
	        setTimeout(() => {
	          const cards = document.querySelectorAll('.category-card');
	          cards.forEach(card => {
	            if (card.getAttribute('data-category-id') == selectedId) {
	              card.classList.add('selected');
	            }
	          });
	        }, 300); 
	      });
	  }
	});

</script>
