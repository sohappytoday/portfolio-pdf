---

page: "08"
section: PROJECT 02 / OBSERVE
topic: PREVIEW
project: SERVER MONITORING INFRA

title: >
  수십 대 서버를 한 화면에서 파악하는
  통합 모니터링 인프라 구축

headline: >
  서버의 이상 징후를 발견할 수 있도록,
  관측 가능한 운영 환경을 만들었습니다.

background: >
  사내와 데이터센터의 다수 서버를 관리하고 있었지만,
  각 서버의 자원 상태를 한 화면에서 확인할 수단이 없었습니다.
  비정상적인 자원 점유와 이상 징후를 제때 발견하기 어려운 상황에서,
  통합 모니터링 환경의 구축을 맡았습니다.

scope:
  - label: 대상 서버
    detail: 사내 · 데이터센터 서버 78대
  - label: 관측 지표
    detail: CPU · Mem · Network · GPU
  - label: 운영 목표
    detail: 이상 서버 식별 · 신규 서버 편입 · 재사용 가능한 배포

role:
  - 모니터링 아키텍처 설계
  - Ansible 기반 수집 환경 배포 자동화
  - Grafana 대시보드 템플릿 제작

stack:
  - Ansible
  - Prometheus
  - node_exporter
  - Grafana
  - PostgreSQL
  - Linux

problem:
  intro: >
    서버는 많았지만, 상태를 비교하고 이상을 빠르게 찾는
    공통의 관측 지점이 없었습니다.

  items:
    - num: "01"
      title: 서버 자원 상태가 각 서버에 흩어져 있었다
      description: >
        CPU · 메모리 · 네트워크 상태를 확인하려면 서버별로 접속해야 했고,
        비정상적인 자원 점유를 한눈에 비교하기 어려웠습니다.
      risk: >
        이상 징후의 발견이 늦어지고 운영 판단이 개별 확인에 의존함

    - num: "02"
      title: 동일한 수집 환경을 수십 대에 반복 적용해야 했다
      description: >
        node_exporter 설치와 기본 설정을 서버마다 따로 수행하면,
        신규 서버가 늘어날수록 구축과 검증 비용이 반복됩니다.
      risk: >
        수동 설치 · 설정 편차 · 신규 서버 편입 지연

    - num: "03"
      title: GPU 지표는 별도 수집 경로가 필요했다
      description: >
        일반 시스템 지표와 달리 GPU 상태는 별도 방식으로 수집해야 했습니다.
      risk: >
        통합 대시보드에서 GPU 상태를 함께 판단하기 어려움

direction: >
  서버별 확인을 늘리는 대신, 배포는 Inventory 기반으로 통일하고
  관측 결과는 Grafana 한 화면으로 모으는 구조를 만들었습니다.

reference_url: https://geo-portfolio.co.kr/projects/server-monitoring-infra

# 화면에 함께 렌더링되는 라벨과 값
scope_label: 운영 범위
scope_value: 서버 70여 대
preview_caption: GRAFANA · SERVER OBSERVABILITY
labels: [ROLE, STACK, PROBLEM, RISK]
role: 모니터링 아키텍처 설계 · Ansible 기반 수집 환경 배포 자동화
stack: Ansible · Prometheus · node_exporter · Grafana · PostgreSQL · Linux
problems:
  - CPU · 메모리 · 네트워크 상태를 서버별로 접속해 확인해야 했습니다.
  - node_exporter 설치와 기본 설정을 서버마다 따로 수행해야 했습니다.
risk: 이상 징후 발견 지연 · 개별 확인에 의존한 운영 판단
reference_text: MORE DETAILS · https://geo-portfolio.co.kr/projects/server-monitoring-infra

---
