# result/ — 최종 산출물

`content/`(원본 사실)와 `designs/<slug>/research/`(그 회사 스타일 분석)는 **입력**입니다. 절대 회사별로
자동 수정되지 않습니다. 다듬어지거나 만들어진 **산출물**은 전부 여기 `result/` 아래에 둡니다.

```
result/
  content/
    NN-slug.md            # 포트폴리오 페이지 1개 = 파일 1개. 파일명이 곧 페이지 번호/순서.
                           # 회사가 달라져도 내용은 거의 안 바뀌므로 회사별로 나누지 않고 하나만 둔다.
  design/
    <company-slug>/
      pages/
        NN-slug.html       # result/content/NN-slug.md와 같은 번호/slug — 1:1 대응
        NN-slug.png         # QA용 스크린샷
        theme.css            # 전 페이지 공유 스타일시트
      portfolio-N.pdf       # 최종 산출물 (페이지별 개별 PDF, N = 페이지 번호)
```

## 왜 페이지별인가

`content/`는 주제별(프로필/경력/스킬/프로젝트)로 정리된 원본이지만, `result/content/`는 **실제
포트폴리오에 들어갈 페이지 단위**로 다시 나눈 최종본입니다. 예를 들어 프로젝트 하나가 내용이 많으면
`content/`에서는 파일 하나(`projects/01-....md`)였어도, `result/content/`에서는 여러 페이지
(`05-project1-cover.md`, `06-project1-terraform.md`, …)로 쪼개집니다. 이렇게 하면:

- 페이지 계획(어떤 내용이 몇 번째 페이지에 들어가는지)과 그 페이지의 콘텐츠가 한 파일에 합쳐져서
  별도 매니페스트가 필요 없다 — 파일 목록 자체가 목차다.
- `result/design/<slug>/pages/NN-slug.html`이 `result/content/NN-slug.md`와 같은 이름을 쓰므로,
  어떤 페이지가 어떤 콘텐츠를 쓰는지 파일명만 보고 바로 알 수 있다.

## 원칙

- `content/*.md`는 여기서 절대 수정하지 않는다. 다듬은 최종본이 필요하면 `result/content/`에
  파생 페이지를 새로 쓴다 (원본에서 필요한 부분을 가져와 페이지 단위로 재구성 + 문장을 다듬음).
- 페이지 번호/순서가 바뀌면 `result/content/`의 파일명도 그에 맞춰 다시 번호를 매긴다 — 파일명이
  곧 순서이므로 어긋나면 안 된다.
- 특정 회사만을 위해 콘텐츠를 다르게 써야 하는 예외적인 경우가 생기면, 그때 `result/design/<slug>/`
  안에 그 회사 전용 override를 두고 이유를 주석으로 남긴다 (기본은 `result/content/`가 모든 회사에
  공유된다는 전제).
- `result/design/<slug>/`은 `designs/<slug>/research/design-brief.md`를 스타일 근거로 삼아 만든
  실제 사이트/PDF 산출물이다. 브랜드 자산(로고 등)은 여기에도 들어가면 안 된다 — design-brief의
  Do/Don't를 그대로 따른다.
