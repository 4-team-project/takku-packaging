<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<style>
.btn-box {
	display: flex;
	justify-content: space-between;
}

.back-btn {
	bottom: 0;
	width: 90px;
	height: 60px;
	border: 2px solid #2E2E3A;
	border-radius: 8px;
	background-color: #FF9670;
	display: flex;
	justify-content: center;
	align-items: center;
	color: #FFFFFF;
	font-family: 'Spoqa Han Sans Neo';
	font-weight: 500;
	font-size: 18px;
	filter: drop-shadow(0 2px 6px rgba(0, 0, 0, 0.1));
	cursor: pointer;
}
</style>

<div class="btn-box">
	<div class="back-btn" id="backBtn">이전</div>
</div>

<script>
  document.getElementById('backBtn').addEventListener('click', function () {
    history.back(); 
  });
</script>
