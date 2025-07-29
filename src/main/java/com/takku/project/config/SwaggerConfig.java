package com.takku.project.config;

import java.util.Collections;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@Configuration
@EnableSwagger2
public class SwaggerConfig {

	@Bean
	public Docket api() {
		return new Docket(DocumentationType.SWAGGER_2).select()
				.apis(RequestHandlerSelectors.basePackage("com.takku.project.controller")).paths(PathSelectors.any())
				.build().apiInfo(apiInfo());
	}

	private ApiInfo apiInfo() {
		return new ApiInfo("딱쿠 프로젝트 API 문서",
				"딱쿠 프로젝트의 백엔드 API 명세서입니다.\n\n"
						+ "📄 [Notion 문서 보기](https://www.notion.so/DS-_Takku-202a8b541bad8013901ec56455dccf0b)\n"
						+ "💻 [GitHub 저장소 보기](https://github.com/4-team-project/songil)",
				"1.0", "", new Contact("손길 개발팀", "https://github.com/4-team-project/songil", "contact@example.com"), "",
				"", Collections.emptyList());
	}
}
