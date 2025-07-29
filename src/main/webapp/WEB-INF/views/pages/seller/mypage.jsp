<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<link rel="stylesheet"
	href="${cpath}/resources/css/pages/seller/mypage.css">

<script>
	$(function() {
		//비밀번호 형식검사
		const $newPw = $("#newPasswordInput");
		const $lengthWarn = $("#passwordLengthWarning");
		const $patternWarn = $("#passwordPatternWarning");

		// 실시간 입력 검사
		$newPw.on("input", function() {
			const val = $newPw.val();

			// 초기화
			$lengthWarn.hide();
			$patternWarn.hide();

			if (val.length > 0 && val.length < 6) {
				$lengthWarn.show();
			} else if (val.length >= 6) {
				// 영문+숫자 포함 체크
				const pattern = /^(?=.*[A-Za-z])(?=.*\d).+$/;
				if (!pattern.test(val)) {
					$patternWarn.show();
				}
			}
		});

		// 폼 제출 시 검사 및 모달 띄우기
		$("form").on("submit", function(e) {
			const val = $newPw.val();

			if (val.length > 0) {
				if (val.length < 6) {
					e.preventDefault();
					$("#passwordLengthWarning").show();
					$("#passwordPatternWarning").hide();
					$("#modalMsg").text("비밀번호 형식이 올바르지 않습니다.");
					$("#resultModal, #modalBackdrop").fadeIn();
					return false;
				}

				const pattern = /^(?=.*[A-Za-z])(?=.*\d).+$/;
				if (!pattern.test(val)) {
					e.preventDefault();
					$("#passwordLengthWarning").hide();
					$("#passwordPatternWarning").show();
					$("#modalMsg").text("비밀번호 형식이 올바르지 않습니다.");
					$("#resultModal, #modalBackdrop").fadeIn();
					return false;
				}
			}

			// 비밀번호가 비었거나 올바르면 통과
		});

		// 새 비밀번호 토글
		const $newPassword = $("#newPasswordInput");
		const $toggleNew = $("#toggleNewPassword");

		let isNewShown = false;

		$toggleNew.on("click", function() {
			if (isNewShown) {
				$newPassword.attr("type", "password");
				$toggleNew.find("img").attr("src",
						"${cpath}/resources/images/eye.svg");
			} else {
				$newPassword.attr("type", "text");
				$toggleNew.find("img").attr("src",
						"${cpath}/resources/images/eye-off.svg");
			}
			isNewShown = !isNewShown;
		});
	});

	$(function() {
		const updateSuccess = "${updateSuccess}";
		if (updateSuccess === 'true') {
			$("#resultModal, #modalBackdrop").fadeIn();
		}

		$("#closeModalBtn").on("click", function() {
			$("#resultModal, #modalBackdrop").fadeOut();
		});
	});

	$(function() {
		let actionType = ""; // 'register' or 'cancel'

		$("#registerPartnerBtn")
				.on(
						"click",
						function() {
							actionType = "register";
							$("#modalTitle").text("파트너 등록");
							$("#modalDesc")
									.html(
											"파트너 등록 시 판매가 가능해지며, 수수료 약관에 동의한 것으로 간주됩니다.<br>계속 진행하시겠습니까?");
							$("#confirmPartnerBtn").text("등록");
							$("#agreeCheckbox").prop("checked", false); // 체크 해제 초기화
							$("#partnerModal, #modalBackdrop").fadeIn();
						});

		// 해지 버튼 클릭 시
		$("#cancelPartnerTriggerBtn").on("click", function() {
			actionType = "cancel";
			$("#modalTitle").text("파트너 해지");
			$("#modalDesc").html("파트너를 해지하면 판매 기능이 비활성화됩니다.<br>계속 진행하시겠습니까?");
			$("#confirmPartnerBtn").text("해지");
			$("#agreeCheckbox").prop("checked", false); // 체크 해제 초기화
			$("#partnerModal, #modalBackdrop").fadeIn();
		});

		$("#cancelPartnerBtn, #partnerCloseBtn").on("click", function() {
			$("#partnerModal, #modalBackdrop").fadeOut();
		});

		$("#confirmPartnerBtn").on(
				"click",
				function() {
					if (!$("#agreeCheckbox").is(":checked")) {
						$("#partnerModal").fadeOut();
						$("#modalMsg").html("약관에 동의해야 진행할 수 있습니다.");
						$("#resultModal").fadeIn();
						$("#closeModalBtn").off("click").on("click",
								function() {
									$("#resultModal").fadeOut();
									$("#partnerModal").fadeIn();
								});
						return;
					}

					$.ajax({
						type : "POST",
						url : "${cpath}/seller/partner/change",
						data : {
							action : actionType
						},
						success : function(res) {
							if (res === "success") {
								$("#partnerModal").fadeOut();
								$("#modalMsg").html("처리가 완료되었습니다.");
								$("#resultModal").fadeIn();
								$("#closeModalBtn").off("click").on(
										"click",
										function() {
											$("#resultModal").fadeOut(
													function() {
														location.reload(); // 성공 시 리로드
													});
										});
							} else {
								$("#partnerModal").fadeOut();
								$("#modalMsg").html("처리에 실패했습니다.");
								$("#resultModal").fadeIn();
								$("#closeModalBtn").off("click").on("click",
										function() {
											$("#resultModal").fadeOut();
										});
							}
						},
						error : function() {
							$("#modalMsg").html("에러가 발생했습니다.");
							$("#resultModal").fadeIn();
							$("#closeModalBtn").off("click").on("click",
									function() {
										$("#resultModal").fadeOut();
									});
						}
					});
				});
	});
