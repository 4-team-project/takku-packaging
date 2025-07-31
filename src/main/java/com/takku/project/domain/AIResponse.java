package com.takku.project.domain;

import java.util.Arrays;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AIResponse {
	private String title;
	private String content;
	private List<String> hashtags;

	public List<String> getHashtags() {
		return hashtags;
	}

	public void setHashtags(String hashtagsStr) {
		if (hashtagsStr != null && !hashtagsStr.isEmpty()) {
			this.hashtags = Arrays.asList(hashtagsStr.trim().split("\\s+"));
		}
	}
}