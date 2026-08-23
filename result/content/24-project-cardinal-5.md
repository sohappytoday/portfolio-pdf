---

# Every string below is rendered on the page. Last troubleshooting case, then the two lessons.
#
# TODO: RESULT 수치를 아직 받지 못했습니다. 이용자 수 · 무중단 여부 · 피크 노드 증감 · 배포 횟수
# 중 하나라도 확인되면 인사이트 아래에 결과 블록을 추가하고, 21페이지 RESULT도 함께 채웁니다.

page: "24"
sections: TEAM PROJECT
project: CARDINAL
document_title: 김지오 — Cardinal 트러블슈팅과 인사이트

topic: TROUBLESHOOTING & INSIGHT

title: 배운 것을 그대로 옮기는 게 적용은 아니었습니다.

headline: 개인 프로젝트에서 쓰던 방식이 실서비스 조건에서 왜 안 되는지부터 확인했습니다.

issues:
  - num: "03"
    label: PROVISIONING
    상황: Ansible을 이용해서 쿠버네티스 클러스터를 구축할 수 없었습니다.
    원인: >
      개인 프로젝트에서 만들었던 Ansible 기반 클러스터 구축의 한계점이 드러났습니다.
      ASG는 부하에 따라 노드 수가 변하기 때문에, 사람이나 cron으로 실행하기에는 시점을 예측할 수 없었습니다.
      또한 사람이 직접 부트스트랩하는 것보다는 Ansible로 설치하는 편이 빠르지만,
      ASG가 노드를 늘리는 급박한 상황에서는 그보다 더 빠른 기동이 필요했습니다.
    해결: >
      EC2가 생성됨과 동시에 워커 노드로 등록시킬 방법을 찾은 결과,
      Amazon Linux에 Kubernetes가 이미 설치된 Custom AMI를 만들기로 했습니다.
      부트 스크립트에서 워커 노드 연결까지 수행하도록 해,
      인스턴스가 뜨면 클러스터에 자동으로 붙고 등록되는 시간을 대폭 낮췄습니다.

# Verifiable from the repository, not from unmeasured traffic or an estimated bill.
result_label: RESULT
result:
  - value: 약 5분 → 약 1분 30초
    label: ASG 확장 시 EC2 시작부터 워커 노드 편입까지 · 이미지는 Custom AMI에 프리풀되어 pull 0초
  - value: 반자동 → 완전 자동
    label: 사람이 플레이북을 실행해야 했던 노드 편입이 부팅만으로 끝납니다

# 초안입니다. 본인 확인 전까지 확정된 문장이 아닙니다.
insight:
  label: INSIGHT
  items:
    - headline: 전제가 바뀌면 도구도 바뀌어야 합니다.
      description: >
        앞선 개인 프로젝트에서는 이 클러스터 위에 Cardinal을 올려보겠다고 적었지만,
        실제로는 그대로 올라가지 않았습니다. ASG라는 전제가 붙는 순간 Ansible은 맞지 않는 도구가 됐습니다.
        적용은 옮겨 심는 일이 아니라, 바뀐 조건에서 다시 고르는 일이었습니다.
    - headline: 제약이 먼저 정해지면 설계가 분명해집니다.
      description: >
        30만 원이라는 상한이 있어 선택마다 근거를 남겨야 했고, 무엇을 포기했는지도 함께 적게 됐습니다.
        다음에는 예산뿐 아니라 가용성 목표도 숫자로 먼저 정해두고, 거기서부터 구성을 고르려 합니다.

---
