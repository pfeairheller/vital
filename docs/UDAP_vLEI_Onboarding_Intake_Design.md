# Asynchronous Onboarding Intake for UDAP + vLEI

## Purpose-of-Use Allow Lists with Human Review

**Status:** Draft v0.1 — for discussion
**Date:** 19 September 2026
**Author:** Mark Scrimshire, Onyx Technology LLC
**Intended audience:** HL7 FAST Security and FAST Identity work groups; implementers preparing the CVS ↔ Cambia payer-to-payer POC
**Relationship to other documents:** Technical companion to the executive whitepaper on LEI/vLEI adoption. Extends the profiling guidance in `LEI_vLEI_Profiling.md` §B.7 (Alignment with UDAP and the FAST Security IG).

> This document is offered as input to the FAST work groups, not as a vendor specification. Its value depends on being standardised — a per-payer variant of this design would recreate the integration burden it exists to remove.

---

## 1. Problem statement

UDAP Dynamic Client Registration is synchronous and binary. The current FAST Security IG defines exactly two registration outcomes: `201 Created` on success, or an RFC 7591 §5.2 error on rejection. There is no pending state, no deferred outcome, and no provision for manual review. The IG is also silent on purpose of use, allow lists, and per-purpose authorization.

This creates three practical problems in payer-to-payer and multi-network exchange:

1. **First contact between two organisations is a business decision, not a technical one.** It involves security review, contract verification, and a judgement about which purposes of use are appropriate. None of that completes inside an HTTP request.
2. **Because the protocol has no way to say "under review," the honest answer today is silence** — a dropped request and a queued request are indistinguishable to the requester. This is the dominant operational failure mode in practice.
3. **Purpose of use is where the actual authorization decision lives**, but neither UDAP nor SMART has a defined slot to express it at registration or at runtime.

This design closes all three without modifying UDAP's existing behaviour.

---

## 2. Design principles

| Principle | Consequence |
|---|---|
| First contact is asynchronous; steady state is not | Review cost is paid once per legal entity, not per certificate lifecycle event |
| Silence is never a valid state | Every request returns a status and a stated next-check time |
| Polling is the contract | A push channel may be added later without breaking any client |
| The allow list is keyed on the legal entity, not the certificate | Certificate rotation, CA change and client rebuild are free |
| Purpose of use is the unit of decision | Approval, rejection, expiry and audit are all per-purpose |
| Backward compatible by omission | A responder that does not implement this simply does not advertise it |

---

## 3. Flow overview

```
Requester                                    Responder
    |                                             |
    |--- POST /udap/onboarding ------------------->|
    |     (signed packet: AID, LEI, OOBI,          |
    |      requested PoU set, contacts)            |
    |                                             |-- machine verification
    |                                             |   (vLEI chain, OOBI, TEL)
    |                                             |
    |<-- 202 Accepted -----------------------------|
    |    Content-Location: /udap/onboarding/{id}   |-- admitted to review queue
    |    Retry-After: 3600                         |   (only unknown tuples)
    |    { per-PoU status, decision_due }          |
    |                                             |
    |--- GET /udap/onboarding/{id} --------------->|   [human review]
    |<-- 202 Accepted, Retry-After: 7200 ----------|
    |                                             |
    |                                             |-- decision recorded;
    |                                             |   (AID, PoU) written to
    |                                             |   PoU allow list(s)
    |--- GET /udap/onboarding/{id} --------------->|
    |<-- 200 OK -----------------------------------|
    |    { TREAT: approved, HPAYMT: rejected }     |
    |                                             |
    |--- POST /register (standard UDAP DCR) ------>|
    |<-- 201 Created ------------------------------|-- synchronous; scopes
    |    (client_id, approved scopes)              |   from allow list
```

The intake endpoint returns plain JSON on the OAuth surface — the same shape as UDAP DCR responses. The requester never needs to touch FHIR. `Task` (or an equivalent) may be used *internally* by the responder to drive its review workflow, but that is an implementation choice and is not exposed.

---

## 4. Discovery