</script>

<div class="mypage-container">
	<div style="display: flex; align-items: center; gap: 20px;">
		<img src="${cpath}/resources/images/mypage.svg" alt="mypage" />
		<h2 style="margin: 0;">
			<span style="color: #ff9670">${loginUser.name}</span>님의 기본 정보를 확인할 수
			있습니다. <br> 정보가 바뀌었다면 수정 후 <strong style="color: #ff9670">'수정하기'</strong>
			버튼을 눌러주세요.
		</h2>
	</div>

	<form action="${cpath}/seller/mypage/update" method="post">
		<input type="hidden" name="userId" value="${loginUser.userId}" />

		<!-- 이름 -->
		<div class="user-info">
			<label>이름</label>
			<div class="input-group">
				<span class="readonly-text">${loginUser.name}</span>
			</div>
		</div>

		<!-- 전화번호 -->
		<div class="user-info">
			<label>전화번호(ID)</label>
			<div class="input-group">
				<span class="readonly-text">${loginUser.phone}</span>
			</div>
		</div>

		<!-- 생년월일 -->
		<div class="user-info">
			<label>생년월일</label>
			<div class="input-group">
				<span class="readonly-text"> <fmt:formatDate
						value="${loginUser.birth}" pattern="yyyy-MM-dd" />
				</span>
			</div>
		</div>

		<!-- 성별 -->
		<div class="user-info">
			<label>성별</label>
			<div class="input-group">
				<span class="readonly-text">${loginUser.gender}</span>
			</div>
		</div>
		<div class="line"></div>
		<!-- 닉네임 (수정 가능) -->
		<div class="user-info">
			<label>닉네임</label>
			<div class="input-group">
				<input type="text" name="nickname" value="${loginUser.nickname}" />
			</div>
		</div>

		<!-- 새 비밀번호 입력 -->
		<div class="user-info">
			<label>새 비밀번호</label>
			<div class="input-group password-group" style="position: relative;">
				<input type="password" id="newPasswordInput" name="newPassword"
					placeholder="새 비밀번호를 입력해주세요" /> <span id="toggleNewPassword"
					style="position: absolute; right: 10px; top: 50%; transform: translateY(-50%); cursor: pointer;">
					<img src="${cpath}/resources/images/eye.svg" alt="비밀번호 보기"
					width="20" />
				</span>
			</div>
			<div id="passwordLengthWarning"
				style="color: red; font-size: 18px; display: none; margin-top: 5px;">
				최소 6자리 이상이어야 합니다.</div>
			<div id="passwordPatternWarning"
				style="color: red; font-size: 18px; display: none; margin-top: 5px;">
				영문과 숫자를 포함해야 합니다.</div>
		</div>


		<!-- 파트너 여부 -->
		<div class="user-info">
			<label>파트너 여부</label>
			<div class="input-group with-btn">
				<span class="readonly-text">${loginUser.isPartner}</span>

				<c:choose>
					<c:when test="${loginUser.isPartner eq 'N'}">
						<button class="btn side-btn" type="button" id="registerPartnerBtn">등록하기</button>
					</c:when>
					<c:when test="${loginUser.isPartner eq 'Y'}">
						<button class="btn side-btn" type="button"
							id="cancelPartnerTriggerBtn">해지하기</button>
					</c:when>
				</c:choose>
			</div>
		</div>

		<div class="btn-group">
			<button class="btn" type="button" onclick="history.back()">이전</button>
			<button class="btn filled" type="submit">수정</button>
		</div>
	</form>
</div>

<!-- 모달 영역 -->
<div id="resultModal">
	<p id="modalMsg">회원 정보가 수정되었습니다.</p>
	<button id="closeModalBtn">확인</button>
</div>

<!-- 파트너 등록/해지 모달 -->
<div id="partnerModal" class="modal" style="display: none;">
	<div class="modal-content">
		<span id="partnerCloseBtn" class="close">&times;</span>
		<h2 id="modalTitle" class="modal-title">파트너 등록 계약</h2>

		<div class="modal-info" id="modalDesc"></div>

		<div style="margin-top: 15px;">
			<label><input type="checkbox" id="agreeCheckbox" /> 약관에
				동의합니다.</label>
		</div>

		<div class="modal-buttons" style="margin-top: 20px;">
			<button id="cancelPartnerBtn" type="button" class="modal-btn cancel">취소</button>
			<button id="confirmPartnerBtn" type="button"
				class="modal-btn confirm">등록</button>
		</div>
	</div>
</div>


<!-- 모달 배경 -->
<div id="modalBackdrop"></div>
