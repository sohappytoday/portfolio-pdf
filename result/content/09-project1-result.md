---
page: 9
section: Project 01 — Result
project_id: ha-kubernetes-iac
tech_stack:
  - category: AI
    tech: Claude
    use: 자연어 클러스터 구축 및 리뷰
  - category: IaC
    tech: Terraform
    use: AWS 인프라(VPC·EC2·NLB·NAT·ReverseProxy) 프로비저닝
  - category: 자동화
    tech: Ansible
    use: 쿠버네티스 클러스터 설치 자동화 (kubeadm·CRI·CNI·ingress)
  - category: 오케스트레이션
    tech: Kubernetes
    use: HA 클러스터 구성
  - category: 클라우드
    tech: AWS
    use: EC2·NLB·Lightsail·SSM 인프라
---

## 결론

Terraform으로 VPC·EC2 인프라를 프로비저닝하고, Claude Skill을 활용해 자연어 명령만으로 Ansible
기반 쿠버네티스 클러스터를 구축했다. 최종적으로 control-plane 3대(t3.small)·worker
2대(c7i-flex.large)에 reverse-proxy·NAT 인스턴스(각 t3.micro)까지 총 7대로 이루어진 멀티마스터
클러스터를 완성했고, `kubectl get nodes`로 전 노드 Ready 상태를 확인했다. 테스트용 Deployment·
Ingress·Service를 배포해 정상 접속을 확인했고, control-plane 하나를 의도적으로 중지시킨 뒤에도
클러스터와 워크로드가 그대로 유지되는 것을 확인해 가용성을 검증했다.

## 성과 지표

1. **Control-plane 페일오버** — 3-마스터 중 1대를 일부러 중지시킨 테스트에서 워크로드 파드가
   계속 Running. 장애 허용 0 → 33%(1/3 노드), 중지 다운타임 0%, 무중단 검증.
2. **인프라 코드화(IaC)** — 수동 콘솔 구성 → 100% 코드 관리. VPC·서브넷·NAT·NLB·EC2·IAM 등 39개
   AWS 리소스·6개 모듈을 `terraform apply` 1회로 생성·버전관리, 수동 작업 0.
3. **HA 클러스터 구축 시간** — 약 1시간(수동) → 약 5분(자연어 명령 1회). 오류 트러블슈팅(~30분)부터
   control-plane init·CNI·worker join까지 수동 약 1시간 → 자연어 명령 1회로 약 92% 단축.
