# content/ 스키마

이 디렉토리는 **디자인과 무관한 사용자 본인의 원본 콘텐츠**를 담습니다. 회사별로 다른 디자인
(`designs/<company>/`)을 만들 때, 디자인 에이전트는 이 디렉토리만 읽어서 각 회사 스타일에 맞는
페이지를 구성합니다. 즉:

- 여기 내용을 고치면 → 모든 회사별 디자인에 반영되어야 함 (내용 수정)
- 디자인만 바꾸고 싶다면 → 이 디렉토리는 건드리지 않고 `designs/<company>/` 쪽만 작업

## 출처

2026-08-13, 사용자 본인이 실제 배포 중인 포트폴리오 사이트 **https://geo-portfolio.co.kr**
(Next.js, Home/Experience/Projects/Profile 4개 페이지 구조)에서 가져와 채웠습니다. WebFetch로
가져온 내용이라 완전히 글자 그대로가 아닐 수 있습니다 — 이력서 등에 그대로 복사해 쓰기 전에는
원 사이트와 대조해 확인하세요.

## 파일 구조

```
content/
  profile.md              # 이름/직함/연락처/학력/자기소개/개발 마인드셋
  skills.md                 # 카테고리별 기술 스택
  experience.md             # 경력·활동 타임라인
  projects/
    01-ha-kubernetes-iac.md # IaC 기반 HA 쿠버네티스 클러스터 구축
    02-geo-portfolio.md     # 포트폴리오 웹사이트 제작 (지금 이 작업과 같은 종류의 프로젝트)
```

새 프로젝트가 생기면 `projects/NN-slug.md` 형식으로 번호를 이어서 추가합니다.

## TODO — 아직 사이트에 없어서 content/에도 없는 것

본인 확인(2026-08-13): 실제 사이트(geo-portfolio.co.kr)엔 아직 안 올라갔지만 존재하는 프로젝트/경력이
있음. 나중에 상세 내용을 받아서 `projects/03-…`, `04-…`로 추가할 것.

- **Cardinal 프로젝트** (2026.07 – 2026.09) — 상세 내용 미정리
- **멋사 서강대 웹사이트** (2026.01 – 2026.03) — 상세 내용 미정리
- **2025년 프로젝트** — 어떤 프로젝트인지 및 상세 내용 미정리

## 참고 — 이미 검증된 정보 구조(IA)

원본 사이트가 이미 **Home / Experience / Projects / Profile** 4페이지 구조로 운영되고 있고, 본인이
그 구조를 실제로 써온 것이므로, 회사별 디자인도 별도 요청이 없는 한 이 IA를 기본값으로 유지하는 게
합리적입니다 (완전히 새 구조를 설계하기보다).

## Frontmatter 규칙

모든 파일은 YAML frontmatter + Markdown 본문 구조를 씁니다.

- `profile.md`: `name`, `role_tagline`, `contact: {email, phone, github, blog}`,
  `education: [{period, school, program}]`, `gpa`, `certifications: [...]`
- `skills.md`: `categories: [{name, items: [...]}]`
- `experience.md`: 본문에 `## Career`(회사/조직 + 기간 + 역할 + 업무), `## Education` 섹션
- `projects/*.md`: `order`, `id`, `title`, `period`, `team`, `role`, `stack: [...]`, `github: [...]`.
  본문은 `## Overview`, `## 아키텍처`(또는 Solution), `## 결론`(Result/Impact), `## Troubleshooting`,
  `## Tech Stack` 같은 공통 섹션을 원 사이트 구조 그대로 따른다.

## 언어

원문이 한국어이므로 콘텐츠도 한국어로 유지합니다.
