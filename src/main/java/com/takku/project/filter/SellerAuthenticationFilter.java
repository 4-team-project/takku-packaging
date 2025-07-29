package com.takku.project.filter;

import java.io.IOException;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.takku.project.domain.UserDTO;

@WebFilter(urlPatterns = "/seller/*")
public class SellerAuthenticationFilter implements Filter {

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse res = (HttpServletResponse) response;
		HttpSession session = req.getSession(false);

		String cpath = req.getContextPath();
		String uri = req.getRequestURI();

		// 1. 로그인 안 되어 있으면 로그인 페이지로
		if (session == null || session.getAttribute("loginUser") == null) {
			res.sendRedirect(cpath + "/auth/login?msg=needLogin");
			return;
		}

		UserDTO loginUser = (UserDTO) session.getAttribute("loginUser");

		// 2. 소상공인이 아닌 사용자가 /seller 경로 접근 시 로그인 페이지로
		if (!"소상공인".equals(loginUser.getUserType())) {
			res.sendRedirect(cpath + "/auth/login?msg=needLogin");
			return;
		}

		// 3. 소상공인인데 store 정보가 없고 현재 uri가 /seller/home 또는 /seller/store/new가 아니면 →
		// /seller/home으로
		Object store = session.getAttribute("store");
		if (store == null && !uri.endsWith("/seller/home") && !uri.endsWith("/seller/store/new")) {

			res.sendRedirect(cpath + "/seller/home?msg=needStore");
			return;
		}

		// 조건 통과 시 다음 필터 또는 컨트롤러 실행
		chain.doFilter(request, response);
	}

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		// 초기화 필요 시 작성
	}

	@Override
	public void destroy() {
		// 자원 해제 필요 시 작성
	}
}