Responders that implement this advertise one additional field in UDAP `.well-known` metadata:

```json
{
  "onboarding_endpoint": "https://payer.example.com/udap/onboarding",
  "onboarding_default_decision_days": 3,
  "onboarding_supported_purposes": [
    "TREAT", "HPAYMT", "HOPERAT"
  ],
  "onboarding_escalation_contact": "interop-escalation@payer.example.com"
}
```

Absence of `onboarding_endpoint` means the responder does not support asynchronous intake; requesters fall back to whatever out-of-band onboarding that organisation uses today. No existing client behaviour changes.

---

## 5. Submission packet

```json
{
  "correlation_id": "req-2026-09-19-0001",
  "legal_entity": {
    "lei": "5493001KJTIIGC8Y1R12",
    "aid": "EKYCb1H2oT9r...",
    "qvi_lei": "254900OPPU84GM83MG36",
    "oobi": [
      "https://requester.example.org/.well-known/vlei/oobi",
      "https://witness3.qvi.example/oobi/EKYCb1H2oT9r..."
    ]
  },
  "submitter": {
    "ecr_said": "EJ8s2...",
    "role": "Data Exchange Representative"
  },
  "requested_purposes": [
    { "purpose": "TREAT",   "scopes": ["system/Patient.rs", "system/Observation.rs"] },
    { "purpose": "HPAYMT",  "scopes": ["system/Claim.rs"] }
  ],
  "client_metadata": { "…": "as per UDAP DCR" },
  "contacts": {
    "technical": "interop-eng@requester.example.org",
    "security":  "security@requester.example.org"
  }
}
```

**The packet MUST be signed by a key chained from the declared AID's KEL.**

This is architecturally significant. In the side-by-side integration pattern described in `LEI_vLEI_Profiling.md` §B.7.2(1), nothing cryptographically binds the X.509 client credential to the vLEI it references — a party holding a valid UDAP certificate could point at another organisation's published anchor. Requiring the intake packet to be AID-signed **closes that binding gap once, at onboarding, under human review**. The resulting allow-list entry records the binding, so runtime never has to re-solve it.

An ECR identifying the submitter is RECOMMENDED. It is what a security reviewer actually wants to see: not merely which organisation submitted, but which authorised individual within it.

---

## 6. Idempotency model

**The idempotency key is the `(AID, Purpose of Use)` tuple — not the submission.**

Keying on the whole submission breaks as soon as a requester submits `{TREAT}` and later `{TREAT, HPAYMT}`: neither a duplicate nor wholly new. Every submission is therefore decomposed into tuples, and each tuple has exactly one state at any time.

On receipt of a submission, for each tuple:

| Tuple state | Action |
|---|---|
| Unknown | Create one review queue entry |
| `in-review` or `escalated` | No queue entry; return current state with an extended `Retry-After` |
| `approved` and unexpired | No queue entry; return `approved` immediately |
| `rejected` | No queue entry; return `rejected` (see §9) |
| `expired` or `suspended` | Create one queue entry (re-review) |

The key is the **AID**, because the AID is stable across key rotation. The LEI is carried alongside as the legal and business record but is not the technical key.

**This is what makes certificate rotation free.** Same AID, same purpose of use, already approved → `200 approved` on the first call, no human involvement, no re-review.

---

## 7. State model

| State | Meaning | Terminal? |
|---|---|---|
| `pending-verification` | Machine verification in progress (seconds) | No |
| `in-review` | Admitted to the human review queue | No |
| `escalated` | Decision due date breached (§8) | No |
| `approved` | Written to the purpose-of-use allow list | Yes, until expiry |
| `rejected` | Declined; resubmission constrained (§9) | Yes |
| `expired` | Approved grant passed its review date | No — re-review |
| `suspended` | Runtime revocation detected (§11) | No — re-review |

Only tuples that pass machine verification enter `in-review`. **Chain-invalid submissions never reach a human** — this is both the correctness rule and the queue's abuse control.

---

## 8. Decision due and escalation

### Configuration

