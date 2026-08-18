---
page: 5
section: Project 01 — Cover
project_id: ha-kubernetes-iac
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

쿠버네티스를 제대로 이해하려면 직접 설치해봐야 한다고 판단해 클러스터 구축을 반복 연습했는데,
공식 문서대로면 CRI·CNI 설치 등 손이 많이 가는 단계가 많아 매번 시간이 오래 걸려 설치 절차를
Ansible로 자동화하고, 이를 검증할 서버가 필요해 AWS 인프라를 Terraform으로 구축했다.

콘솔로 수동 구성하며 노드 간 통신용 포트를 여러 개 열다 보니 보안이 아쉬워, private 통신 전환과
control-plane 격리로 보안을 v1·v2·v3 세 단계로 강화했다. 가용성은 정족수를 고려해 CP 3대·WN
2대로 구성해 한 대가 죽어도 클러스터가 유지되도록 했다 — 다만 단일 AZ라 완전한 HA는 아니며,
멀티-AZ 등으로 계속 보완할 계획이다.
