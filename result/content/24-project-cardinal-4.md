---

# Every string below is rendered on the page. Each case is split into four parts so the
# observation, the cause, the options weighed, and the fix stay visually separate.
# Case 03 and the insights live on page 25.

page: 24
sections: TEAM PROJECT
project: CARDINAL
document_title: 김지오 — Cardinal 트러블슈팅

topic: TROUBLESHOOTING

title: 멈추면 안 되는 환경이라, 넘어갈 수 있는 게 없었습니다.

headline: 한 진입점을 여러 서비스가 나눠 쓰고 노드가 스스로 늘고 줄면서, 개인 프로젝트에서는 없던 문제가 나왔습니다.

issues:
  - num: "01"
    label: SUB PATH
    상황: /grafana로 접속했을 때 Grafana가 제대로 작동하지 않았습니다.
    시도: >
      Kubernetes Ingress 리소스에 rewrite 애노테이션을 걸어 /grafana를 떼고 넘기면,
      Grafana가 평소처럼 루트로 요청을 받으니 정상적으로 뜰 것이라고 생각했습니다.
    원인: >
      요청이 들어가는 방향은 실제로 맞았습니다. 문제는 나오는 방향이었습니다.
      Grafana는 프리픽스가 떼진 URL을 받기 때문에 자기가 루트에 있다고 판단하고,
      응답 HTML에 실어 보내는 자산과 리다이렉트 주소에도 /grafana를 붙이지 않습니다.

      브라우저가 그 주소를 다시 요청하면 /grafana 규칙에 걸리지 않고
      / 규칙을 타 frontend로 넘어갔습니다.
    해결: >
      오픈소스를 이용했기 때문에 이미지의 소스 코드를 수정할 수는 없었습니다.
      그래서 프리픽스를 떼지 않고 그대로 넘긴 뒤,
      root_url과 serve_from_sub_path로 Grafana에게 자기 위치를 알려줬습니다.
      응답 주소에도 /grafana가 붙으니 Ingress 규칙으로 다시 돌아옵니다.

  - num: "02"
    label: HEALTH CHECK
    상황: ALB 타깃 그룹에 app 노드를 등록하고 조금 있다가 서버가 자동으로 내려갔습니다.
    원인: >
      파드도 정상이고 노드도 방금 떴는데 계속 교체되길래, 교체를 결정하는 주체인 ASG부터 봤습니다.
      문제는 ASG의 헬스체크 방식에 있었습니다.

      타깃 그룹을 붙이면 EC2 상태 검사에 더해 ALB 헬스체크까지 통과해야 하는데,
      30080을 받아줄 ingress-nginx가 아직 클러스터에 없어 매번 실패했고,
      ASG는 그 노드를 고장으로 판단해 종료하고 있었습니다.
      헬스체크 유예가 300초라 정확히 5분 주기로 반복됐고,
      desired_capacity가 1이라 교체되는 동안에는 app 노드가 0대가 됐습니다.
    고민: >
      헬스체크 유예 시간을 늘리거나 판정을 느슨하게 잡을 수도 있었습니다.
      그러면 당장 교체는 멈추지만 진짜 고장난 노드까지 살려두게 됩니다.
      판정 기준이 아니라 순서가 문제였습니다.
    해결: >
      타깃 그룹 등록을 미뤄 ALB 헬스체크가 걸리지 않은 상태로 클러스터를 먼저 띄웠습니다.
      ingress-nginx가 30080을 열고 응답하는 것을 확인한 뒤,
      register_app_nodes_to_alb를 켜 타깃 그룹에 등록했습니다.

---
