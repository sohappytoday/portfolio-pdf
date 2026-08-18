---
page: 8
section: Project 01 — Troubleshooting
project_id: ha-kubernetes-iac
---

## Troubleshooting

이 프로젝트의 아키텍처 설계는 대부분 트러블슈팅을 거치며 만들어진 결과물이다. 여기서는 설계에
직접 녹지 않은, 그 외 추가로 겪은 트러블슈팅을 따로 정리했다.

### 이슈 1 — 메모리 부족

**상황 & 원인**: 여러 실험을 반복하다 보니 인스턴스 비용이 생각보다 많이 발생해, AWS 프리티어
기준 안에서 쓸 수 있는 인스턴스로 구성했고 control-plane은 t3.small(2GB RAM)로 잡았다. 기본 HA
클러스터를 돌리기엔 t3.small(2GB)로도 충분해 control-plane 3대·worker 2대가 모두 Ready 상태로
잘 돌아갔다. 다만 메모리 여유가 거의 없어, 도커 데몬을 추가로 설치한 순간 OOM이 발생하며 인스턴스가
응답 불능 상태가 되었다.

**해결 & 결과**: 쿠버네티스는 설치 조건상 swap 메모리를 off해야 해서, 부족한 메모리를 swap으로
메울 수 없었다. 결국 물리 RAM 자체를 늘리는 수밖에 없어 프리티어에서 쓸 수 있는 4GB RAM인
c7i-flex.large로 사양을 올려 OOM 문제를 해결했다. 이후 t3.small의 control plane을 사용한다면
필수 시스템 구성요소를 제외한 추가 상주 에이전트(데몬 등)는 배치하지 않는 운영 원칙을 세웠다.

### 이슈 2 — kubectl 명령 실패

**상황 & 원인**: HA 구성 후 상태를 확인하려고 control-plane에서 `kubectl get nodes -o wide`를
실행했는데, 가끔은 노드 목록이 정상적으로 나오고 가끔은 한참 멈춰 있다가 아무것도 받지 못한 채
실패하는 현상이 반복됐다. 같은 명령인데도 될 때와 안 될 때가 갈려, 처음엔 원인을 잡기 어려웠다.

**해결 & 결과**: 문제의 조건을 조금씩 좁혀 나갔다. control-plane 내부의 기본 명령어들은 모두
timeout 없이 잘 동작해 인스턴스 자체에는 문제가 없다고 판단했다. 이 현상은 단일 control-plane과
worker-node 구성에서는 한 번도 없었기 때문에, HA 클러스터로 넘어오며 새로 추가된 요소인 NLB,
NAT Instance, Reverse Proxy를 의심했다. 이 중 NAT Instance는 outbound 중계가, Reverse Proxy는
외부 요청 포워딩이 정상 동작하는 것을 확인해 용의선상에서 제외했다. 결국 남는 건 NLB 하나였다.
control-plane에서 kubectl을 실행하면 kubeconfig의 server 값을 읽어 요청을
`https://<NLB-endpoint>:6443`으로 보낸다 — 즉 control-plane의 apiserver 접근 경로가 반드시
NLB를 거치도록 되어 있어, 관련이 있을 것이라는 심증이 굳어졌다. 이 가설로 NLB 관련 이슈를 찾아본
결과, NLB가 지원하지 않는 루프백(hairpinning) 문제임을 알게 됐다. NLB는 client IP 보존이 켜져
있을 때 요청이 자기 자신으로 되돌아가는 경로를 처리하지 못한다. control plane은 NLB의 타겟이면서
동시에 NLB로 요청을 보내는 클라이언트였기 때문에, NLB가 3대 중 요청을 보낸 자기 자신을 고를
때만 연결이 실패했던 것이다. Terraform으로 NLB를 설계할 때 타겟 그룹에
`preserve_client_ip = false` 한 줄을 추가해 이 문제를 해결했다.
