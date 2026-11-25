# Pattern: Network Connectivity Diagnosis
Status: optional | Sources: Networking Basics full user-provided text (E31, reviewed 2026-11-11); engineering recommendations

## Pattern Card

| Field | Summary |
|---|---|
| Purpose | 연결 장애를 계층별로 좁혀 처음 관찰되는 실패 경계와 실제 근본 원인을 구분한다. |
| When to Use | 접속 불가, 타임아웃, 간헐적 실패, 배포 후에만 실패, DNS/방화벽/TLS/MTU 의심. |
| When Not to Use | 애플리케이션 로직 오류가 로그로 이미 확정된 경우. |
| Alternatives | Cloud 콘솔 진단 도구, APM/트레이싱, 서비스 메시 관측. |
| Implementation Rules | 위에서 아래로 한 단계씩 확인, 증상을 정확히 기록, 읽기 전용 명령 우선. |
| Trade-offs | 절차는 빠르지만 중간 장비·외부 정책을 볼 수 없으면 한계가 있다. |
| Security Considerations | 패킷 캡처에 민감 데이터가 있을 수 있다. 방화벽 규칙 변경, 포트 개방은 승인. |
| Testing & Acceptance Criteria | 실패 단계가 재현되고 수정 후 같은 단계에서 통과, 재발 방지 설정 기록. |
| Resource & Token Cost | 캡처 크기, 진단 시간. |
| References | E31 [S]. |

## Guardrails
Read-only checks (`ip`, `ss`, `dig`, `curl`, `traceroute`, `openssl s_client`, `nc`) are fine. Changing firewall/security-group/NACL/route/DNS records, packet-loss or delay injection, `iptables`, and long captures on shared hosts need approval; restore any change you make. Labels: [S] Source-derived, [R] Engineering recommendation.

### Order of checks (first failure is evidence, not automatically the root cause)
Link up -> address and route (`ip addr`, `ip route get`) -> same-network reach (ARP/neighbors) -> outside reach by IP -> DNS by name -> port reachable -> listening address -> TLS -> HTTP.
- [S] IP works but name fails: DNS only. Port fails while ICMP succeeds: firewall or service, not routing. ICMP can be blocked while the service is fine; test the port.
- [S] Immediate "connection refused" means the host answered: service down, wrong bind, or REJECT. Long timeout means packets are dropped: DROP rule, security group, or no route. Many sockets in SYN-SENT point to drops; many in CLOSE-WAIT mean the local application does not close connections.
- [S] A service bound to `127.0.0.1` is unreachable from outside; check `ss -tlnp` before touching firewalls. Inside the host works but outside fails: network rules.
- [S] Cloud layers: host firewall, security group (stateful), network ACL (stateless; open return ports too), route table. A wrong subnet mask makes some addresses silently unreachable. Overlapping private CIDRs block later peering/VPN; choose non-overlapping ranges up front.
- [S] Break a slow request into DNS, TCP, TLS, first-byte and total with `curl -w`; large payloads slow means bandwidth/window, small requests slow means latency/RTT, intermittent means loss, and a hang above a certain size means MTU (probe with `ping -M do -s`; ICMP blocked; clamp MSS or lower MTU).
- [S] Always pass the server name when testing TLS (SNI) and read the verify result and expiry date. Expired or incomplete chains are common causes.

### Intermittent and deploy-time failures
- [S] Idle connections silently dropped by NAT or load balancers cause first-request failures after quiet periods. The timeout is provider/configuration-specific: verify it, then set TCP keepalive/pool validation and max connection lifetime below the shortest measured/configured idle timeout; reuse connections to avoid ephemeral-port exhaustion instead of tuning kernel TIME_WAIT.
- [S] DNS changes propagate by TTL across several caches, including long-lived application and JVM caches and connection pools. Lower TTL before a cutover; for instant switches change the load balancer target, not DNS; set application DNS cache TTL.
- [R] Record the failing layer, command output and time in the incident note; add a regression check (health probe, timeout setting, alert) for the cause.

### Read-only incident runbook

| Boundary | Observe without changing state | Interpretation / next evidence |
|---|---|---|
| Interface/link | `ip addr`, interface counters and link state | Down/link errors are local evidence; capture interface, error delta and timestamp before escalating. |
| Route/source | `ip route get <ip>` and neighbour state | Confirm chosen source address, interface and next hop; compare a working host before proposing route changes. |
| DNS | `dig <name>` and, when authorized, query the configured resolver and authoritative answer separately | Record resolver, answer, TTL and timing; compare name and direct-IP tests without treating an IP success as proof the application is healthy. |
| Port/listener | `nc -vz <host> <port>`, `curl -v`, local `ss -ltnp` | Refused, timeout and wrong bind mean different boundaries. Verify the process/listening address before firewall changes. |
| Socket state | `ss -tan` summaries and per-destination states | SYN-SENT suggests unanswered handshakes; CLOSE-WAIT suggests local close handling. Do not tune kernel limits before proving exhaustion. |
| TLS | `openssl s_client -connect host:port -servername name` | Record hostname verification, chain, expiry and negotiated protocol; do not disable verification as a fix. |
| Request timing | `curl -w` for DNS/connect/TLS/TTFB/total | Locate the slow phase and correlate it with server traces; one client measurement is not a capacity conclusion. |
| MTU/size | compare small/large transfers and use a read-only path-MTU probe where supported | Size-dependent stalls are evidence; MTU/MSS changes require approval and a rollback plan. |
| Packet evidence | a short, narrowly filtered capture only when permitted | Minimize duration/hosts/ports, protect payloads, and delete/retain according to incident policy. |

[R] For every run, record absolute time/time zone, source and destination, protocol/port, environment, command and result. After a fix, repeat the same failing check and the user-visible scenario. `sudo`, firewall/security-group, route, DNS, sysctl, MTU/MSS and packet-injection changes require approval.
