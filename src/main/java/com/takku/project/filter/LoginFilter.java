//package com.takku.project.filter;
//
//import java.io.IOException;
//import javax.servlet.Filter;
//import javax.servlet.FilterChain;
//import javax.servlet.FilterConfig;
//import javax.servlet.ServletException;
//import javax.servlet.ServletRequest;
//import javax.servlet.ServletResponse;
//import javax.servlet.annotation.WebFilter;
//import javax.servlet.http.HttpServletRequest;
//import javax.servlet.http.HttpServletResponse;
//import javax.servlet.http.HttpSession;
//
//@WebFilter(urlPatterns = {"/", "/*"})
//public class LoginFilter implements Filter {
//
//    @Override
//    public void doFilter(ServletRequest request, ServletResponse response,
//                         FilterChain chain) throws IOException, ServletException {
//
//        HttpServletRequest req = (HttpServletRequest) request;
//        HttpServletResponse res = (HttpServletResponse) response;
//
//        String cpath = req.getContextPath();         // 예: "/myapp"
//        String path = req.getRequestURI();           // 예: "/myapp/mysql/test"
//
//        // 로그인 없이 접근 가능한 경로 예외 처리
//        if (path.startsWith(cpath + "/auth") ||
//        	    path.startsWith(cpath + "/mysql") ||
//        	    path.startsWith(cpath + "/resources") ||
//        	    path.startsWith(cpath + "/favicon.ico")) {
//            chain.doFilter(request, response);
//            return;
//        }
//
//        HttpSession session = req.getSession(false);
//        if (session == null || session.getAttribute("user") == null) {
//            res.sendRedirect(cpath + "/auth/login");
//            return;
//        }
//
//        chain.doFilter(request, response);
//    }
//
//    @Override
//    public void init(FilterConfig filterConfig) throws ServletException { }
//
//    @Override
//    public void destroy() { }
//}
//
