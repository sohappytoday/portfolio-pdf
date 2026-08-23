---

page: "05"
section: PROJECT 01 / STANDARDIZE
topic: PREVIEW

title: >
사내 Proxmox VM 환경 표준화

headline: >
같은 VM 환경을 매번 처음부터 구축하고 있었습니다.

background: >
사내 Proxmox 환경에서 개발·검증용 VM을 생성할 때마다
OS 설치부터 초기 설정까지 같은 과정을 반복해야 했습니다.
특히 GPU를 사용하는 환경에서는 OS와 Kernel, NVIDIA Driver 조합까지
다시 확인해야 해 VM 한 대를 준비하는 데 약 15분이 필요했습니다.

what_we_managed:

label: VM 생성
detail: vCPU · Memory · Disk 등 기본 리소스 설정

label: OS 환경
detail: Ubuntu · Rocky Linux 등 목적에 맞는 OS 설치

label: GPU 환경
detail: NVIDIA Driver · Kernel 호환성 확인

role:
- Proxmox VM 환경 분석
- 표준화 방식 설계
- Template 구축 및 검증

stack:

- Proxmox VE
- Ubuntu
- Rocky Linux
- NVIDIA Driver

problem:
intro: >
VM은 만들 수 있었지만, 같은 환경을 반복해서 준비하는 과정에
운영 관점의 비효율이 있었습니다.



items:
- num: "01"
title: VM마다 OS 설치를 반복해야 한다
description: >
새로운 VM이 필요할 때마다 ISO를 연결하고 OS를 설치한 뒤
기본 설정을 다시 수행해야 했습니다.
risk: >
VM 수가 늘어날수록 동일한 구축 작업과 대기 시간이 반복됨

- num: "02"
title: 실행 환경이 사람과 작업마다 달라질 수 있다
description: >
  동일한 용도의 VM이라도 OS 버전과 초기 설정이 달라질 수 있어
  환경 차이에서 발생하는 문제를 다시 확인해야 했습니다.
risk: >
  환경 불일치로 인한 재작업과 트러블슈팅 비용 증가

- num: "03"
title: GPU 환경은 호환성까지 다시 확인해야 한다
description: >
  NVIDIA Driver는 Kernel과의 호환성을 함께 고려해야 해,
  검증된 조합을 매번 다시 구성하는 방식은 운영 부담이 컸습니다.
risk: >
  Driver · Kernel 조합 차이로 실행 환경의 안정성이 흔들릴 수 있음

direction: >
그래서 매번 환경을 새로 만드는 대신,
검증된 실행 환경 자체를 재사용하는 방향으로 표준화했습니다.

results:

metric: VM 구축 시간
before: 약 15분
after: 약 5분
impact: 약 67% 단축

metric: 표준 OS 템플릿
before: 0종
after: 6종
impact: Ubuntu 2종 · Rocky Linux 4종

metric: 환경 불일치 재작업·문의
before: 발생
after: 0건
impact: 동일한 검증 환경 재현

# 화면에 함께 렌더링되는 라벨과 값
labels: [PROBLEM, RISK, ROLE, STACK, DIRECTION]
role: Proxmox VM 환경 분석 · 표준화 방식 설계 · Template 구축 및 검증
stack: Proxmox VE · Ubuntu · Rocky Linux · NVIDIA Driver
direction:
  - 약 15분 → 약 5분
  - 0종 → 6종
  - 발생 → 0건
reference_text: MORE DETAILS · https://geo-portfolio.co.kr/projects/proxmox-vm-template

---
