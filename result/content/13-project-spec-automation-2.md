---

page: 13
sections: PROJECT 03
topic: PROCESS
project: SERVER SPEC AUTOMATION

title: >
  담당자가 쉽게 사용할 수 있도록
  실행 과정을 기획하고 구현하였습니다.

process:
  - num: "01"
    title: Inventory 기준 대상 정의
    detail: |
      모니터링 프로젝트를 진행하며 정리한 Inventory 구조를 적용해,
      대상 정의와 초기 설계에 드는 비용을 줄였습니다.
    why: 설계 비용 최소화
  - num: "02"
    title: Ansible 기반 수집 자동화
    detail: SSH 기반으로 OS · IP · Hostname · CPU · Mem · Disk 정보를 Agentless 방식으로 수집
    why: |
      대상 서버마다 패키지를 설치하는 것은
      운영 부담이었습니다.
  - num: "03"
    title: Docker Container 정형화
    detail: |
      여러 패키지가 필요한 정형화 작업을 컨테이너에 격리해,
      운영 서버에 설치 부담과 의존성을 남기지 않음
    why: 서버 설치 부담과 의존성 분리
  - num: "04"
    title: Shell Script 실행
    detail: |
      Shell Script 한 번으로 결과를 생성하도록 구성해,
      다른 구성원도 쉽게 활용할 수 있는 사내 운영 자산으로 남김
    why: 재사용 가능한 사내 운영 자산화

reference_url: https://geo-portfolio.co.kr/projects/server-spec-automation

---
