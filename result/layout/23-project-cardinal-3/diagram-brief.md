# Cardinal 클러스터 구성도 — 이미지 생성 브리프

포트폴리오 23페이지에 넣을 아키텍처 다이어그램입니다.
아래 내용을 그대로 그려 주세요. **라벨 텍스트는 한 글자도 바꾸지 마세요.**

---

## 캔버스 · 스타일

- 가로:세로 = **1152 : 400** (가로로 긴 형태)
- 배경 `#f7f7f4` / 카드 배경 `#ffffff`
- 본문 텍스트 `#171714` / 보조 텍스트 `#62625b` / 테두리 `#d9d9d2`
- **평면 스타일.** 그림자·그라데이션·3D·광택 없이 얇은 선과 둥근 모서리(반경 8px)만
- 한글이 들어가므로 한글 지원 산세리프 사용
- **AWS 공식 서비스 아이콘은 넣지 마세요.** 텍스트 라벨이 붙은 사각형 박스만 사용

---

## 구조 (바깥 → 안)

### 1. 왼쪽 바깥 — 진입 주체 두 개

세로로 위아래에 배치. 어두운 배경(`#171714`)의 알약 모양, 흰 글씨.

- 위: **유저**
- 아래: **관리자**

### 2. VPC — 점선 테두리 큰 박스

좌상단 라벨: `VPC 10.20.0.0/16`

#### 2-1. PUBLIC SUBNET (VPC 안 위쪽, 점선 박스)

좌상단 라벨: `PUBLIC SUBNET · 2 AZ`
안에 카드 두 개를 **좌·우 끝**에 배치.

| 위치 | 제목 (굵게) | 부제 (작게, 회색) |
|---|---|---|
| 왼쪽 | `ALB` | `유일한 인바운드 진입점` |
| 오른쪽 | `NAT Instance` | `유일한 아웃바운드` |

#### 2-2. PRIVATE SUBNET (VPC 안 아래쪽, 점선 박스)

좌상단 라벨: `PRIVATE SUBNET`

**위층 — 가운데에 넓은 카드 하나**

- 제목: `control-plane`
- 부제: `t3.medium · 1대 · apiserver · etcd · scheduler · Calico`

**아래층 — 카드 두 개를 좌·우로 나란히** (control-plane 바로 아래)

왼쪽 카드
- 제목: `app node`
- 부제: `m7i-flex.large · ASG 1~3대`
- 목록:
  - `ingress-nginx (DaemonSet)`
  - `backend · frontend · metrics-server`

오른쪽 카드
- 제목: `system node`
- 부제: `m7i-flex.large · 고정 1대`
- 목록:
  - `ArgoCD · MySQL · Redis · RabbitMQ`
  - `Prometheus · Grafana`

---

## 화살표 (총 5종)

계층 관계상 **control-plane이 위, 두 워커 노드가 아래**여야 합니다.

| # | 경로 | 선 종류 | 라벨 |
|---|---|---|---|
| 1 | 유저 → ALB | **실선**, 진한 색 | `HTTPS` |
| 2 | ALB → app node (아래로 수직) | **실선**, 진한 색 | `NodePort 30080` |
| 3 | 관리자 → control-plane (가로로 곧게) | **점선**, 진한 색 | `SSM Session Manager · VPC Endpoint` |
| 4 | control-plane → app node, control-plane → system node | 얇은 실선, 회색 | `kubeadm join · apiserver` |
| 5 | system node → NAT Instance (위로 수직) | 얇은 실선, 회색 | `아웃바운드` |

### 이 그림에서 가장 중요한 점

**3번(관리자 경로)은 PUBLIC SUBNET을 통과하지 않고 PRIVATE SUBNET으로 곧장 들어갑니다.**
ALB를 거치지 않는 완전히 별개의 경로라는 것이 한눈에 보여야 합니다.
그래서 1·2번(유저)은 실선, 3번(관리자)은 점선으로 구분합니다.

---

## 넣지 말 것

- AWS 공식 아이콘, 로고, 브랜드 색
- 그림자, 3D, 아이소메트릭, 광택
- 위에 없는 리소스 (RDS, EKS, CloudFront, Route 53 박스 등)
- 영어 번역 — 한글 라벨은 한글 그대로

---

## 참고

`result/layout/23-project-cardinal-3/23-project-cardinal-3.html` 안의 인라인 SVG가
현재 버전입니다. 좌표와 배치를 그대로 참고하셔도 됩니다.
