<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="/WEB-INF/views/common/init.jsp"%>

<div class="dropdown">
	<button class="dropbtn" id="sidoButton">
		시/도 선택 <img id="dropdownIcon"
			src="${cpath}/resources/images/icons/drop-down-gray.svg"
			class="dropdown-icon" />
	</button>
	<div class="dropdown-content" id="sidoDropdown"></div>
</div>
<div class="dropdown">
	<button class="dropbtn" id="sigunguButton">
		시/군/구 선택 <img id="dropdownIcon"
			src="${cpath}/resources/images/icons/drop-down-gray.svg"
			class="dropdown-icon" />
	</button>
	<div class="dropdown-content" id="sigunguDropdown"></div>
</div>
