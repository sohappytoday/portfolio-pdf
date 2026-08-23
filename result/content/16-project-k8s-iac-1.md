---

# Every string below is rendered on the page. Single-project opener: lead thesis, title, stack,
# the reason the project started, and the measured outcomes.

page: "16"
sections: PERSONAL PROJECT
project: HA KUBERNETES IaC
document_title: 김지오 — IaC 기반 HA 지향 Kubernetes 클러스터

lead: >
  귀찮아서 시작했고, 만들고 나서 보안까지 좁혔습니다.

title: >
  2. IaC 기반 HA 지향 Kubernetes 클러스터

subtitle: >
  AWS 인프라 프로비저닝 · Kubernetes 클러스터 구축 자동화

stack_label: STACK
stack: Terraform · Ansible · Kubernetes · AWS (EC2 · VPC · NLB · SSM) · Claude

story: >
  업무에서 반복하던 쿠버네티스 프로비저닝을, 개인 프로젝트로 직접 자동화했습니다.
  설치를 Ansible로 자동화했고, 이를 검증할 환경이 필요해 AWS 인프라를 Terraform으로 코드화했습니다.
  만들고 나서야 드러난 보안 문제를 v1에서 v3까지 단계적으로 좁혀갔습니다.

metrics_label: RESULT
metrics:
  - value: 약 1시간 → 약 5분
    label: HA 클러스터 구축 시간 · 약 92% 단축
  - value: 39개의 리소스
    label: control-plane 3 · worker 2 · terraform apply 1회로 생성
  - value: 다운타임 0%
    label: control-plane 1대 중지 시

reference_url: https://geo-portfolio.co.kr/projects/terraform-ansible-ha-kubernetes

reference_text: MORE DETAILS · https://geo-portfolio.co.kr/projects/terraform-ansible-ha-kubernetes

---
