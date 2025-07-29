<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<link rel="stylesheet" type="text/css"
	href="${cpath}/resources/css/components/searchBox.css">
</head>
<body>
<div class="search-box">
	<input class="search-text" id="searchText" type="text" placeholder="검색하기">
	<div class="search-button" id="searchButton" onclick="sendSearchData()">
		<div class="search-button-circle">
			<img class="search-icon"
				src="${cpath}/resources/images/icons/search.svg"
				alt="search">
		</div>
	</div>
</div>
</body>
</html>


