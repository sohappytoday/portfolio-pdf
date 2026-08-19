---

page: 7
sections: TOPIC 01
topic: STANDARDIZE

title: >
  Solution · 검증된 VM 환경의 재사용 구조 설계

headline: >
  단순히 Template을 만든 것이 아니라,
  어떻게 재사용할지를 기준으로 구조를 정했습니다.

decisions:
  - num: "01"
    what_i_did: >
      cloud-init 없이 검증된 VM 환경을 Template으로 전환
    why: >
      Proxmox 도입 초기 단계였기 때문에 자동 초기화 체계를 먼저 도입하기보다,
      이미 검증된 OS·Driver 환경을 빠르게 재사용하는 것을 우선했습니다.
      Clone 이후 IP와 리소스는 수동으로 조정했습니다.
    tradeoff: >
      빠르게 표준 환경을 만들 수 있었지만,
      IP·리소스 관리에 사람의 개입이 남았습니다.

  - num: "02"
    what_i_did: >
      Linked Clone 대신 Full Clone 선택
    why: >
      Linked Clone은 원본 Template의 디스크에 의존하기 때문에,
      각 VM을 독립적인 개발·검증 환경으로 사용할 수 있도록
      Full Clone 방식을 선택했습니다.
      또한 디스크는 Clone 이후 확장하기는 쉽지만 축소하기는 어렵기 때문에,
      Template의 기본 디스크 용량은 최소한으로 구성했습니다.
    tradeoff: >
      Linked Clone보다 Storage 사용량은 늘지만,
      원본 Template과 독립적인 실행 환경을 확보했습니다.

  - num: "03"
    what_i_did: >
      NVIDIA Driver 설치 Kernel 버전을 검증된 조합으로 고정
    why: >
      NVIDIA Driver는 Kernel Module과 함께 동작하므로
      Kernel이 임의로 업데이트되면 기존 Driver와 호환되지 않을 수 있습니다.
      이를 막기 위해 Kernel 패키지를 고정하였습니다.
    tradeoff: >
      최신 Kernel을 즉시 적용하는 대신,
      검증된 GPU 실행 환경의 안정성과 재현성을 우선했습니다.

---