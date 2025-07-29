package com.takku.project.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SwaggerRedirectController {

	@GetMapping("/swagger")
	public String redirectSwagger() {
		return "redirect:/swagger-ui.html?url=/project/v2/api-docs";
	}

}
