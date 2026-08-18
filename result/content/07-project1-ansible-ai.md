---
page: 7
section: Project 01 — Architecture (Ansible + AI)
project_id: ha-kubernetes-iac
---

## 아키텍처 · Ansible

**1. 유연성 — K8s·CRI·CNI 구성 선택**

인턴 중 요구되는 쿠버네티스 버전·Container Runtime·CNI가 매번 달랐던 경험이 있어, 매번
플레이북을 새로 짜는 대신 하나의 role을 변수로 조립하도록 설계했다.

**2. 가용성 — 단일/HA 분기 처리**

cp_count(control plane 개수)에 따라 role을 분기했다. control plane이 3개 이상일 때만 첫 CP의
kubeadm init에 NLB 엔드포인트를 지정하고, 나머지 CP는 그 NLB 엔드포인트를 통해 자동으로
join되도록 했다.

**3. 보안 — SSM 접속**

Ansible은 기본적으로 SSH(22번 포트 TCP)로 접속하기 때문에 프로젝트에 적용한 SSM 방식과 바로
맞지 않았다. ProxyCommand로 SSM 세션을 열어 그 통로로 접속하도록 설계해 해결했다.

## 아키텍처 · AI

**1. 자동화 — 자연어를 통한 쿠버네티스 클러스터 구축**

role이 아무리 유연해도 어떤 변수를 어디에, 어떤 순서로 넣어야 하는지는 결국 작성자만 안다.
그래서 자연어로 CNI·CRI·Kubernetes 버전 등을 선택하면, Terraform Output을 바탕으로
`ha-cluster-ssm.yml` 또는 `ha-cluster-ssh.yml` 인벤토리를 자동 생성하고 Ansible 플레이북을
실행해 클러스터를 구축한 뒤, 완료 기준(전 노드 Ready 등)을 자동 점검해 성공/실패를 판정하도록
만들었다. "이런 클러스터를 만들어줘" 한마디로 구성 확정 → Terraform → 인벤토리 생성 → Ansible
→ 검증까지 이어지는 파이프라인을, 코드를 몰라도 돌릴 수 있게 설계했다.
