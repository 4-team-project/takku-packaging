package com.takku.project.service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.takku.project.domain.ImageDTO;
import com.takku.project.mapper.ImageMapper;

@Service
public class ImageService {
	
	@Autowired
	private ImageMapper imageMapper;

	@Autowired
	SqlSession sqlSession;
	String namespace = "com.takku.project.mapper.ImageMapper.";

	@Value("${file.upload.path}")
	private String uploadDir;

	// 임시 디렉토리 경로
	@Value("${file.temp.path}")
	private String tempDir;

	private String getFileExtension(String fileName) {
		if (fileName == null || !fileName.contains(".")) {
			return ""; // 확장자 없을 경우
		}
		return fileName.substring(fileName.lastIndexOf("."));
	}

	public ImageDTO storeTempImage(MultipartFile file) {
		if (file.isEmpty())
			return null;

		try {
			String ext = getFileExtension(file.getOriginalFilename());
			String fileName = UUID.randomUUID().toString() + ext; // 오리지널 이름 제거
			File dest = new File(tempDir + File.separator + fileName);
			file.transferTo(dest);

			return ImageDTO.builder().imageUrl(fileName).build(); // 파일명만 저장
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	}

	public String moveImageFromTemp(String oldFileName) throws IOException {
	    File tempFile = new File(tempDir + File.separator + oldFileName);

	    String ext = getFileExtension(oldFileName);
	    String newFileName = UUID.randomUUID().toString() + ext;

	    File finalFile = new File(uploadDir + File.separator + newFileName);

	    if (tempFile.exists()) {
	        boolean success = tempFile.renameTo(finalFile);
	        if (!success)
	            throw new IOException("파일 이동 실패: " + oldFileName);
	        return "/image/" + newFileName; // 🔥 여기서 URL을 붙여줌
	    } else {
	        throw new IOException("임시 파일 존재하지 않음: " + oldFileName);
	    }
	}

	public ImageDTO storeImage(MultipartFile file, Integer productId, Integer fundingId, Integer reviewId) {
		if (file.isEmpty())
			return null;

		try {
			String ext = getFileExtension(file.getOriginalFilename());
			String fileName = UUID.randomUUID().toString() + ext; // 한글 없는 이름
			File dest = new File(uploadDir + File.separator + fileName);
			file.transferTo(dest);

			return ImageDTO.builder().productId(productId).fundingId(fundingId).reviewId(reviewId)
					.imageUrl("/image/" + fileName).build();

		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	} 

	public void updateFundingIdByImageId(Integer imageId, Integer fundingId) {
		Map<String, Object> params = new HashMap<>();
		params.put("imageId", imageId);
		params.put("fundingId", fundingId);
		imageMapper.updateFundingIdByImageId(imageId, fundingId);
	}

	//로컬 사진 저장 + DB 사진 저장 
	  public List<ImageDTO> storeImages(MultipartFile[] files, Integer productId, Integer fundingId, Integer reviewId) {
	        List<ImageDTO> savedImages = new ArrayList<>();

	        if (files != null) {
	            for (MultipartFile file : files) {
	                if (!file.isEmpty()) {
	                    try {
	                        String ext = getFileExtension(file.getOriginalFilename());
	                        String fileName = UUID.randomUUID().toString() + ext;
	                        File dest = new File(uploadDir + File.separator + fileName);
	                        file.transferTo(dest);

	                        ImageDTO image = ImageDTO.builder()
	                                .productId(productId)
	                                .fundingId(fundingId)
	                                .reviewId(reviewId)
	                                .imageUrl("/image/" + fileName)
	                                .build();

	                        this.insertImageUrl(image);
	                        savedImages.add(image);

	                    } catch (IOException e) {
	                        e.printStackTrace();
	                    }
	                }
	            }
	        }

	        return savedImages;
	    }
	


	public int insertImageUrl(ImageDTO image) {
		int result = sqlSession.insert(namespace + "insertImageUrl", image);
		return result;
	}


	public int deleteImageUrl(String imageUrl) {
		int result = sqlSession.delete(namespace + "deleteImageUrl", imageUrl);
		return result;
	}


	public List<ImageDTO> selectImagesByFundingId(int fundingId) {
		List<ImageDTO> imagelist = sqlSession.selectList(namespace + "selectImagesByFundingId", fundingId);
		return imagelist;
	}


	public List<ImageDTO> selectImagesByReviewId(int reviewId) {
		List<ImageDTO> imagelist = sqlSession.selectList(namespace + "selectImagesByReviewId", reviewId);
		return imagelist;
	}

	
	public List<ImageDTO> selectImagesByProductId(int productId) {
		List<ImageDTO> imagelist = sqlSession.selectList(namespace + "selectImagesByProductId", productId);
		return imagelist;
	}

}
