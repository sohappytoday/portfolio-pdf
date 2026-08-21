---

# Every string below is rendered on the page. The 관찰·원인·대응·결과 labels are the rendered form of
# the observation/cause/response/result field names, and the "01"/"02" markers come from num.

page: 16
sections: PROJECT 04 / COORDINATION
topic: TROUBLESHOOTING & RESULT
project: INSURANCE BMT INFRA
document_title: 김지오 — 보험 BMT 트러블슈팅과 결과

title: >
  현장 변수는 사전 검증만으로 끝나지 않았고,
  실제 구성에 맞춰 다시 판단해야 했습니다.

headline: >
  반입 파일의 무결성과 GPU 분할 방식까지 확인하며,
  폐쇄망 환경에서 vLLM 파드의 정상 기동을 검증했습니다.

# The two cases render side by side, each as observation -> cause -> response -> result.
issues:
  - num: "01"
    label: FILE INTEGRITY
    title: USB 반입 파일의 실제 용량이 달랐습니다.
    observation: >
      현장에서 확인한 모델 파일은 예상한 59GB가 아니라 1.7GB로 표시됐습니다.
    cause: >
      전날 AWS H100 서버에서 최종 검수를 마친 뒤 최신 파일만 USB에 담으려 SFTP로 복사했는데,
      전송이 끝나기 전에 완료 여부를 확인하지 않고 분리했습니다.
    response: >
      불변이 확인된 safetensor를 제외한 파일만 다시 동기화하고,
      서버에서 정상 파일을 재확인한 뒤 USB를 다시 반입했습니다.
    result: >
      모델 파일을 정상 상태로 복구해 현장 배포 기준을 맞췄습니다.

  - num: "02"
    label: GPU RESOURCE
    title: vLLM 파드의 GPU를 Index로 지정할 수 없었습니다.
    observation: >
      현장 H100 GPU가 MIG로 분할돼 있어,
      기존 GPU Index 기반 리소스 요청은 사용할 수 없었습니다.
    cause: >
      고객사가 GPU 할당 방식을 따로 언급하지 않고 H100 한 장을 제공한다고만 해,
      Index 방식일 것으로 가정했습니다.
    response: >
      GPU Index와 CUDA_VISIBLE_DEVICES 방식 대신,
      배정된 MIG 프로파일 리소스를 requests·limits로 요청하도록 Manifest를 변경했습니다.
    result: >
      vLLM(Gemma4-31B-it) 파드의 정상 기동을 로그로 확인했습니다.

result:
  label: RESULT
  headline: >
    지정된 폐쇄망 조건에서 vLLM 기반 보험금 지급 금액 심사 시스템의
    배포와 동작을 검증했습니다.
  description: >
    사전 환경 재현·이미지 버전 고정·반입 파일 검증·MIG 리소스 설계를 통해
    현장 변수에도 대응 가능한 BMT 인프라를 구성했습니다.

# The two lessons render side by side under one INSIGHT label.
insight:
  label: INSIGHT
  items:
    - headline: >
        최악의 상황을 가정하고 준비해야 합니다.
      description: >
        현장에는 예상치 못한 변수가 생기므로, 반입물의 전송 완료와 무결성을 직접 확인하고
        달라질 수 있는 구성에는 대안을 함께 준비해야 합니다.
    - headline: >
        아는 것을 팀에 먼저 공유해야 합니다.
      description: >
        현장에서 BMT 실행을 매번 curl로 호출하며, API 형태의 실행 방식을
        미리 제안했다면 팀 전체가 더 수월했겠다고 느꼈습니다.

---
