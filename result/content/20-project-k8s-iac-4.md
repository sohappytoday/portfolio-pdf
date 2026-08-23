---

# Every string below is rendered on the page. Each case leads with the observed symptom and then
# reads as one narrative: what was ruled out, what the cause turned out to be, and what was done.

page: 20
sections: PERSONAL PROJECT
project: HA KUBERNETES IaC
document_title: 김지오 — IaC 클러스터 트러블슈팅과 인사이트

topic: TROUBLESHOOTING & INSIGHT

title: 안전하게 만들수록, 제가 접근하고 개발하기도 까다로워졌습니다.

headline: 닫아둔 경로와 새로 넣은 구성요소가 그대로 작업의 제약이 됐습니다.

issues:
  - num: "01"
    label: NLB HAIRPIN
    observation: 다중 control-plane에서 Kubernetes 설치 이후, kubectl 명령이 간헐적으로 실패했습니다.
    resolution: >
      모든 kube-system 파드가 정상이었고 Linux 명령도 잘 실행돼 인스턴스 문제는 아니라고 판단했습니다.
      v3에서 새로 추가한 NLB·NAT Instance·Reverse Proxy 중 Kubernetes와 직접 닿는 것은 NLB뿐이라 보고 관련 이슈를 찾아보았습니다.
      kubeconfig가 NLB 엔드포인트를 향하고 있어,
      kubectl 명령을 날리던 control-plane이 NLB의 타깃이면서 동시에 클라이언트가 되는
      헤어핀 문제라는 것을 알게 되었습니다.
      클라이언트 IP 보존이 켜져 있으면 자기 자신으로 되돌아온 요청에 응답하지 못하기 때문에,
      타깃 그룹에서 이 옵션을 끄고 다시 검증했습니다.

  - num: "02"
    label: MEMORY
    observation: Kubernetes 설치 파일을 옮기던 중 control-plane 서버가 다운됐습니다.
    resolution: >
      worker가 인터넷에 나갈 수 없어 control-plane이 받아 전달하는 구조였습니다.

      Ansible fetch가 파일을 메모리에 통째로 올리면서,
      kube-system 파드가 이미 떠 있던 control-plane이 이를 견디지 못했습니다.

      따라서 메모리에 쌓지 않고 control-plane에서 worker로 곧장 보내는 scp로 변경하였습니다.

  - num: "03"
    label: SSH ACCESS
    observation: Ansible이 프라이빗 노드에 접속하지 못했습니다.
    resolution: >
      Ansible은 SSH 기반이라 퍼블릭 IP도 SSH 인바운드도 없는 노드에는 붙을 수 없었습니다.

      인벤토리에 ProxyCommand를 걸어 SSH 연결을 SSM 세션 위로 태웠고,
      접속 대상도 IP가 아닌 인스턴스 ID로 지정해 인바운드를 열지 않고 관리하도록 했습니다.

# The two lessons render side by side under one INSIGHT label.
insight:
  label: INSIGHT
  items:
    - headline: >
        만든 것으로 끝내지 않아야 합니다.
      description: >
        실제로 동작하는지 증명하기 위해,
        Cardinal 프로젝트를 이 위에 올려보기로 했습니다.
    - headline: >
        확장성과 보안을 함께 설계해야 합니다.
      description: >
        단일 AZ처럼 남겨둔 한계를 다음에는 넘어서기 위해
        AWS SAA를 준비하였습니다.

---
