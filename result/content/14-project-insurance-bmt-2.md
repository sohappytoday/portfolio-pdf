---

# Every string below is rendered on the page. Layout-only chrome (the "↓" connectors between step
# cards and the "WHY nn" row labels) is not represented here.

page: "14"
sections: PROJECT 04 / COORDINATION
topic: PROCESS
project: INSURANCE BMT INFRA
document_title: 김지오 — 보험 BMT 배포 프로세스

title: >
  폐쇄망에 반입하기 전에,
  현장 조건을 외부에 그대로 만들었습니다.

# Each item renders as one row: the left card carries title + tags, the right row carries why
# (the statement, kept to two lines) + detail.
process:
  - num: "01"
    title: 검증 환경 구축
    tags: Rocky 9.4 · 온프레미스 검증 · SFTP
    why: >
      비용이 큰 H100 대신
      온프레미스에서 먼저 검증했습니다.
    detail: >
      현장 RHEL은 유료 라이선스라 가장 가까운 Rocky 9.4로 테스트 서버를 새로 설치해 검증하였습니다.

  - num: "02"
    title: 이미지 버전 고정
    tags: inspect · digest · 특정 태그
    why: >
      현장과 같은 이미지를
      반입할 수 있게 했습니다.
    detail: >
      사용 중인 vLLM 컨테이너를 inspect해 image digest를 확인하고,
      동일 digest에 대응하는 특정 태그로 고정했습니다.

  - num: "03"
    title: Kubernetes 설계
    tags: vLLM · Backend 분리 · ClusterIP
    why: >
      파드 IP 변화와 무관한
      내부 통신을 만들었습니다.
    detail: >
      vLLM과 Backend를 별도 파드로 분리하고 ClusterIP Service와 고정 DNS 이름으로 연결했습니다.

  - num: "04"
    title: H100 용량 확보
    tags: 시드니 리전 · 용량 예약
    why: >
      2일 안에 쓸 수 있는
      GPU를 확보했습니다.
    detail: >
      확보 가능한 H100이 없어 AWS·Azure·SCP·NCP를 확인한 뒤, 지연시간이 짧은 AWS 시드니 리전에
      용량을 예약하고 아웃바운드를 열어 RHEL에 고객사 조건의 Kubernetes를 설치했습니다.

  - num: "05"
    title: 당일 변경 대비
    tags: 소스코드 마운트 · mount / nomount
    why: >
      당일 코드 변경까지
      대비했습니다.
    detail: >
      개발팀의 당일 소스 코드 변경 가능성이 생겨, 현장 재빌드 없이 대응하도록
      소스코드를 마운트하는 매니페스트를 따로 작성했습니다.

  - num: "06"
    title: 폐쇄망 재현·최종 검증
    tags: 아웃바운드 차단 · SSH만 허용 · SFTP
    why: >
      현장과 같은 폐쇄망에서
      최종 검증까지 마쳤습니다.
    detail: >
      H100 서버의 아웃바운드를 차단해 SSH 포트를 제외한 폐쇄망 환경을 재현하고,
      SFTP로 완성된 반입물을 AWS H100 서버에 반입한 뒤 최종 검증을 진행하였습니다.

why_labels: [WHY 01, WHY 02, WHY 03, WHY 04, WHY 05, WHY 06]

---
