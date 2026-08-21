---

# Every string below is rendered on the page. Layout-only chrome (the "↓" connector between a
# design point's context and its decision) is not represented here.

page: 14
sections: PROJECT 04 / COORDINATION
topic: PREVIEW
project: INSURANCE BMT INFRA
document_title: 김지오 — 보험금 지급 금액 심사 BMT 인프라

title: >
  폐쇄망 환경에서 vLLM 기반
  보험금 지급 금액 심사 인프라 설계

headline: >
  국내 대형 손해보험사 BMT에서
  총 7명 규모의 팀 인프라를 단독 전담했습니다.

conditions:
  label: 제약 조건
  items:
    - label: 고객사 조건
      detail: RHEL · Kubernetes 1.34 · Cilium · containerd · 폐쇄망 환경 · PuTTY 접속
    - label: 개발팀 조건
      detail: 안정적인 백엔드 애플리케이션과 vLLM 환경 구축

role:
  - BMT 인프라 단독 전담
  - Kubernetes 리소스·네트워크 구조 설계
  - AWS 사전 검증 환경 구축 및 현장 배포 대응

stack:
  - Kubernetes
  - vLLM
  - Gemma4-31B-it
  - AWS H100
  - Linux (RHEL)

# Each item renders as one column: problem (muted) -> context -> decision (prominent) -> detail.
design_points:
  label: 설계 포인트
  items:
    - num: "01"
      problem: 온프레미스 H100 검증 환경이 없었다
      context: >
        RTX 5000 4장 구성으로 검증하면 현장 H100 환경과 결과가 달라질 수 있다고 판단했습니다.
      decision: AWS H100 사전 검증 환경 구성
      detail: >
        AWS H100 인스턴스를 예약해 고객사 환경과 유사한 사전 검증 환경을 구성했습니다.

    - num: "02"
      problem: latest 태그 이미지의 반입 기준이 불확실했다
      context: >
        개발팀이 사용하던 Gemma 이미지의 태그가 latest로 지정되어 있었습니다.
      decision: SHA 일치 이미지 버전 고정
      detail: >
        USB 반입 전 Docker Hub에서 SHA가 일치하는 정확한 이미지 버전을 찾아 고정했습니다.

    - num: "03"
      problem: 개발팀이 테스트를 쉽게 할 수 있도록 해야 했다
      context: >
        이미지가 교체되더라도 쉽게 테스트할 수 있는 환경을 조성해야 했습니다.
      decision: K8s Deployment · Service 구성
      detail: >
        Deployment와 Service 리소스를 구성해 이미지 교체와 서비스 접근 과정을 단순화했습니다.

reference_url: https://geo-portfolio.co.kr/projects/insurance-bmt-infra

---
