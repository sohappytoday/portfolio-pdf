# 포트폴리오 프로젝트

지원하는 회사마다 **그 회사 사이트와 비슷한 디자인**으로 다른 포트폴리오 페이지를 만드는 것이 목표입니다.
디자인은 회사마다 다르지만, 내용(경력·프로젝트·스킬 등)은 하나로 공유됩니다.

## 구조

- `portfolio-example/` — **참고용 견본 포트폴리오**(다른 사람이 만든 PDF 등)와 그 분석 문서
  (`*-analysis.md`)를 두는 곳. 사용자 본인의 콘텐츠가 아님. git에 커밋되지 않음 (`.gitignore`).
- `content/` — **사용자 본인의** 실제 포트폴리오 콘텐츠(디자인과 무관, 구조화된 형태). 아직 비어 있음 —
  견본을 분석한다고 여기에 채워 넣지 않는다. 사용자가 직접 작성/수정하며 채워나갈 곳.
- `designs/<company-slug>/research/` — 그 회사 사이트에서 뽑아낸 **디자인 브리프**
  (`design-brief.md`: 컬러·타이포·형태·톤 등, 근거 데이터는 `tokens.md`). 회사 로고/브랜드 자산은
  포함하지 않음 — 스타일 참고용이지 브랜드 복제가 아님. `raw/`(원본 HTML/CSS 스크랩 원본)는 타사
  콘텐츠라 git에 커밋되지 않음 (`.gitignore`).
- `designs/<company-slug>/` (research/ 제외한 나머지) — (아직 없음) 그 회사 스타일로 렌더링한 실제
  포트폴리오 사이트. `content/` + `research/design-brief.md`를 입력으로 삼아야 함 — 아직 구축 전.

## 워크플로

1. `portfolio-example/`에 참고할 견본 PDF가 새로 생기거나 바뀌면 `/analyze-portfolio` 스킬로 그 구조와
   내용을 분석한다 (`.claude/skills/analyze-portfolio/`, 실제 작업은
   `.claude/agents/portfolio-analyzer.md` 에이전트가 수행). 분석 결과는 항상 원본 PDF와 같은 위치
   (`portfolio-example/`)에 저장되며, **`content/`에는 절대 쓰지 않는다.**
2. `content/`는 사용자 본인의 실제 콘텐츠를 담는 곳으로, 견본 분석과는 별개로 직접 작성한다.
3. `content/`를 채운 뒤에는 `/review-portfolio` 스킬로 목표 직무(기본값: DevOps Engineer) 기준
   루브릭에 맞춰 점수와 근거를 리뷰받을 수 있다 (`.claude/skills/review-portfolio/`, 실제 작업은
   `.claude/agents/portfolio-reviewer.md` 에이전트가 수행). 읽기 전용이며 `content/`를 직접 고치지
   않는다.
4. 지원할 회사가 정해지면 `/extract-design` 스킬로 그 회사 사이트의 디자인 언어를 뽑아
   `designs/<company-slug>/research/design-brief.md`로 정리한다 (`.claude/skills/extract-design/`,
   실제 작업은 `.claude/agents/design-extractor.md` 에이전트 + `scripts/extract-css-tokens.sh`
   도구가 수행). 이 브리프 + `content/`를 입력으로 실제 사이트를 만드는 단계는 아직 구축 전.

## 알아둘 것

- 이 환경의 `pdftotext`(xpdf)는 인코딩을 명시하지 않으면 한글이 깨진다. 반드시
  `pdftotext -enc UTF-8 ...`로 실행할 것 (자세한 내용은 `portfolio-analyzer` 에이전트 정의 참고).
- `pdftoppm`(PDF 페이지를 이미지로 렌더링)은 이 환경에 설치되어 있지 않아, PDF를 이미지로 직접 보는
  것은 기본적으로 불가능하다 — 텍스트 추출 기반으로 작업한다.
- 헤드리스 브라우저/스크린샷 도구가 없다 (`node`/`npx`/playwright류 전부 없음). `curl`은 있음. 그래서
  회사 사이트 디자인 추출도 실제 렌더링이 아니라 "HTML + 연결된 CSS 파일을 받아서 색상/폰트/radius/
  shadow 값을 빈도순으로 집계"하는 방식(`extract-css-tokens.sh`)으로 한다 — 신뢰할 수 있는 근거지만
  최종 확정값은 아니므로, 정확도가 중요하면 사용자가 스크린샷을 제공해 보정할 수 있다.
- `.claude/agents/*.md`로 정의한 커스텀 서브에이전트가 이 대화 세션의 Agent 도구에서 이름으로 호출되지
  않을 수 있다 (실제 `claude` CLI에서는 정상 작동). 안 될 경우 `general-purpose` 에이전트에게 해당
  `.md` 파일을 읽고 그대로 따르도록 태스크를 주는 방식으로 우회한다.
