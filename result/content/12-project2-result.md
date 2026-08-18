---
page: 12
section: Project 02 — Result
project_id: geo-portfolio
tech_stack:
  - category: AI
    tech: Claude
    use: 코드 작성 및 성능, 보안 리뷰
  - category: AI
    tech: Stitch AI
    use: 디자인 설계
  - category: IaC
    tech: Terraform
    use: EC2·S3 프로비저닝
  - category: 자동화
    tech: Ansible
    use: 쿠버네티스 설치
---

## Troubleshooting

**상황 & 원인**: make-workflow 스킬과 관련 에이전트가 자연어 요청에서 제대로 호출되지 않는 것을
확인했다.

**해결 & 결과**: Skill의 호출 조건을 예시까지 포함해 아주 자세하게 적고, Skill에서 관련 Agent를
실행하도록 강제해 해결했다.

## 배운 점

- AI는 명확한 기준을 줘야 원하는 결과가 나온다는 것
- AI를 쓰더라도 관련 기본 지식이 있어야 더 좋은 결과물을 뽑아낼 수 있다는 것

## 결론

API로 환산하면 백엔드 $67.96, 프론트엔드 $77.50, 총 $145.46(약 22만 원) 규모의 사용량이었지만,
작업을 시간대별로 나눠 Claude Pro 구독의 사용량 한도 안에서 진행해 구독료 외의 추가 비용은 들지
않았다. 직접 하기 어려웠던 디자인과 프론트엔드는 AI로 대체하고, 백엔드는 기존 컨벤션을 SubAgent가
강제로 준수하도록 설계해 품질과 일관성을 유지한 채 기획부터 배포까지 혼자 완성했다.

**개발 기간 비교**: 통상 수 주~한 달 걸리는 작업을, AI 활용 구조 설계로 기획~배포를 5일에
완성했다.
