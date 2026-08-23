---

# Every string below is rendered on the page. Each resource box reads as
# 막힌 것 -> 도입한 리소스, in the order the resources were actually added.

page: "18"
sections: PERSONAL PROJECT
project: HA KUBERNETES IaC
document_title: 김지오 — Ansible 자동화와 리소스 도입 순서

topic: AUTOMATION & RESOURCES

title: >
  설치는 변수로 받고,
  막힐 때마다 리소스를 하나씩 더했습니다.

# Why each tool was chosen, set beside the title.
tool_reasons:
  - label: Terraform
    reason: >
      콘솔에서 하나씩 만들면 빠뜨리기 쉬워,
      AWS 리소스를 코드로 모아 한 번에 다루도록 했습니다.
  - label: Ansible
    reason: >
      프로젝트의 목표 자체가 설치 자동화였기에,
      모든 노드에 같은 절차가 적용되도록 만들었습니다.

ansible_label: Ansible
ansible_summary: >
  역할을 시나리오마다 새로 쓰지 않고 변수로 조합하도록 만들어,
  플레이북 수정 없이 원하는 구성을 골라 설치할 수 있게 했습니다.
ansible_params:
  - label: Kubernetes
    value: 1.24 이상 · 기본 1.30
    note: pkgs.k8s.io에서 제공하는 범위
  - label: Container Runtime
    value: containerd · CRI-O · cri-dockerd
  - label: CNI
    value: Calico · Flannel · Cilium
  - label: control-plane
    value: 1대 또는 3대 이상
  - label: OS
    value: Ubuntu · Rocky 모두 동작
  - label: 폐쇄망 워커 (v2)
    value: control-plane에서 worker로 scp
    note: 아웃바운드가 있는 control-plane이 받아 전달

resources_label: Terraform
resources:
  - num: "01"
    problem: SSH 인바운드를 없애 노드에 접근할 수 없다
    solution: SSM Session Manager
    detail: VPC 인터페이스 엔드포인트로 AWS 내부망만 경유

  - num: "02"
    problem: 프라이빗 서브넷의 애플리케이션에 외부가 닿을 수 없다
    solution: Reverse Proxy
    detail: 유일한 인바운드 진입점 · NodePort는 이 SG 출처로만 개방

  - num: "03"
    problem: 아웃바운드가 없어 쿠버네티스 패키지를 설치할 수 없다
    solution: NAT Instance
    detail: NAT Gateway 대신 저렴한 인스턴스로 비용 절감

  - num: "04"
    problem: control-plane 1대가 멈추면 클러스터가 함께 멈춘다
    solution: 정족수를 고려한 control-plane 3대
    detail: 1대가 빠져도 etcd 정족수가 유지되는 최소 구성

  - num: "05"
    problem: control-plane 3대의 apiserver 주소를 하나로 묶어야 한다
    solution: 내부 NLB
    detail: kubeadm join이 바라볼 고정 엔드포인트 · 사설 IP만 할당

  - num: "06"
    problem: 특정 출처를 차단해야 하는데 SG는 allow만 가능하다
    solution: NACL deny 규칙
    detail: 퍼블릭 서브넷 경계에서 악성 IP를 먼저 거름

---
