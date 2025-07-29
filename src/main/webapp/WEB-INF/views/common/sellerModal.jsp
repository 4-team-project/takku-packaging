<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<input type="hidden" id="storeId" value="${storeDTO.storeId}" />
<style>
.modal {
	position: fixed;
	z-index: 1000;
	left: 0;
	top: 0;
	width: 100vw;
	height: 100vh;
	background: rgba(0, 0, 0, 0.4);
	display: flex;
	justify-content: center;
	align-items: center;
	font-family: 'Spoqa Han Sans Neo';
}

.modal-content {
	background: #ffffff;
	border: 3px solid #2e2e3a;
	border-radius: 12px;
	width: 600px;
	padding: 30px 30px 20px 30px;
	box-shadow: 6px 6px 0 #FF9670;
	position: relative;
}

.modal-title {
	font-size: 22px;
	font-weight: bold;
	margin-bottom: 16px;
	border-bottom: 2px solid #2e2e3a;
	padding-bottom: 12px;
	color: #2e2e3a;
	display: flex;
	align-items: center;
	justify-content: center;
}

.close {
	position: absolute;
	top: 18px;
	right: 24px;
	font-size: 24px;
	font-weight: bold;
	color: #2e2e3a;
	cursor: pointer;
}

.modal-info {
	background: #fff6f0;
	border: 2px solid #FF9670;
	border-radius: 12px;
	padding: 20px;
	margin-bottom: 20px;
	text-align: left;
	box-shadow: 2px 2px 0 #FF9670;
}

.modal-info p {
	font-size: 20px;
	margin-bottom: 12px;
	display: flex;
	align-items: flex-start;
	font-weight: 600;
}

.modal-info strong {
	width: 90px;
	color: #ff9670;
	flex-shrink: 0;
	font-size: 24px;
}

.modal-info span {
	word-break: break-word;
	flex: 1;
	color: #333;
}

.cancel-guide {
	color: #f4795c;
	font-size: 18px;
	margin-top: 8px;
}

.modal-buttons {
	display: flex;
	justify-content: space-between;
	gap: 12px;
	margin-top: 16px;
}

.modal-btn {
	flex: 1;
	padding: 14px 0;
	border-radius: 8px;
	font-size: 18px;
	font-weight: bold;
	cursor: pointer;
	border: 2px solid #2e2e3a;
	transition: all 0.2s ease;
}

.modal-btn.cancel {
	background: #fff;
	color: #ff9670;
}

.modal-btn.cancel:hover {
	background-color: #ffc2a1;
	color: white;
}

.modal-btn.confirm {
	background: #ff9670;
	color: white;
}

.modal-btn.confirm:hover {
	background-color: #ffc2a1;
	color: #fff;
}

.modal-btn:active {
	transform: translate(2px, 2px);
	box-shadow: 2px 2px 0 #2e2e3a;
}
</style>

<div id="commonModal" class="modal" style="display: none;">
  <div class="modal-content">
    <span class="close" onclick="closeModal()">&times;</span>
    <div class="modal-title" id="modalTitle">제목</div>
    <div class="modal-body" id="modalBody">본문 내용</div>
    <div class="modal-buttons">
      <button class="modal-btn cancel" id="modalTitleCancelBtn" onclick="closeModal()">취소</button>
      <button class="modal-btn confirm" id="modalConfirmBtn">확인</button>
    </div>
  </div>
</div>

<script>
function openModal({ 
	  title = "알림", 
	  body = "", 
	  onConfirm = null,
	  cancelText = "취소", 
	  confirmText = "확인" 
	}) {
	  document.getElementById("modalTitle").innerText = title;
	  document.getElementById("modalBody").innerHTML = body;
	  document.getElementById("modalTitleCancelBtn").innerText = cancelText;
	  document.getElementById("modalConfirmBtn").innerText = confirmText;

	  const confirmBtn = document.getElementById("modalConfirmBtn");
	  const newConfirm = onConfirm || closeModal;
	  confirmBtn.onclick = newConfirm;

	  document.getElementById("commonModal").style.display = "flex";
	}

	function closeModal() {
	  document.getElementById("commonModal").style.display = "none";
	}

</script>
