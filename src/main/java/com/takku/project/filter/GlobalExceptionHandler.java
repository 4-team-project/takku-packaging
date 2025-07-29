package com.takku.project.filter;

import com.takku.project.errorcode.ErrorCode;
import com.takku.project.exception.BusinessException;
import com.takku.project.util.ErrorResponse;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

//@ControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(BusinessException.class)
	public ModelAndView handleBusinessException(BusinessException ex) {
		ErrorResponse response = ErrorResponse.of(ex.getErrorCode(), ex.getMessage());
		ModelAndView mav = new ModelAndView("error.error");
		mav.addObject("error", response);
		return mav;
	}

	@ExceptionHandler(Exception.class)
	public ModelAndView handleException(Exception ex) {
		ErrorResponse response = ErrorResponse.of(ErrorCode.INTERNAL_ERROR, ex.getMessage());
		ModelAndView mav = new ModelAndView("error.error");
		mav.addObject("error", response);
		return mav;
	}
}
