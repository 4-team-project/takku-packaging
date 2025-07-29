package com.takku.project.domain.stats;

import java.util.List;

import lombok.Data;

@Data
public class AgeGenderTagDTO {
	private String ageGroup;
	private String gender;
	private List<String> topTags;
}