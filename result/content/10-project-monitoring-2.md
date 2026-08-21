---

page: 10
sections: PROJECT 02
topic: ARCHITECTURE

title: >
  Ansible 기반 IaC로 표준화한
  서버 관측 구조

headline: >
  Ansible 기반 IaC로 수집 환경을 표준화하고, 
  PostgreSQL 적재를 통해 GPU까지 관측 범위를 확장했습니다.

principles:
  - num: "01"
    title: Agentless 배포를 선택
    decision: >
      대상 서버에는 SSH로 접근하고,
      Ansible Playbook으로 node_exporter 설치와 설정을 일괄 적용했습니다.
    why: >
      모니터링과 무관한 별도 에이전트 부담을 줄이면서,
      멱등성 있는 실행으로 78대와 이후 추가 서버에 같은 상태를 적용할 수 있었습니다.

  - num: "02"
    title: OS 계열별 방화벽 처리 분기
    decision: >
      Ansible이 OS 계열을 판별해 Debian 계열과 RedHat 계열의
      방화벽 도구를 각각 처리하도록 구성했습니다.
    why: >
      node_exporter의 지표 노출 포트가 서버 방화벽에 막히지 않도록 하되,
      하나의 명령으로 모든 서버를 다룬다는 가정을 피했습니다.

  - num: "03"
    title: 연속된 스냅샷 적재를 통한 GPU 수집
    decision: >
      Ansible로 GPU·프로세스 정보를 수집 후 PostgreSQL에 적재하고,
      cron job을 통해 주기적으로 갱신되도록 구성했습니다.
    why: >
      Prometheus 기반 실시간 수집과는 다른 방식으로
      GPU 상태를 저장·조회하는 구조를 직접 검증했습니다.

flow:
  - num: "01"
    title: Inventory 등록
    description: 서버 목록과 접속 정보를 Inventory에 추가
  - num: "02"
    title: Playbook 실행
    description: node_exporter 설치 · 설정 · OS별 방화벽 처리
  - num: "03"
    title: 일반 시스템 지표 수집
    description: CPU · Memory · Network → Prometheus
  - num: "03"
    title: GPU · Process 스냅샷 적재
    description: Ansible → PostgreSQL
  - num: "04"
    title: Grafana 통합 확인
    description: 두 수집 경로의 상태와 이상 징후를 대시보드에서 비교

outcomes:
  - metric: 서버 자원 가시성
    before: 모니터링 부재
    after: 78대 통합 대시보드
    impact: Grafana 한 화면에서 실시간 확인

  - metric: 신규 서버 모니터링 편입 시간
    before: 약 20분
    after: 약 2분
    impact: Inventory 등록 후 Playbook 실행

---
