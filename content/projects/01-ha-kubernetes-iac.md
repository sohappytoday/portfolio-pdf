---
order: 1
id: ha-kubernetes-iac
title: IaC 기반 HA 지향 쿠버네티스 클러스터 구축
category: AI · DevOps
period: 2026.05 – 2026.07
team: 1인 (단독 프로젝트)
role: 아키텍처 설계 · 인프라 프로비저닝 · 클러스터 구축 자동화 · 하네스 구조 설계
summary: Terraform으로 AWS 인프라를 프로비저닝하고, Ansible로 kubeadm 클러스터를 부트스트랩한 자동화 프로젝트
stack: [Claude, Terraform, Ansible, Kubernetes, AWS]
github:
  - https://github.com/sohappytoday/terraform-aws
  - https://github.com/sohappytoday/ansible
metrics:
  - label: control-plane 페일오버
    value: "장애 허용 0 → 33%(1/3 노드), 중지 다운타임 0%"
  - label: 인프라 코드화(IaC)
    value: "수동 콘솔 구성 → 100% 코드 관리, AWS 리소스 39개·모듈 6개를 terraform apply 1회로 생성"
  - label: HA 클러스터 구축 시간
    value: "약 1시간(수동) → 약 5분(자연어 명령 1회), 약 92% 단축"
---

## Overview

쿠버네티스를 제대로 이해하려면 직접 설치해봐야 한다고 생각해 클러스터 구축을 반복 연습했는데,
쿠버네티스 공식 문서를 보면서 CRI·CNI 설치 등 손이 많이 가는 단계가 많아 매번 구축에 시간이 오래
걸렸다. 그래서 설치 절차를 Ansible로 자동화했고, 이를 검증할 서버가 필요해 AWS 인프라를 Terraform으로
구축했다. 콘솔로 수동 구성하던 중 노드 간 통신을 위해 포트를 여러 개 열다 보니 보안이 아쉬워, private
통신 전환과 control-plane 격리로 보안을 버전 단위(v1·v2·v3)로 강화했다. 가용성은 정족수를 고려해 CP
3대·WN 2대로 구성해 한 대가 죽어도 클러스터가 유지되도록 했으나, 단일 AZ라 완전한 HA는 아니며
멀티-AZ 등으로 계속 보완할 예정이다.

## 아키텍처

### Terraform

**1. 격리 — 전 노드 Private + SSM 접근**

control-plane과 worker node를 VPC를 이용하여 Private Subnet에 두었고, Public IP·SSH inbound를
제거해 외부에서 직접 도달 가능한 경로 자체를 없앴다. 관리 접근은 SSM Session Manager로 대체했다.
이를 위해 SSM 서비스로 가는 사설 경로로 VPC Interface Endpoint를 두고, 인스턴스에는 SSM에 등록·통신할
권한으로 IAM Role을 부여함으로써 인터넷을 경유하지 않고 AWS 내부망으로만 접속하도록 했다.

**2. 아웃바운드 — NAT Instance**

cp, worker-node가 속한 라우트 테이블을 VPC IGW로 향하지 않도록 설정했기 때문에 이미지 Pull, 패키지
설치 등을 할 수 없게 되었다. 그래서 Private Subnet이 외부로 나갈 수 있는 경로를 따로 만들어줘야
했다. 처음에는 NAT Gateway를 쓸까 했는데, 24시간 켜두면 월 $42 정도가 나와서 학습용으로는 부담이
컸다. 그래서 저렴한 t3.micro EC2를 NAT 용도로 Public Subnet에 하나 띄우고, Private Subnet 라우트
테이블의 0.0.0.0/0을 이 NAT 인스턴스로 향하게 설정함으로써 노드들의 outbound를 NAT가 대신
중계하도록 만들어주었다.

**3. 인바운드 — Reverse Proxy**

외부 인바운드의 유일한 진입점으로 Public Subnet에 Reverse Proxy(Nginx) EC2를 두고, 사용자 요청을
worker의 Ingress NodePort로 포워딩했다. NodePort는 Reverse Proxy SG 출처로만 열어 외부에서 worker의
NodePort로 직접 들어오는 걸 막았다.

**4. 가용성 — control plane 3대 + 내부 NLB**

etcd 정족수를 생각하여, 단일이 아니면서 홀수 개인 3개로 control plane을 설계하였다. 또한 클러스터를
구축할 때, worker-node가 바라보는 control plane이 죽었을 때를 대비하여 NLB를 두어 단일 고정
엔드포인트로 묶고 worker-node들이 NLB Endpoint를 바라보도록 설계하였다.

**5. 경계 방어 — NACL**

