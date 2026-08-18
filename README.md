# Portfolio PDF workflow

회사마다 다른 분위기로 보이되, 포트폴리오의 사실·페이지 순서·읽기 경험은 유지하는 PDF 제작 시스템입니다.
처음에는 디자인 시스템을 만들고, 지원 회사의 아트 디렉션을 조사한 뒤, 그 결과를 회사별 테마로 적용합니다.

## 먼저 알아둘 것

- `content/`은 원본 사실입니다. 경력, 수치, 역할을 임의로 바꾸지 않습니다.
- `result/content/`은 실제 PDF의 페이지별 텍스트입니다. 현재 13페이지입니다.
- `portfolio-system/`은 모든 회사가 공유하는 레이아웃·컴포넌트·품질 규칙입니다.
- `designs/<company>/research/art-direction/`은 회사 조사의 공식 결과입니다.
- `designs/<company>/application/`은 조사 결과를 CSS 테마와 라이선스 폰트로 바꾼 소스입니다.
- `result/design/<company>/`은 렌더된 산출물입니다. 기존 Toss 산출물은 legacy이므로 덮어쓰지 않습니다.

회사별 테마는 표현만 바꿉니다. 콘텐츠, 페이지 순서, 의미 있는 HTML 구조는 바꾸지 않습니다.

## 전체 흐름

```text
공통 포트폴리오 시스템
  → 공통 시스템 검수
  → 회사 아트 디렉션 추출
  → 아트 디렉션 검수
  → 회사 테마 적용·렌더
  → 적용 결과 검수
  → 승인된 PDF build
```

각 검수의 통과 기준은 “97% 정확도”가 아니라 다음의 운영 기준입니다.

- 결정론 검증 통과
- hard blocker 0개
- 독립 검수자 2명 모두 97/100 이상
- 최종 점수는 두 점수 중 낮은 점수

## 처음 사용하는 사람의 권장 순서

### 1. 공통 시스템을 먼저 준비합니다

Codex에 다음처럼 요청합니다.

```text
$build-common-portfolio-system을 사용해서 공통 포트폴리오 시스템을 점검하고,
result/content의 모든 페이지를 수용하는 중립 레이아웃을 준비해줘.
```

이 단계의 목표는 `portfolio-system/`과 `result/layout/`입니다. `result/layout/`에는
`result/content/`의 각 `NN-slug.md`에 대응하는 회사 중립 HTML이 하나씩 있어야 합니다.
이 HTML은 어느 회사에 지원해도 동일하게 유지됩니다.

작업 뒤에는 다음 검증을 실행합니다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents/skills/build-common-portfolio-system/scripts/validate-portfolio-system.ps1 -RepoRoot .
```

그 다음 `$review-portfolio-system`으로 공통 시스템을 독립 검수합니다.

### 2. 지원할 회사의 아트 디렉션을 추출합니다

예를 들어 Toss Securities에 지원한다면 다음처럼 요청합니다.

```text
$extract-company-art-direction을 사용해서 Toss Securities의 현재 공식 웹·제품·채용 표면을 조사하고,
회사 전체 기준의 아트 디렉션 패키지를 만들어줘.
```

이 흐름은 현재 공식 출처를 조사해 다음 파일을 만듭니다.

```text
designs/toss-securities/research/art-direction/
  sources.md
  art-direction.json
  art-direction.md
  reviews/
  acceptance.json
```

조사 단계에서는 CSS나 PDF를 만들지 않습니다. 독점 폰트, 로고, 슬로건, 제품 UI를 그대로 복사하지 않고,
관찰한 특성을 포트폴리오에 안전하게 적용할 원칙으로 바꿉니다.

완성 뒤에는 `$review-company-art-direction`으로 독립 검수합니다. `acceptance.json`이 hash-matching
`PASS`가 되기 전에는 다음 단계로 넘어가지 않습니다.

### 3. 회사 테마를 적용합니다

아트 디렉션이 승인된 뒤에만 다음을 실행합니다.

```text
$apply-company-art-direction을 사용해서 toss-securities의 승인된 아트 디렉션을 적용해줘.
```

이 단계는 다음을 만듭니다.

```text
designs/toss-securities/application/
  adapter.css
  theme-manifest.json
  font-license.json
  fonts/

result/design/toss-securities/builds/<build-id>/
  inputs.lock.json
  preflight.json
  pages/
  fixtures/
  reviews/
  acceptance.json
```

`adapter.css`에는 회사별 색·타이포그래피 성격·선·라운드·표면감만 들어갑니다. 공통 CSS, 콘텐츠,
페이지 구조, 기존 build는 수정하지 않습니다.

중립 레이아웃이 아직 없으면 `adapter-proof`만 가능합니다. 이는 sparse/dense fixture에서 테마 호환성을
확인하는 단계이며, 최종 포트폴리오 PDF 승인은 아닙니다. 13개 중립 레이아웃이 모두 있을 때만
`portfolio-render`로 전체 PDF를 만들 수 있습니다.

### 4. 렌더된 결과를 검수합니다

```text
$review-applied-portfolio를 사용해서 toss-securities의 정확한 build ID를 읽기 전용으로 검수해줘.
```

검수자는 PNG와 PDF를 먼저 보고, 그 후에 폰트 라이선스·입력 lock·preflight·출력 hash를 확인합니다.
두 검수자 점수 차이가 크면 세 번째 adjudicator가 판단합니다.

## 필요한 도구

Windows 기준으로 Chrome 또는 Edge가 필요합니다. 최종 PDF 승인을 받으려면 다음 명령도 가능해야 합니다.

```powershell
pdftotext
pdfinfo
pdffonts
```

없으면 PDF의 텍스트 선택, 페이지 크기, 폰트 임베딩을 충분히 증명할 수 없으므로 production 승인 상태가 될 수 없습니다.

## 자주 지켜야 하는 규칙

- 회사 로고, 마스코트, 슬로건, 스크린샷, 생산용 CSS를 복사하지 않습니다.
- 독점·권리 불명 폰트는 사용하지 않습니다. 한국어 지원, 정적 weight, PDF embedding 권한을 확인합니다.
- `content/`과 `result/content/`을 회사별 지원 목적으로 조용히 바꾸지 않습니다.
- 기존 `result/design/<company>/` 산출물은 삭제·덮어쓰기하지 않습니다.
- 검수자는 자신이 검수한 산출물을 수정하지 않습니다.

## 현재 저장소 상태

- 공통 시스템·회사 조사·적용·검수 Skill의 기본 골격은 있습니다.
- `result/content/`에는 13페이지가 있습니다.
- 중립 레이아웃 HTML, 정식 회사 아트 디렉션 패키지, 회사 application package, immutable build는 아직 없습니다.
- 회사 적용 워크플로우는 독립 검수에서 발견된 안전성 보강 항목이 남아 있어, 97점 승인 상태가 아닙니다.

따라서 현재의 다음 작업은 “첫 회사 디자인 적용”보다 먼저 공통 중립 레이아웃과 적용 워크플로우의
안전성 보강을 끝내는 것입니다.

## 더 자세한 계약

- 공통 시스템: `portfolio-system/SYSTEM.md`
- 테마 경계: `portfolio-system/THEME_CONTRACT.md`
- 회사 조사: `portfolio-system/ART_DIRECTION_CONTRACT.md`
- 회사 적용: `portfolio-system/APPLICATION_CONTRACT.md`
- 장기 전략과 결정: `.agents/memory/portfolio-system-strategy.md`
