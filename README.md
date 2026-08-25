# VITAL Initiative

## Verifiable Identity and Trust Automation Layer

Piloting a trusted, automated framework for healthcare organizational ID via open source, open standard protocols.

This repository contains the schema, documentation and links to open source for the VITAL Initiative, a project aimed at creating a trusted, automated framework for healthcare organizational ID using open source, open standard protocols.

### Schema
The follow table contains the schema for the GLEIF vLEI Ecosystem as well as proposed schema for the VITAL pilot project.


| Schema Name                                                                             | Schema SAID                                                                           | OOBI (link) to Verifiable Schema                                               | Version | Status    | Notes |
|-----------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|---------|-----------|-------|
| Qualified&nbsp;vLEI&nbsp;Issuer&nbsp;Credential                                         | EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao                                          | https://weboftrust.github.io/oobi/EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao | 1.0.0   | Published |       |
| Legal Entity vLEI Credential                                                            | <span style="white-space: nowrap">ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY</span> | https://weboftrust.github.io/oobi/ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY | 1.0.0   | Published |       |
| Legal&nbsp;Entity&nbsp;Official&nbsp;Organizational&nbsp;Role&nbsp;vLEI&nbsp;Credential | EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy                                          | https://weboftrust.github.io/oobi/EBNaNu-M9P5cgrnfl2Fvymy4E_jvxxyjb70PRtiANlJy | 1.0.0   | Published |       |
| OOR Authorization vLEI Credential                                                       | EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E                                          | https://weboftrust.github.io/oobi/EKA57bKBKxr_kN7iN5i7lMUxpMG-s19dRcmov1iDxz-E | 1.0.0   | Published |       |
| Legal&nbsp;Entity&nbsp;Engagement&nbsp;Context&nbsp;Role&nbsp;vLEI&nbsp;Credential      | EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw                                          | https://weboftrust.github.io/oobi/EEy9PkikFcANV1l7EHukCeXqrzT1hNZjGlUk7wuMO5jw | 1.0.0   | Published |       |
| ECR Authorization vLEI Credential                                                       | EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g                                          | https://weboftrust.github.io/oobi/EH6ekLjSr8V32WyFbGe1zXjTzFs9PkTYmupJ9H65O14g | 1.0.0   | Published |       |

Note: <i>Files are available in the schema folder of the repository, keyed by SAID.</i>

### Open Source

The following table contains the open source repositories available for participants in the VITAL Initiative:

| Repository Name   | Description                                                 | Link                                            | Language/Stack   | Purpose                                                      |
|-------------------|-------------------------------------------------------------|-------------------------------------------------|------------------|--------------------------------------------------------------|
| Castellan         | Enterprise credential management server                     | https://github.com/healthKERI/castellan         | Python           | Backend server for managing KERI identifiers and credentials |
| Castellan Plugin  | Enterprise credential management UI (for Locksmith)         | https://github.com/healthKERI/castellan-plugin  | Python / PySide6 | Client library for interacting with Castellan servers        |
| Sentinel          | Local watcher framework and library                         | https://github.com/healthKERI/sentinel          | Python           | Local watcher framework for managing keystate updates        |
| KERI              | Key Event Receipt Infrastructure core                       | https://github.com/WebofTrust/keripy            | Python           | Core KERI protocol implementation                            |
| libkeri           | Key Event Receipt Infrastructure core                       | https://github.com/healthKERI/libkeri           | Rust             | Core KERI protocol implementation                            |
| Locksmith         | Keys at the Edge KERI Wallet                                | https://github.com/keri-foundation/locksmith    | Python / PySide6 | Server for issuing and managing vLEI credentials             |
| Witness Server    | Deployable KERI Witnesses                                   | https://github.com/keri-foundation/witness-hk   | Python           | Server for issuing and managing vLEI credentials             |
| Watcher Server    | Deployable KERI Watchers                                    | https://github.com/keri-foundation/watcher-hk   | Python           | Server for issuing and managing vLEI credentials             |
| ACDC Auth Arbiter | Credential arbiter for presentation and issuance            | https://github.com/healthKERI/acdc-auth-arbiter | Python           | Managing automated issuance of Use Case credentials          |
| ACDC Auth Server  | ACDC/OAuth2 Authorization Server and OIDC Identity Provider | https://github.com/healthKERI/acdc-auth-server  | Python           | Implementation of UDAP inspired vLEI OAuth identity provider |
| ACDC Auth Client  | ACDC OAuth2 Client                                          | https://github.com/healthKERI/acdc-auth-client  | Python           | Implementation of UDAP inspired vLEI OAuth client            |

Additional resources and documentation can be found at:

- KERI Documentation: https://keri.one
- WebOfTrust GitHub Organization: https://github.com/WebOfTrust
- GLEIF vLEI
  Resources: https://www.gleif.org/en/lei-solutions/gleifs-digital-strategy-for-the-lei/introducing-the-verifiable-lei-vlei