Security Group은 특정 IP나 IP 대역을 allow만 가능해 악성 IP를 deny할 수 없다. 외부 진입점이 있는
Public Subnet에 NACL을 도입해, 악성 IP가 Reverse Proxy에 닿기 전 서브넷 경계에서 deny하도록 이중
방어선을 구성했다.

### Ansible

**1. 유연성 — K8s·CRI·CNI 구성 선택**

인턴을 진행하면서 요구되는 쿠버네티스 버전, Container Runtime 종류, CNI 종류가 항상 달랐던 경험이
있었다. 그래서 클러스터를 구축할 때 이것들을 선택할 수 있으면 좋겠다는 생각으로, 매번 플레이북을
새로 짜는 대신 하나의 role을 변수로 조립되도록 설계했다.

**2. 가용성 — 단일/HA 분기 처리**

control plane의 개수인 cp_count에 따라 role을 분기 처리하였다. control plane이 3개 이상일 때만 첫
CP의 kubeadm init에 NLB 엔드포인트가 지정되고, 나머지 CP도 그 NLB 엔드포인트를 통해 자동으로
join되도록 하였다.

**3. 보안 — SSM 접속**

Ansible은 기본적으로 SSH 기반으로 노드에 접속하기 때문에, 프로젝트에서 구현한 SSM 방식에는 바로
적용할 수 없었다. SSH는 기본적으로 서버의 22번 포트로 TCP 연결을 시도하는데, ProxyCommand를 이용해
직접 연결하는 대신 SSM 세션을 열어 그 통로로 접속하도록 설계하였다.

### AI

**1. 자동화 — 자연어를 통한 쿠버네티스 클러스터 구축**

결국, 다른 사람들은 이 코드들을 바로바로 이해하기 어렵다. role이 아무리 유연해도, 어떤 변수를 어디에
넣고 어떤 순서로 실행해야 하는지는 결국 이 코드를 짠 사람만 안다. 그래서 자연어를 통해서 원하는 CNI,
CRI, Kubernetes 버전 등을 선택하고, Terraform을 사용하고 있다면 Terraform Output으로 나온 결과를
바탕으로 `ha-cluster-ssm.yml` 또는 `ha-cluster-ssh.yml` 파일을 생성하도록 만들었다. 이렇게 만들어진
인벤토리와 확정된 구성으로 Ansible 플레이북을 실행해 클러스터를 구축하고, 마지막에는 완료 기준(전 노드
Ready 등등)을 자동으로 점검해 성공/실패를 판정하게 했다. 즉 "이런 클러스터를 만들어줘"라는 말
한마디에서 시작해, 구성 확정 → Terraform → 인벤토리 생성 → Ansible → 검증까지 이어지는 전체
파이프라인을 사람이 코드를 몰라도 돌릴 수 있게 설계했다.

## 결론

Terraform으로 VPC와 EC2 인프라를 프로비저닝하고, Claude Skill을 활용해 자연어 명령만으로 Ansible
기반 쿠버네티스 클러스터를 구축했다. 그 결과 control-plane 3대(t3.small), worker 2대(c7i-flex.large),
여기에 외부 노출용 reverse-proxy와 아웃바운드용 NAT 인스턴스(각 t3.micro)까지 총 7대의 노드로 이루어진
멀티마스터 클러스터를 완성했다. `kubectl get nodes`로 확인한 결과 control-plane 3대와 worker 2대가
모두 Ready 상태인 것을 확인할 수 있었다. 또한 테스트용으로 Deployment, Ingress, Service를 배포한 뒤
`http://<리버스프록시-ip>/<ingress-path>`로 접속해보니 화면이 정상적으로 잘 나오는 것을 확인할 수
있었다. 이후, 가용성을 검증하기 위해 control-plane 하나를 일부러 중지시켜 망가뜨린 다음 기존에 떠
있던 파드들을 다시 확인해본 결과, 클러스터와 워크로드가 여전히 잘 돌아가는 것을 확인할 수 있었다.
이로써 control-plane 장애에도 견디는, 가용성 있는 고가용성(HA) 쿠버네티스 클러스터를 완벽히
만들어냈다.

**성과 지표**

1. **Control-plane 페일오버** — 3-마스터 중 1대를 일부러 중지시킨 테스트에서 워크로드 파드가 계속
   Running. 장애 허용 0 → 33%(1/3 노드), 중지 다운타임 0%, 무중단 검증.
2. **인프라 코드화(IaC)** — 수동 콘솔 구성 → 100% 코드 관리. VPC·서브넷·NAT·NLB·EC2·IAM 등 39개
   AWS 리소스·6개 모듈을 `terraform apply` 1회로 생성·버전관리, 수동 작업 0.
3. **HA 클러스터 구축 시간** — 약 1시간(수동) → 약 5분(자연어 명령 1회). 오류 트러블슈팅(~30분)부터
   control-plane init·CNI·worker join까지 수동 약 1시간 → 자연어 명령 1회로 약 92% 단축.