`decision_due_days` is a responder-configured parameter, **default 3**.

- It MAY be overridden per purpose of use. A novel or high-sensitivity purpose reasonably warrants a longer window than Treatment.
- The configured default is advertised in `.well-known` metadata so requesters know the expected turnaround before submitting.
- The responder computes and returns an **absolute UTC timestamp** per tuple. The requester never calculates the deadline itself.

### Clock start

The clock starts **on admission to the review queue**, not on receipt of the submission. A submission that cannot complete machine verification because an OOBI or witness is unreachable returns `503` and does not consume review time.

> **Open decision (§14):** business days or calendar days. Three calendar days spanning a weekend yields roughly one business day of actual review. The recommendation is that responders compute the deadline on business days in a declared timezone, but the returned value remains an absolute timestamp either way.

### Breach behaviour

On breach the tuple moves `in-review` → `escalated`, and:

1. The state change is **visible to the requester** in the status response. This is the whole point — an escalated request is distinguishable from a stalled one.
2. `Retry-After` is **shortened**, not lengthened. Escalation signals that a decision is now expected imminently.
3. The response exposes `escalation_contact` so the requester has a named human to pursue.
4. A secondary deadline is set (default: a further `decision_due_days`).

```json
{
  "purpose": "HPAYMT",
  "status": "escalated",
  "decision_due": "2026-09-22T17:00:00Z",
  "escalated_at": "2026-09-22T17:00:01Z",
  "escalation_due": "2026-09-25T17:00:00Z",
  "escalation_contact": "interop-escalation@payer.example.com"
}
```

Escalation is deliberately **not** auto-resolving. Auto-rejection is hostile to a partner whose submission is merely stuck in someone's queue; auto-approval is a security hole. Beyond the escalation state, technology has done all it usefully can — the matter becomes governance, and the applicable path is the network's (TEFCA Common Agreement and SOPs, or the bilateral trading-partner agreement). What this design guarantees is that the condition is *visible and attributable on both sides*, which is the precondition for any governance path working at all.

---

## 9. Rejection and resubmission

A rejected tuple requires a **material change** before it will be reconsidered. Under the tuple model this resolves cleanly without needing a subjective test:

- Resubmitting a **rejected tuple unchanged** returns its existing `rejected` state. No queue entry is created.
- Submitting a **new purpose of use** creates a new tuple, which enters review normally. A rejection of `HPAYMT` does not prejudice a later request for `TREAT`.
- Resubmitting an **identical packet** (canonical hash match) after rejection returns `409 Conflict` with a `Retry-After`, to stop reject-resubmit loops.

The responder MAY set either of the following on a rejection:

| Field | Effect |
|---|---|
| `resubmit_after` | Timestamp before which the tuple will not be reconsidered |
| `remediation` | Free-text statement of what would need to change |

If neither is set, the rejection is indefinite and the requester must pursue the escalation contact. That is an intentional, honest outcome: some rejections are business decisions that no protocol should let a requester retry their way past.

---

## 10. HTTP semantics

Purpose-of-use results are inherently mixed — one submission for three purposes may return approved, in-review and rejected simultaneously. No single HTTP status expresses that. The envelope status therefore signals only *whether polling should continue*, and per-purpose detail lives in the body.

| Condition | Status | Notes |
|---|---|---|
| Any tuple non-terminal | `202 Accepted` | `Content-Location`, `Retry-After` |
| All tuples terminal | `200 OK` | Unambiguous "stop polling" |
| Malformed packet / schema invalid | `400 Bad Request` | |
| Packet signature invalid or not chained to declared AID | `401 Unauthorized` | |
| vLEI chain invalid, revoked, or duplicitous | `403 Forbidden` | Never queued |
| vLEI indeterminate (OOBI/witness unreachable) | `503 Service Unavailable` | `Retry-After`; clock not started |
| Identical packet resubmitted after rejection | `409 Conflict` | `Retry-After` |
| Polling faster than `Retry-After` | `429 Too Many Requests` | `Retry-After` |

