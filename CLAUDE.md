# 포트폴리오 프로젝트

지원하는 회사마다 **그 회사 사이트와 비슷한 디자인**으로 다른 포트폴리오를 만드는 것이 목표입니다.
최종 산출물은 **PDF** — 페이지마다 `portfolio-1.pdf`, `portfolio-2.pdf`, … 로 개별 렌더링합니다
(`portfolio-example/portfolio.pdf` 같은 슬라이드형 포트폴리오 포맷). 디자인은 회사마다 다르지만,
내용(경력·프로젝트·스킬 등)은 하나로 공유됩니다.

## 구조

- `portfolio-example/` — **참고용 견본 포트폴리오**(다른 사람이 만든 PDF 등)와 그 분석 문서
  (`*-analysis.md`)를 두는 곳. 사용자 본인의 콘텐츠가 아님. git에 커밋되지 않음 (`.gitignore`).
- `content/` — **사용자 본인의** 실제 포트폴리오 콘텐츠(디자인과 무관, 구조화된 형태). 사용자의 실제
  배포 사이트 https://geo-portfolio.co.kr (Next.js, Home/Experience/Projects/Profile 구조)에서 가져와
  채워둠 (2026-08-13). 다만 그 사이트에는 아직 없는 프로젝트(Cardinal, 멋사 서강대 웹사이트, 2025년
  프로젝트)가 있으니 `content/README.md`의 TODO를 참고해 계속 채워나갈 것.
- `designs/<company-slug>/research/` — 그 회사 사이트에서 뽑아낸 **디자인 브리프**
  (`design-brief.md`: 컬러·타이포·형태·톤 등, 근거 데이터는 `tokens.md`). 회사 로고/브랜드 자산은
  포함하지 않음 — 스타일 참고용이지 브랜드 복제가 아님. `raw/`(원본 HTML/CSS 스크랩 원본)는 타사
  콘텐츠라 git에 커밋되지 않음 (`.gitignore`). `designs/`는 여기까지만 — 실제 사이트 산출물은 두지
  않는다 (아래 `result/` 참고).
- `result/` — **최종 산출물**. 자세한 규칙은 `result/README.md` 참고.
  - `content/NN-slug.md` — `content/`(주제별 원본)를 실제 포트폴리오 **페이지 단위**로 다시 나누고
    다듬은 최종본 (파일 1개 = 페이지 1개, 파일명이 곧 페이지 순서). 회사가 달라져도 거의 안 바뀌는
    내용이라 회사별로 나누지 않고 하나만 둔다. `content/` 원본은 절대 여기서 수정하지 않는다.
  - `design/<company-slug>/` — `designs/<company-slug>/research/design-brief.md`를 스타일 근거로
    삼아 실제로 만든 포트폴리오. 회사마다 다르므로 회사별 폴더로 나눔.
    - `pages/NN-slug.html` + `.png` — `result/content/NN-slug.md`와 1:1 대응하는 페이지별 소스와
      QA용 스크린샷, `theme.css` 하나를 전 페이지가 공유.
    - `portfolio-N.pdf` — 최종 산출물 (페이지별 개별 PDF).

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
   도구가 수행).
5. 실제 포트폴리오를 만들기 전엔 항상 `/curate-content`로 `result/content/`를 채우거나 갱신한다
   (`.claude/skills/curate-content/`, `content-curator` 에이전트가 `content/`(주제별)를 **페이지
   단위로 나누고** 잘라내고 묻힌 신호를 앞으로 꺼내 `result/content/NN-slug.md`로 쓰고, 이어서
   `portfolio-reviewer`로 점수를 검증한다). 페이지 계획(몇 페이지, 무엇이 어디에)도 이 단계에서
   콘텐츠 밀도를 보고 정해진다 — **없는 사실을 지어내는 건 항상 금지**, 점수를 올리는 게 목표가
   아니라 있는 사실 중 잘 안 보이던 걸 잘 보이게 하는 게 목표.
