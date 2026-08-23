---

# Every string below is rendered on the page. Each row is one spend line: what it cost,
# and the deliberation that set it. Row order follows how the budget was actually allocated.

page: "21"
sections: TEAM PROJECT
project: CARDINAL
document_title: 김지오 — Cardinal 예산 배분과 설계 근거

topic: CLOUD ARCHITECTURE

title: 예산을 먼저 나누고, 그 안에서 구성을 맞췄습니다.

headline: >
  3주에 30만 원. 평소에는 최소로 두고, 무너지면 되살아나고 몰리면 늘어나도록 배분했습니다.

rows:
  - num: "01"
    item: 노드
    spec: |
      control-plane t3.medium 4GiB · system m7i-flex.large 8GiB · app m7i-flex.large 8GiB · NAT t3.micro 1GiB
    cost: 20.6만 원
    note: >
      control-plane은 3대에서 1대로 낮췄습니다. 3대면 7만 원이 더 들어 예산을 넘고,
      EKS는 컨트롤 플레인만 월 9만 원대라 후보가 아니었습니다.
      대신 사설 IP를 고정하고 etcd 스냅샷을 6시간마다 S3에 올려 복구 경로를 남겼습니다.

      app 노드는 평소에 1대만 돌아가고, 몰리면 HPA가 파드를 늘립니다.
      Cluster Autoscaler는 ASG의 스케일 아웃 장치로 사용했습니다.

      ArgoCD · Grafana · MySQL은 ASG 밖 system 노드에 두어 스케일 인에도 영향받지 않게 했습니다.

  - num: "02"
    item: ALB · Route 53
    spec: |
      ALB 1대 · Route 53 Hosted Zone · 도메인 1년 19,800원
    cost: 4.2만 원
    note: >
      개인 프로젝트의 Reverse Proxy 노드보다 ALB가 더 비쌉니다.
      그래도 관리형을 택한 건, 진입점이 꺼지면 서비스 전체가 멈추기 때문입니다.
      노드 한 대에 걸려 있던 인바운드를 관리형으로 넘겼고,
      액세스 로그가 S3로 바로 쌓여 차단할 IP를 고르기도 쉬워졌습니다.

  - num: "03"
    item: VPC Endpoint
    spec: |
      Interface Endpoint ×3 · ssm · ssmmessages · ec2messages
    cost: 2.8만 원
    note: >
      SSM 자체는 무료지만, 노드를 전부 Private Subnet에 두면 사설 경로가 필요합니다.
      SSH 인바운드를 완전히 닫기 위해 낸 값이고,
      비용을 줄이려 엔드포인트를 첫 AZ 한 곳에만 배치했습니다.

  - num: "04"
    item: EBS · S3 · 공인 IP
    spec: |
      gp3 30GB ×4 · etcd 스냅샷 · ALB 액세스 로그 · 공인 IP 3개
    cost: 2.6만 원
    note: >
      S3는 수명 주기 규칙으로 로그와 스냅샷을 자동 만료시켜 용량이 늘지 않게 했습니다.
      공인 IP는 NAT와 ALB에만 남기고 나머지 노드에는 붙이지 않았습니다.

free_num: "05"
free_label: 무료
free_cost: 0원
free_note: >
  배포와 모니터링, 데이터베이스는 system 노드에 파드로 직접 띄워 관리형 서비스 요금 없이 운영했습니다.

  GitHub Actions와 GHCR도 무료 한도 안에서 사용하였습니다.

sum_label: 합계
sum_cost: 30.2만 원
sum_note: >
  예산이 더 있었다면 control-plane 3대, NAT Gateway 순으로 가용성을 올렸을 것입니다.

---
