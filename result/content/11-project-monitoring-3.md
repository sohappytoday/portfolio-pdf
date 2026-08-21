---

page: 11
sections: PROJECT 02
topic: TROUBLESHOOTING & INSIGHTS

title: >
  데이터 수집으로 인해 모니터링 서버의 저장 여력은
  한 달 안에 한계에 도달했습니다.

headline: >
  5분마다 GPU 지표를 수집하자 하루 약 4GB가 쌓였습니다.
  정보 최신성과 저장 용량 사이의 균형을 고민해야 했습니다.

context: >
  GPU와 프로세스 정보의 수집 주기를 5분에서 15분으로 조정한 뒤,
  실제 운영에서는 저장 용량과 서버 구성 변경까지 고려해야 했습니다.

issues:
  - num: "01"
    title: 고빈도 스냅샷이 하루 약 4GB 쌓였다
    observation: >
      전체 GPU 지표를 수집하면서 5분마다 1,000건 이상의 지표 값이
      디스크에 기록됐습니다.
    cause: >
      모델명 · Driver · CUDA처럼 거의 변하지 않는 정적 정보까지
      실시간 메트릭과 같은 빈도로 저장하고 있었습니다.
    response: >
      GPU 이상은 CPU·메모리 등 시스템 지표와 함께 판단할 수 있다고 보고,
      GPU 수집 주기를 15분으로 조정했습니다.
    tradeoff: >
      GPU 스냅샷의 즉시성은 일부 낮아졌지만,
      모니터링 서버의 저장 여력을 확보했습니다.

  - num: "02"
    title: 제거된 GPU 정보가 Grafana에 남았다
    observation: >
      서버에서 GPU가 제거·교체된 뒤에도 gpu_nodes에 이전 정보가 남아,
      더 이상 존재하지 않는 GPU가 대시보드에 노출됐습니다.
    cause: >
      수집 결과를 추가하는 흐름은 있었지만,
      장비 변경을 비활성 상태로 반영하는 규칙이 없었습니다.
    response: >
      gpu 테이블에 활성 상태 컬럼을 추가하고,
      Ansible 수집 시 제거된 GPU는 false로 갱신하도록 만들었습니다.
    result: >
      현재 구성에 존재하는 GPU만 표시해,
      실제 서버 구성과 대시보드의 정합성을 유지했습니다.

result:
  headline: >
    78대 서버의 상태와 GPU·프로세스별 점유율을
    대시보드에서 한눈에 확인할 수 있게 됐습니다.
  description: >
    Inventory에 서버만 추가하면 동일한 배포·수집·대시보드 구조를 적용할 수 있도록 구성해,
    사내 운영 자산으로 남겼습니다.

insight:
  headline: >
    운영 자동화는 일회성 실행이 아니라,
    확장을 전제로 한 구조여야 합니다.
  description: >
    사내 운영 자산으로 남기려면, 서버를 쉽게 추가·제거·변경할 수 있는 구조와
    이를 뒷받침하는 상세한 운영 문서가 함께 필요하다는 점을 깨닫고, 이를 구조와 문서에 반영했습니다.

reference_url: https://geo-portfolio.co.kr/projects/server-monitoring-infra

---
