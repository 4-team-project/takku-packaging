package com.takku.project.controller;

import com.takku.project.domain.ImageDTO;
import com.takku.project.service.ImageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/image")
public class ImageController {

	@Autowired
	private ImageService imageService;

	@Value("${file.upload.path}")
	private String uploadPath;

	/**
	 * 1. 이미지 임시 업로드 (temp 폴더로)
	 */
	@PostMapping("/upload")
	public String uploadImage(@RequestParam("file") MultipartFile file) {
		ImageDTO image = imageService.storeTempImage(file); // 임시 저장
		if (image != null) {
			// 클라이언트는 이 파일명을 이후 요청에서 사용
			return image.getImageUrl(); // 파일명만 반환 (예: abc123.jpg)
		}
		throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Upload failed");
	}

	/**
	 * 2. 이미지 제공 (파일명으로 실제 폴더에서 조회) 먼저 /upload/ 에서 찾고, 없으면 /upload/temp/ 에서 찾기
	 */
	@GetMapping("/{fileName:.+}")
	public void viewImage(@PathVariable String fileName, HttpServletResponse response) throws IOException {
		File realFile = new File(uploadPath + fileName);
		File tempFile = new File(uploadPath + "temp" + File.separator + fileName);

		File targetFile = realFile.exists() ? realFile : (tempFile.exists() ? tempFile : null);
		if (targetFile != null) {
			String contentType = Files.probeContentType(targetFile.toPath());
			response.setContentType(contentType != null ? contentType : "application/octet-stream");
			Files.copy(targetFile.toPath(), response.getOutputStream());
			response.getOutputStream().flush();
		} else {
			response.sendError(404, "File not found");
		}
	}

	@PostMapping
	public String insertImage(ImageDTO imageDTO) {
		int result = imageService.insertImageUrl(imageDTO);
		return result > 0 ? "이미지 등록 성공" : "이미지 등록 실패";
	}

	@DeleteMapping
	public String deleteImage(@RequestParam("imageUrl") String imageUrl) {
		int result = imageService.deleteImageUrl(imageUrl);
		return result > 0 ? "이미지 삭제 성공" : "이미지 삭제 실패";
	}

	@GetMapping
	public String showImageForm() {
		return "image_form";
	}
}