**Rejection returns `200`, not `403`.** The submission was processed correctly; the *decision* was negative. Conflating a business decision with a transport failure loses the mixed-result case and degrades client error handling.

`GET` on the status URI is the polling path — it returns cached state without re-running chain verification. `POST` is reserved for a genuine change to the requested tuple set.

### Backpressure

`Retry-After` is the sole flow-control mechanism, and the responder owns it entirely. Suggested escalation on repeat polls: 60s → 300s → 3600s → 86400s, adjusted against actual queue depth, and shortened when a decision is near or a tuple has escalated.

Ignoring `Retry-After` is a conformance violation and is met with `429`.

This is also what closes out the original operational question. There is no longer any silence at ten minutes or at one day: there is always a state, a reason, and a stated next-check time.

---

## 11. Allow list entry

On approval, the tuple is written to the allow list for that purpose of use:

| Field | Purpose |
|---|---|
| `aid` | Technical key — stable across key rotation |
| `lei` | Legal and business record |
| `purpose` | The purpose of use this grant authorises |
| `scopes` | Permitted scopes under this purpose |
| `conditions` | Rate limits, data segment restrictions |
| `granted_at` / `review_due` | Grant validity and mandatory re-review date |
| `decision_provenance` | Approver, timestamp, ticket reference — for audit |

### The allow list is a cached decision, not a standing grant

An LEI can lapse, a vLEI credential can be revoked, and an ECR can expire between approval and use. The authorization server SHOULD therefore perform a cheap, cached vLEI status check at token issuance rather than trusting the allow list blindly.

Critically, apply the distinction from the verification taxonomy in §12:

- **Invalid** (cryptographic failure, revocation confirmed) → `suspend` the entry.
- **Indeterminate** (OOBI or witness unreachable) → **do not** suspend.

Suspending on indeterminate means a single witness outage revokes every trading partner simultaneously. This is the single most consequential error an implementer can make in this design.

---

## 12. Verification outcome taxonomy

Seven outcomes, six of which require different operational responses. Conflating them is what makes multi-party debugging expensive.

| Outcome | Meaning | Response |
|---|---|---|
| Verified | Chain valid, witness threshold met | Admit to review / proceed |
| Not-presented | No vLEI anchor supplied | Policy: fail-open + log, or fail-closed |
| Indeterminate | Verification material unreachable | `503`, retry — availability issue |
| Invalid | Cryptographic verification failed | `403` — security event |
| Revoked | TEL shows credential revoked | `403` |
| Duplicitous | OOBIs return inconsistent key state | `403` + security review |
| Verified-but-unauthorised | Chain valid; no agreement with this entity | Queue for review |

Every failure response MUST return a correlation identifier. UDAP endpoints correctly do not leak verification detail to unauthenticated parties, which means without a correlation ID the two sides cannot reconcile logs and every failure becomes a week of email.

> **Duplicity in practice:** inconsistent key state is the one condition KERI exists to detect, and the specification says fail hard. In practice, stale witnesses and partial sync following a rotation will be far more common than genuine duplicity. Without an operational path to distinguish the two, responders will either suffer alarm fatigue or learn to wave the condition through. This is flagged as an open issue for FAST Identity.

---

## 13. Why the vLEI is load-bearing here

The asynchronous intake pattern would work with X.509 alone. What the vLEI changes is the economics.

| Event | X.509-keyed allow list | AID-keyed allow list |
|---|---|---|
| Certificate routine rotation | Re-review or re-register | No change |
| Emergency key rotation | Re-review | KEL records rotation; no change |
| CA distrust / root program change | Full re-review | No change |
| TLS provider change | Re-review | No change |
| New client implementation | Re-register; possibly re-review | Same grant, client auth rebuilt |
| Joining an additional network | Full re-review under new trust list | Same AID, same decision — reusable |

Two further effects on review cost itself:

- The reviewer sees a **GLEIF-verified legal entity name**, not a certificate subject string requiring independent investigation. This removes an entire class of "is this actually them?" review effort.
- The ECR identifies **which authorised individual** submitted on the organisation's behalf — evidence a security reviewer would otherwise have to obtain by email.

