---
page: 6
section: Project 01 — Architecture (Terraform)
project_id: ha-kubernetes-iac
---

## 아키텍처 · Terraform

**1. 격리 — 전 노드 Private + SSM 접근**

control-plane과 worker node를 VPC Private Subnet에 두고, Public IP·SSH inbound를 제거해
외부에서 직접 도달 가능한 경로를 없앴다. 관리 접근은 SSM Session Manager로 대체했다 — SSM용
VPC Interface Endpoint와 인스턴스 IAM Role을 함께 구성해, 인터넷을 경유하지 않고 AWS 내부망으로만
접속하도록 했다.

**2. 아웃바운드 — NAT Instance**

cp·worker node가 속한 라우트 테이블이 IGW로 향하지 않아 이미지 pull·패키지 설치 같은 아웃바운드가
막혀 있었다. NAT Gateway는 24시간 기준 월 $42로 학습용치고 부담이 커서, 대신 저렴한 t3.micro
EC2를 NAT 인스턴스로 Public Subnet에 띄우고 Private Subnet 라우트 테이블의 0.0.0.0/0을 이
인스턴스로 향하게 해 outbound를 중계하도록 했다.

**3. 인바운드 — Reverse Proxy**

외부 인바운드의 유일한 진입점으로 Public Subnet에 Reverse Proxy(Nginx) EC2를 두고, 사용자
요청을 worker의 Ingress NodePort로 포워딩했다. NodePort는 Reverse Proxy SG 출처로만 열어
외부에서 worker의 NodePort로 직접 들어오는 걸 막았다.

**4. 가용성 — control plane 3대 + 내부 NLB**

etcd 정족수를 고려해 control plane을 홀수·복수인 3대로 설계했다. worker node가 바라보는
control plane이 죽는 경우에 대비해 NLB로 단일 고정 엔드포인트를 두고, worker node가 이 NLB
엔드포인트를 바라보도록 했다.

**5. 경계 방어 — NACL**

Security Group은 IP를 allow만 할 수 있어 악성 IP를 deny할 수 없다. 외부 진입점인 Public
Subnet에 NACL을 추가로 두어, 악성 IP가 Reverse Proxy에 닿기 전 서브넷 경계에서 차단하는 이중
방어선을 구성했다.