## Troubleshooting

이 프로젝트의 아키텍처 설계는 대부분 트러블슈팅을 거치며 만들어진 결과물이다. 여기서는 설계에 직접
녹지 않은, 그 외 추가로 겪은 트러블슈팅을 따로 정리했다.

### 이슈 1 — 메모리 부족

**상황 & 원인**: 여러 실험을 반복하다 보니 인스턴스 비용이 생각보다 많이 발생했다. 그래서 AWS
프리티어 기준 안에서 쓸 수 있는 인스턴스로 구성했고, 그중 control-plane은 t3.small(2GB RAM)로
잡았다. 기본 HA 클러스터를 돌리기엔 t3.small(2GB)로도 충분했다. 실제로 control-plane 3대와 worker
2대가 모두 Ready 상태로 잘 돌아갔다. 다만 메모리 여유가 거의 없다 보니, 여기에 뭔가를 더 얹는 순간
한계가 드러났다. 도커도 같이 돌려보고 싶어 도커 데몬을 설치한 순간, OOM이 발생하면서 인스턴스가
응답 불능 상태가 되었다.

**해결 & 결과**: 쿠버네티스는 설치 조건상 swap 메모리를 off해야 해서, 부족한 메모리를 swap으로
메울 수 없었다. 결국 물리 RAM 자체를 늘리는 수밖에 없었고, 프리티어에서 쓸 수 있는 4GB RAM인
c7i-flex.large로 사양을 올려 OOM 문제를 해결했다. 이후, t3.small의 control plane을 사용한다면 필수
시스템 구성요소를 제외한 추가 상주 에이전트(데몬 등)는 배치하지 않는 운영 원칙을 세웠다.

### 이슈 2 — kubectl 명령 실패

**상황 & 원인**: HA 구성 후 상태를 확인하려고 control-plane에서 `kubectl get nodes -o wide`를
실행했는데, 가끔은 노드 목록이 정상적으로 나오고 가끔은 한참 멈춰 있다가 아무것도 받지 못한 채
실패하는 현상이 반복됐다. 같은 명령인데도 될 때와 안 될 때가 갈려, 처음엔 원인을 잡기 어려웠다.

**해결 & 결과**: 문제의 조건을 조금씩 좁혀 나갔다. 먼저 control-plane 내부에서 기본 명령어들은 모두
timeout 없이 잘 동작했다 — 인스턴스 자체에는 문제가 없다고 판단했다. 또 이 현상은 단일 control-plane과
worker-node 구성에서는 한 번도 없었기 때문에, HA 클러스터로 넘어오며 새로 추가된 요소인 NLB, NAT
Instance, Reverse Proxy를 의심했다. 이 중 NAT Instance는 outbound 중계가, Reverse Proxy는 외부 요청
포워딩이 정상 동작하는 것을 확인해 용의선상에서 제외했다. 결국 남는 건 NLB 하나였고, "NLB에 문제가
있는 게 아닐까"라는 가설을 세웠다. control-plane에서 kubectl을 실행하면 kubeconfig의 server 값을
읽어 요청을 `https://<NLB-endpoint>:6443`으로 보낸다 — 즉 control-plane의 apiserver 접근 경로가
반드시 NLB를 거치도록 되어 있어, 관련이 있을 것이라는 심증이 굳어졌다. 이 가설을 가지고 NLB 관련
이슈를 찾아본 결과, 이 현상이 NLB가 지원하지 않는 루프백(hairpinning) 문제임을 알게 됐다. NLB는
client IP 보존이 켜져 있을 때 요청이 자기 자신으로 되돌아가는 경로를 처리하지 못한다. 따라서 control
plane은 NLB의 타겟이면서 동시에 NLB로 요청을 보내는 클라이언트였기 때문에, NLB가 3대 중 요청을 보낸
자기 자신을 고를 때만 연결이 실패했던 것이다. 이를 해결하기 위해 Terraform으로 NLB를 설계할 때,
타겟 그룹에 `preserve_client_ip = false` 한 줄을 추가해 이 문제를 해결했다.

## Tech Stack

| 분류 | 기술 | 용도 |
|---|---|---|
| AI | Claude | 자연어 클러스터 구축 및 리뷰 |
| IaC | Terraform | AWS 인프라(VPC·EC2·NLB·NAT·ReverseProxy) 프로비저닝 |
| 자동화 | Ansible | 쿠버네티스 클러스터 설치 자동화 (kubeadm·CRI·CNI·ingress) |
| 오케스트레이션 | Kubernetes | HA 클러스터 구성 |
| 클라우드 | AWS | EC2·NLB·Lightsail·SSM 인프라 |
