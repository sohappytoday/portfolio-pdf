---

# Every string below is rendered on the page. Each stage ends with the problem it left behind,
# which is what the next stage sets out to fix; the last one is the limitation that still stands.

page: "17"
sections: PERSONAL PROJECT
project: HA KUBERNETES IaC
document_title: 김지오 — IaC 클러스터 보안 구조 발전

topic: SECURITY HARDENING

title: >
  한 번에 설계하지 못했고,
  만들고 나서 보인 문제를 세 단계에 걸쳐 좁혔습니다.

stages:
  - step: 1단계
    version: v1
    title: >
      단일 control-plane에서 Ansible로
      Kubernetes 환경을 설치했습니다
    items:
      - control-plane 1대 · worker 1대
      - Kubernetes 버전 · CRI · CNI를 지정해 설치
      - 노드 간 통신을 퍼블릭 IP로 연결
    why_label: 설계 포인트
    why: >
      control-plane은 비용이 낮은 Lightsail로,
      worker는 파드가 올라가는 만큼 수직 확장이 자유로운 EC2로 나눴습니다.
    problem_label: 생긴 문제
    problem: >
      노드끼리 통신할 때 퍼블릭 IP를 주고받으면서 네트워크 비용이 발생했습니다.
      또한 Lightsail은 자체 default VPC에서 돌아가 EC2와 내부 통신을 할 수 없었습니다.

  - step: 2단계
    version: v2
    title: >
      하나의 VPC로 통합하여
      사설 네트워크 통신으로 만들었습니다
    items:
      - 전 노드를 EC2로 통일하고 커스텀 VPC 구성
      - control-plane은 퍼블릭 · worker는 프라이빗 서브넷
      - 사설 IP 통신으로 인터넷 경유 제거
    why_label: 설계 포인트
    why: >
      네트워크가 갈려 생긴 요금과 통신 문제를 없애려면 한 VPC로 모아야 했고,
      control-plane은 SSH 접근이 필요해 퍼블릭에 남겼습니다.
    problem_label: 남은 문제
    problem: >
      control-plane이 여전히 퍼블릭에 노출돼 SSH 인바운드가 열려 있었고,
      이 control-plane을 거치면 프라이빗 서브넷의 worker까지 닿을 수 있었습니다.

  - step: 3단계
    version: v3
    title: >
      클러스터를 Private Subnet에 배치하고
      control-plane을 다중화했습니다
    items:
      - 전 노드 프라이빗 서브넷
      - 관리 접근은 SSM
      - 인바운드는 Reverse Proxy
      - 아웃바운드는 NAT Instance
      - 출처 차단은 NACL
      - control-plane 3대와 내부 NLB로 단일 엔드포인트
    problem_label: 결과
    problem: >
      control-plane 3대 중 1대가 멈춰도 클러스터가 유지되는 구성을 완성했습니다.
      다만 단일 AZ라 가용 영역 장애까지는 견디지 못합니다.

---
