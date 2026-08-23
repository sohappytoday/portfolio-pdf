---

page: "12"
sections: PROJECT 03 / AUTOMATE
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

# 화면에 함께 렌더링되는 단계 부제와 WHY 라벨
step_subtitles:
  - 모니터링 Inventory 재사용
  - SSH 기반 Agentless 수집
  - Excel 산출
  - 누구나 재사용
whys:
  - label: WHY 01
    title: 설계 비용을 최소화했습니다.
  - label: WHY 02
    title: 대상 서버마다 패키지를 설치하는 것은 운영 부담이었습니다.
    body: 별도 Agent 설치 없이 SSH로 접속해 OS · IP · Hostname · CPU · Mem · Disk 정보를 일괄 수집했습니다.
  - label: WHY 03
    title: Excel 생성 환경은 컨테이너로 분리했습니다.
    body: 운영 서버에 설치 부담과 의존성을 남기지 않았습니다.
  - label: WHY 04
    title: Ansible을 몰라도 실행할 수 있게 했습니다.
    body: 다른 구성원도 쉽게 활용할 수 있는 사내 운영 자산으로 남겼습니다.

---
