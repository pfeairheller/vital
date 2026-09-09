# vLEI Credential Hierarchy Graph with Proposed Credentials Inline

```mermaid
---
config:
  layout: dagre
---
classDiagram
direction TB
    class `GLEIF Root AID` {
	    12 Signing Keys
	    12 Rotation Keys
	    5 Witnesses
    }

    class `GLEIF External AID` {
	    3 Signing Keys
	    3 Rotation Keys
	    5 Witnesses
    }

    class `GLEIF Internal AID` {
	    3 Signing Keys
	    3 Rotation Keys
	    5 Witnesses
    }

    class `QVI AID` {
	    3 Signing Keys
	    3 Rotation Keys
	    5 Witnesses
    }

    class `Legal Entity vLEI Credential` {
	    LEI
    }

    class `Qualified vLEI Issuer vLEI Credential` {
	    LEI
	    gracePeriod
    }

    class `Engagement Context Role vLEI Credential` {
	    LEI
	    personLegalName
	    engagementContextRole
    }

    class `ECR Person AID` {
	    1 Signing Key
	    1 Rotation Key
	    5 Witnesses
    }

    class `Qualification Agent vLEI Credential` {
	    LEI
	    gracePeriod
    }

    class `Qualification Agent AID` {
	    3 Signing Keys
	    3 Rotation Keys
	    5 Witnesses
    }

    class `ECR Authorization vLEI Credential` {
	    AID
	    LEI
	    personLegalName
	    engagementContextRole
    }

    class `Legal Entity AID` {
	    1 - 2 Signing Keys
	    1 - 2 Rotation Keys
    }

    class `Legal Entity Subdivision vLEI Credential` {
	    LEI
	    subdivisionName
    }

    class `Subdivision AID` {
	    2 Signing Keys
	    2 Rotation Keys
	    5 Witnesses
    }

    class `LESR Authorization vLEI Credential` {
	    AID
	    LEI
	    legalEntityRole
    }

    class `Legal Entity Role Subdivision vLEI Credential` {
	    LEI
	    legalEntitySubdivisionRole
    }

    class `Legal Entity Agent AID` {
	    1 Signing Key
	    1 Rotation Key
	    5 Witnesses
    }

    class `Legal Entity Agent vLEI Credential` {
	    LEI
	    agentName
    }

    class `Legal Entity Subdivision Agent vLEI Credential` {
	    LEI
	    subdivisionAgentName
    }

    class `Legal Entity Subdivision Agent AID` {
	    1 Signing Key
	    1 Rotation Key
	    5 Witnesses
    }

	<<AID>> `GLEIF Root AID`
	<<AID>> `GLEIF External AID`
	<<AID>> `GLEIF Internal AID`
	<<AID>> `QVI AID`
	<<vLEICredential>> `Legal Entity vLEI Credential`
	<<vLEICredential>> `Qualified vLEI Issuer vLEI Credential`
	<<vLEICredential>> `Engagement Context Role vLEI Credential`
	<<AID>> `ECR Person AID`
	<<vLEICredential>> `Qualification Agent vLEI Credential`
	<<AID>> `Qualification Agent AID`
	<<vLEICredential>> `ECR Authorization vLEI Credential`
	<<AID>> `Legal Entity AID`
	<<vLEICredential>> `Legal Entity Subdivision vLEI Credential`
	<<AID>> `Subdivision AID`
	<<vLEICredential>> `LESR Authorization vLEI Credential`
	<<vLEICredential>> `Legal Entity Role Subdivision vLEI Credential`
	<<AID>> `Legal Entity Agent AID`
	<<vLEICredential>> `Legal Entity Agent vLEI Credential`
	<<vLEICredential>> `Legal Entity Subdivision Agent vLEI Credential`
	<<AID>> `Legal Entity Subdivision Agent AID`

    `GLEIF Root AID` --> `GLEIF External AID` : delegatesTo
    `GLEIF Root AID` --> `GLEIF Internal AID` : delegatesTo
    `GLEIF External AID` ..> `QVI AID` : delegatesTo
    `GLEIF External AID` ..> `Qualified vLEI Issuer vLEI Credential` : issues
    `Qualified vLEI Issuer vLEI Credential` ..> `QVI AID` : issuedTo
    `QVI AID` ..> `Legal Entity vLEI Credential` : issues
    `Legal Entity vLEI Credential` ..> `Legal Entity AID` : issuedTo
    `QVI AID` ..> `Engagement Context Role vLEI Credential` : issues
    `Engagement Context Role vLEI Credential` ..> `ECR Person AID` : issuedTo
    `GLEIF External AID` ..> `Qualification Agent vLEI Credential` : issues
    `Qualification Agent vLEI Credential` ..> `Qualification Agent AID` : issuedTo
    `Qualification Agent AID` ..> `Qualified vLEI Issuer vLEI Credential` : issues
    `GLEIF External AID` ..> `Qualification Agent AID` : delegatesTo
    `Qualification Agent AID` ..> `QVI AID` : delegatesTo
    `Legal Entity AID` ..> `ECR Authorization vLEI Credential` : issues
    `ECR Authorization vLEI Credential` ..> `QVI AID` : issuedTo
    `ECR Authorization vLEI Credential` <..> `Legal Entity vLEI Credential` : chainedTo
    `ECR Authorization vLEI Credential` <..> `Engagement Context Role vLEI Credential` : chainedTo
    `Legal Entity AID` ..> `Legal Entity Subdivision vLEI Credential` : issues
    `Legal Entity Subdivision vLEI Credential` ..> `Subdivision AID` : issuedTo
    `Legal Entity Subdivision vLEI Credential` <..> `Legal Entity vLEI Credential` : chainedTo
    `Legal Entity AID` ..> `Engagement Context Role vLEI Credential` : issues
    `Legal Entity AID` ..> `LESR Authorization vLEI Credential` : issues
    `LESR Authorization vLEI Credential` ..> `QVI AID` : issuedTo
    `QVI AID` ..> `Legal Entity Role Subdivision vLEI Credential` : issues
    `Legal Entity Role Subdivision vLEI Credential` ..> `Subdivision AID` : issuedTo
    `Legal Entity Role Subdivision vLEI Credential` <..> `Legal Entity Subdivision vLEI Credential` : chainedTo
    `Legal Entity Role Subdivision vLEI Credential` <..> `LESR Authorization vLEI Credential` : chainedTo
    `ECR Person AID` ..> `Legal Entity Agent vLEI Credential` : issues
    `Legal Entity Agent vLEI Credential` ..> `Legal Entity Agent AID` : issuedTo
    `Legal Entity Agent vLEI Credential` <..> `Engagement Context Role vLEI Credential` : chainedTo
    `Subdivision AID` ..> `Legal Entity Subdivision Agent vLEI Credential` : issues
    `Legal Entity Subdivision Agent vLEI Credential` -- `Legal Entity Subdivision Agent AID`
    `Legal Entity Subdivision Agent vLEI Credential` <..> `Legal Entity Role Subdivision vLEI Credential` : chainedTo

	class `Qualification Agent vLEI Credential`:::Peach
	class `Qualification Agent AID`:::Peach
	class `Legal Entity Subdivision vLEI Credential`:::Peach
	class `Subdivision AID`:::Peach
	class `LESR Authorization vLEI Credential`:::Peach
	class `Legal Entity Role Subdivision vLEI Credential`:::Peach
	class `Legal Entity Agent AID`:::Peach
	class `Legal Entity Agent vLEI Credential`:::Peach
	class `Legal Entity Subdivision Agent vLEI Credential`:::Peach
	class `Legal Entity Subdivision Agent AID`:::Peach

	classDef Peach :,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D,stroke-width:1px,stroke-dasharray:none,stroke:#FBB35A,fill:#FFEFDB,color:#8F632D```