**The executive-facing statement:** first contact with a trading partner costs a human review. Everything thereafter — certificate rotation, new client, new environment, CA change, additional network — costs one HTTP round trip and returns approved. This design is what makes that literally true rather than aspirational.

---

## 14. Open decisions

| # | Decision | Owner |
|---|---|---|
| 1 | Business days or calendar days for `decision_due_days` (§8) | FAST Security |
| 2 | Runtime purpose-of-use assertion mechanism (see below) | FAST Security |
| 3 | Purpose-of-use value set binding — TEFCA Exchange Purposes, HL7 v3 `PurposeOfUse`, or both | FAST Identity |
| 4 | `Not-presented` default posture: fail-open with logging, or fail-closed | Deployment policy |
| 5 | Whether a lapsed LEI with a cryptographically valid vLEI is acceptable | FAST Identity |
| 6 | Parent/subsidiary policy — requester presents a subsidiary LEI, agreement names the parent | Deployment policy |
| 7 | Duplicity vs. mid-rotation operational distinction (§12) | FAST Identity |

### On decision 2 — the significant remaining gap

The allow list is only meaningful if the runtime token request states *which approved purpose it is exercising*, and UDAP/SMART has no defined slot for this. Three options:

1. **Purpose-qualified scopes** — non-standard, breaks tooling. Not recommended.
2. **A `purpose_of_use` token request parameter** validated against the allow list — the correct long-term answer; requires a specification change.
3. **One `client_id` per approved purpose of use** — works with entirely unmodified UDAP today, and yields clean per-purpose audit, revocation and rate limiting as a side effect.

**Recommendation:** adopt option 3 for the POC and raise option 2 with FAST Security as the longer-term ask.

---

## 15. Standardisation footprint

Deliberately small, which is what makes it a plausible work group proposal:

1. `onboarding_endpoint` and associated fields in UDAP `.well-known` metadata
2. The submission packet schema and its AID-signing requirement
3. The status object shape — per-purpose status array with `decision_due`
4. `Retry-After` conformance and the `202`/`200` polling contract
5. A purpose-of-use value set binding

Nothing in this list changes existing UDAP DCR behaviour. A responder that does not implement it is unaffected.

---

## 16. POC scope — 19 October 2026

Full implementation is more than the available window supports. Minimum viable scope that still produces a defensible finding:

**In scope**

- Intake endpoint returning `202` with `Content-Location` and `Retry-After`
- `(AID, PoU)` tuple decomposition and idempotent resubmission
- A single purpose of use
- Manual status transition standing in for a review interface
- Polling to `200`, then standard UDAP DCR yielding the approved scopes
- **A deliberate certificate rotation mid-test**, to demonstrate that the AID-keyed allow-list entry survives it

**Out of scope**

- Escalation automation (model the state; trigger it by hand)
- Multiple concurrent purposes of use
- Any push notification channel
- Production traffic, member data, or changes to either payer's live infrastructure

**The finding to target:** that an approval keyed on the legal entity survives a PKI lifecycle event without human re-review. That is the claim the executive whitepaper rests on, and it is cheap to demonstrate and hard to argue with.

Agree a decision-due value, an escalation contact, and a no-response SLA on both sides *before* the test window opens. Otherwise the window will be spent debugging silence — which is precisely the failure this design exists to eliminate.

---

## References

- [Security for Scalable Registration, Authentication, and Authorization (FAST Security IG) — Registration](https://build.fhir.org/ig/HL7/fhir-udap-security-ig/registration.html)
- [UDAP Dynamic Client Registration](https://www.udap.org/udap-dynamic-client-registration.html)
- RFC 7591 — OAuth 2.0 Dynamic Client Registration Protocol
- RFC 8615 — Well-Known Uniform Resource Identifiers
- `LEI_vLEI_Profiling.md` — LEI and vLEI Profiling for Verifiable Organizational Identity, §B.5.2, §B.6, §B.7
