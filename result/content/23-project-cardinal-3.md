---

# The diagram itself is a rendered image, so its labels are not selectable text.
# The three lines under it carry the same information as text.

page: 23
sections: TEAM PROJECT
project: CARDINAL
document_title: 김지오 — Cardinal 클러스터 아키텍처

topic: ARCHITECTURE

title: >
  진입은 하나로 두고, 분기는 클러스터 안에서 했습니다.

headline: >
  경로를 하나 늘리는 일이 인프라 변경이 아니라 Git 커밋이 되도록 했습니다.

diagram: assets/image.png
diagram_alt: >
  Cardinal 클러스터 구성도. VPC 안에 퍼블릭 서브넷의 ALB와 NAT Instance,
  프라이빗 서브넷의 control-plane과 그 아래 app node, system node가 배치되어 있고,
  유저는 ALB를 거쳐 실선으로, 관리자는 SSM을 거쳐 점선으로 들어간다.

# What the diagram draws, in the order the reader should follow it.
diagram_contents:
  vpc: VPC 10.20.0.0/16
  public_subnet:
    label: PUBLIC SUBNET · 2 AZ
    items:
      - ALB — 유일한 인바운드 진입점
      - NAT Instance — 유일한 아웃바운드
  private_subnet:
    label: PRIVATE SUBNET
    items:
      - control-plane — t3.medium · 1대 · apiserver · etcd · scheduler · Calico
      - app node — m7i-flex.large · ASG 1~3대 · ingress-nginx(DaemonSet) · backend · frontend · metrics-server
      - system node — m7i-flex.large · 고정 1대 · ArgoCD · MySQL · Redis · RabbitMQ · Prometheus · Grafana
  edges:
    - 유저 → ALB (실선, HTTPS)
    - ALB → app node (실선, NodePort 30080)
    - 관리자 → control-plane (점선, SSM Session Manager · VPC Endpoint)
    - control-plane → app node · system node (kubeadm join · apiserver)
    - system node → NAT Instance (아웃바운드)

# Two request paths, rendered as chip chains under the diagram.
chains:
  - label: 유저 요청
    steps: [도메인, ALB, NodePort 30080, ingress-nginx, backend · frontend · Grafana]
  - label: 관리 접근
    steps: [로컬, SSM Session Manager, VPC Endpoint, control-plane]

paths:
  - label: ALB vs ingress-nginx 분기 처리
    detail: >
      서비스를 하나 추가할 때마다 ALB에서는 NodePort · 타깃 그룹 · 리스너 규칙이 함께 늘고,
      매번 terraform apply가 필요합니다.
      ingress 규칙은 매니페스트라 경로 한 줄을 커밋하면 ArgoCD가 반영합니다.

---
