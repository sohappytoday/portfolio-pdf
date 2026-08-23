---

page: "07"
sections: PROJECT 01 / STANDARDIZE
topic: STANDARDIZE

title: >
  Troubleshooting & Insights

headline: >
  설치 실패를 단순 오류로 넘기지 않고,
  Kernel과 Package의 관계까지 추적했습니다.

troubleshooting:
  title: >
    Rocky Linux 8.6에서 NVIDIA Driver 설치 실패

  situation: >
    Template을 구성하기 위해 NVIDIA Driver를 설치하던 중,
    실행 중인 Kernel에 맞는 Module을 빌드하지 못하며 설치가 실패했습니다.

  process:
    - num: "01"
      title: 실행 중인 Kernel 버전 확인
      description: >
        uname -r을 통해 현재 실행 중인 Kernel 버전을 확인하고,
        NVIDIA Driver Module 빌드에 필요한 패키지 조건을 좁혔습니다.

    - num: "02"
      title: kernel-devel · headers 버전 비교
      description: >
        Driver 자체의 문제가 아니라,
        실행 Kernel과 Build Package의 버전이 일치해야 한다는 점을 확인했습니다.

    - num: "03"
      title: 기본 Repository 밖에서 동일 버전 탐색
      description: >
        기본 Repository에서는 필요한 버전을 찾을 수 없어,
        RHEL 호환 계열 Repository까지 범위를 넓혀 동일 버전 패키지를 찾았습니다.

    - num: "04"
      title: Build 환경 구성 후 Driver 재설치
      description: >
        Kernel과 일치하는 Build Package와 필요한 도구를 구성한 뒤
        NVIDIA Driver를 다시 설치해 정상 동작을 확인했습니다.

result:
  headline: >
    Rocky Linux 8.6의 지원 종료로
    실행 Kernel과 일치하는 Build Package를 기본 Repo에서 확보할 수 없었습니다.

  description: >
    기본 Repository에 없는 Kernel Build Package를 직접 탐색·설치해 NVIDIA Driver의 Kernel Module 빌드를 정상화했습니다.

learnings:
  - num: "01"
    title: >
      개별 오류보다, 시스템의 연결 구조를 보게 되었습니다.
    description: >
      Driver에서 시작한 문제를 Kernel Module · Build Package · Repository까지 확장해 추적하며, 하나의 오류에 매몰되지 않고 시스템 전체의 의존 관계에서 원인을 찾는 관점을 익혔습니다.

  - num: "02"
    title: >
      표준화와 자동화는 다른 문제였습니다.
    description: >
      Template으로 동일한 실행 환경은 재현할 수 있었지만,
      Clone 이후 IP와 CPU·Memory·Disk를 직접 설정하는 과정은 여전히 남았습니다.
      이를 통해 다음 단계에서는 cloud-init과 IaC를 통해
      Provisioning까지 코드화할 필요성을 느꼈습니다.

# 화면에 함께 렌더링되는 라벨과 문구
section_label: PROCESS & RESULT
headline_lead: 설치 실패를 단순 오류로 보지 않고,
labels: [상황, 원인 추적, 해결 방법, RESULT]
trace_steps:
  - title: 실행 Kernel 확인
    detail: 현재 Kernel과 Module 빌드 조건을 확인했습니다.
  - title: Build Package 비교
    detail: kernel-devel · headers 버전 일치 여부를 확인했습니다.
  - title: 동일 버전 Package 탐색
    detail: 필요한 Package를 찾아 Build 환경을 맞췄습니다.
resolution_note: 일치한 환경에서 정상 동작을 확인했습니다.
results:
  - headline: 오류 메시지보다 의존 관계를 따라가게 되었습니다.
    body: >
      하나의 설치 실패도 해당 Package만 보는 것이 아니라
      Kernel · Module · Repository까지 연결된 실행 환경 전체를 확인해야 한다는 점을 배웠습니다.
  - headline: 표준화는 자동화로 가는 다음 문제를 만듭니다.
    body: >
      Template로 동일 환경을 재현한 뒤에도 IP와 CPU·Memory·Disk 설정은 남았습니다.
      다음 단계에서 cloud-init과 IaC가 필요함을 확인했습니다.

---