6. 실제 포트폴리오(PDF)를 만드는 단계는 `/build-portfolio` 스킬로 진행한다 (`.claude/skills/build-portfolio/`,
   `portfolio-builder` 에이전트가 design-brief 기반 공유 스타일시트를 먼저 만들고,
   `result/content/NN-slug.md` 파일 목록을 그대로 페이지 계획으로 읽어(직접 페이지를 다시 나누지
   않음) 페이지마다 HTML → `scripts/render-page.sh`로 PDF+PNG 렌더링 → PNG를 직접 읽어서 페이지 간
   폰트·색·간격 일관성을 QA하는 순서로 진행한다). 결과는 `result/design/<company-slug>/portfolio-N.pdf`.

## 알아둘 것

- 이 환경의 `pdftotext`(xpdf)는 인코딩을 명시하지 않으면 한글이 깨진다. 반드시
  `pdftotext -enc UTF-8 ...`로 실행할 것 (자세한 내용은 `portfolio-analyzer` 에이전트 정의 참고).
- `pdftoppm`(PDF 페이지를 이미지로 렌더링)은 이 환경에 설치되어 있지 않아, PDF를 이미지로 직접 보는
  것은 기본적으로 불가능하다 — 텍스트 추출 기반으로 작업한다.
- `node`/`npm`/`npx`는 없지만, **Chrome과 Edge가 표준 설치 경로에 실제로 깔려 있다** (PATH엔 없음 —
  `C:\Program Files\Google\Chrome\Application\chrome.exe` 등 직접 경로로 호출해야 함). 즉
  `--headless --print-to-pdf`/`--screenshot`로 HTML → PDF/PNG 렌더링이 된다 (한글 렌더링 확인 완료).
  `build-portfolio`의 `render-page.sh`가 이걸 씀. 회사 사이트 디자인 추출(`extract-css-tokens.sh`)은
  여전히 실제 렌더링이 아니라 "HTML + 연결된 CSS 파일에서 색상/폰트/radius/shadow 값을 빈도순으로
  집계"하는 방식이다 — 대상은 우리가 통제 못 하는 남의 사이트라 렌더링보다 정적 분석이 안전하고
  충분함.
- `.claude/agents/*.md`로 정의한 커스텀 서브에이전트가 이 대화 세션의 Agent 도구에서 이름으로 호출되지
  않을 수 있다 (실제 `claude` CLI에서는 정상 작동). 안 될 경우 `general-purpose` 에이전트에게 해당
  `.md` 파일을 읽고 그대로 따르도록 태스크를 주는 방식으로 우회한다.
- **웹폰트를 PDF에 쓸 때 함정이 많다** (전부 실제로 겪고 고침, 자세한 내용은 `portfolio-builder`
  에이전트 정의 참고):
  - CDN `@import`는 `--print-to-pdf`가 로드를 안 기다려서 PDF에서만 시스템 폰트로 조용히 깨짐 (화면
    캡처는 멀쩡해 보임).
  - variable 폰트(`woff2-variations`)는 PDF에서 텍스트가 아니라 벡터 윤곽선으로 그려져서, 보기엔
    멀쩡한데 **텍스트 선택/추출이 아예 안 되는** PDF가 나온다.
  - 그래서 정적 웨이트별 폰트 파일을 base64 data URI로 인라인해야 한다 (`Pretendard-Regular/Medium/
    .../ExtraBold.woff2`, 웨이트별 `@font-face`).
  - 폰트 스택에서 generic 키워드(`monospace`/`sans-serif`)보다 뒤에 이름 있는 폰트를 두면 그 폰트는
    사실상 무시된다 — 반드시 generic 키워드 앞에 둘 것.
  - 같은 출력 경로를 반복 렌더링하면 캐시(디스포저블 프로필 밖 어딘가)가 낡은 "폰트 로드 실패" 결과를
    재현하는 게 관찰됨 — `render-page.sh`가 내부적으로 매번 임시 경로로 렌더링 후 이동하는 방식으로
    이미 우회함.
  - 검증은 PNG만 보지 말고 **실제 PDF**로 할 것 (`grep -a -io "폰트이름" out.pdf`, `pdftotext`로 텍스트
    추출 확인) — PNG와 PDF는 별도 Chrome 프로세스라 결과가 다를 수 있음이 실제로 확인됨.
