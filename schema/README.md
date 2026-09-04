# vLEI Credential Schemas

This directory contains JSON Schema definitions for ACDC (Authentic Chained Data Containers) credentials used in the vLEI (verifiable Legal Entity Identifier) ecosystem. These schemas define the structure and validation rules for credentials that establish legal entity identities, roles, and authorizations in a cryptographically verifiable manner.

## Overview

The vLEI ecosystem uses a hierarchical credential architecture where credentials chain together to establish trust. Each credential is a self-addressed data structure (using SAIDs - Self-Addressing Identifiers) that can reference other credentials through edge blocks, creating a verifiable chain of authority.

## Directory Structure

```
schema/
├── GLEIF/                           # Reference schemas from GLEIF
│   ├── LegalEntityvLEICredential.json
│   ├── QualifiedvLEIIssuervLEICredential.json
│   ├── ECRAuthorizationvLEICredential.json
│   ├── OORAuthorizationvLEICredential.json
│   ├── LegalEntityEngagementContextRolevLEICredential.json
│   └── LegalEntityOfficialOrganizationalRolevLEICredential.json
├── QualificationAgentvLEICredential.json
├── LegalEntitySubdivisionvLEICredential.json
├── LERAuthorizationvLEICredential.json
├── LegalEntityRolevLEICredential.json
├── ConnectionAuthorizationvLEICredential.json
└── schema-map.json
```

### GLEIF Reference Directory

The `GLEIF/` subdirectory contains the official GLEIF vLEI credential schemas. These are reference schemas maintained by the Global Legal Entity Identifier Foundation (GLEIF) and serve as the foundation for the vLEI ecosystem. The schemas in the root directory extend or build upon these base GLEIF schemas to support specific use cases and authorization patterns.

## Credential Schemas

### QualificationAgentvLEICredential.json

**Schema SAID:** `EOQD1-1y-l3FawXRncdNsCecE6qEGM1DPu6ZcvWNJ7x1`

**Description:** A foundational credential issued by GLEIF to Qualification Agents (QAs). This credential empowers Qualification Agents to issue, verify, and revoke Qualified vLEI Issuer (QVI) credentials, making them the trust roots that enable the entire vLEI ecosystem.

**Key Attributes:**
- `i` - Issuee AID (the Qualification Agent's KERI identifier)
- `LEI` - The Legal Entity Identifier of the requesting organization
- `dt` - Issuance date/time
- `gracePeriod` - Allocated grace period (default 90 days)

**Rules:**
- Usage disclaimer stating limitations of credential trustworthiness
- Issuance disclaimer asserting validation accuracy

**Dependencies:** None (root credential in the chain)

**Purpose:** Establishes the authority of Qualification Agents who can then issue QVI credentials. This is typically the first credential in any vLEI credential chain.

---

### LegalEntitySubdivisionvLEICredential.json

**Schema SAID:** `EOvrvccCry9lWXMqdlnysBJ3JYUQg6wihIsLM1_dc-4U`

**Description:** A credential issued to a Legal Entity Subdivision (department, division, branch office, etc.). This allows large organizations to create distinct verifiable identities for their organizational subdivisions.

**Key Attributes:**
- `i` - Issuee AID (the subdivision's KERI identifier)
- `LEI` - The Legal Entity Identifier of the parent organization
- `dt` - Issuance date/time
- `subdivisionLegalName` - The official name of the subdivision (optional)

**Edge Relationships:**
The credential supports two edge patterns:
1. **Subdivision chain** - References another subdivision (for nested hierarchies)
2. **Legal Entity chain** - References the parent Legal Entity vLEI credential (const: `ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY`)

**Rules:**
- Usage and issuance disclaimers (matching GLEIF standards)

**Dependencies:** Can depend on either a Legal Entity credential or another subdivision credential

**Purpose:** Enables organizations to issue verifiable identities to subdivisions, creating organizational hierarchies within the vLEI ecosystem.

---

### LERAuthorizationvLEICredential.json

**Schema SAID:** `EIM8yGRXvvsXyUnljtf87qfu5vhYaDSXnCqhc13hEctN`

**Description:** A Legal Entity Role Authorization credential issued by a Legal Entity to authorize a specific role within the organization. This credential authorizes the issuance of role credentials to individuals or systems.

**Key Attributes:**
- `i` - Issuee AID (the authorizing entity's identifier)
- `LEI` - The Legal Entity Identifier
- `dt` - Issuance date/time

**Edge Relationships:**
- `subdivision` - References a LegalEntitySubdivisionvLEICredential (const: `EOvrvccCry9lWXMqdlnysBJ3JYUQg6wihIsLM1_dc-4U`)

**Rules:**
- Usage, issuance, and privacy disclaimers
- Privacy considerations note the responsibility to use IPEX protocol for privacy-preserving presentation

**Dependencies:**
- LegalEntitySubdivisionvLEICredential

**Purpose:** Authorizes the creation of role credentials within a specific subdivision, enabling delegated authority management.

---

### LegalEntityRolevLEICredential.json

**Schema SAID:** `EC2pLemg70rwCwmTdNsJvX1xEQSTkrKb2ui9G2CbfATv`

**Description:** A credential issued to establish a specific role within a Legal Entity. This credential binds a KERI identifier to a named role within an organization (e.g., "Chief Financial Officer", "Authorized Signatory", "API Administrator").

**Key Attributes:**
- `i` - Issuee AID (the role holder's identifier)
- `LEI` - The Legal Entity Identifier
- `dt` - Issuance date/time
- `legalEntityRole` - The name/description of the role being assigned

**Edge Relationships:**
- `auth` - References a LERAuthorizationvLEICredential (const: `EIM8yGRXvvsXyUnljtf87qfu5vhYaDSXnCqhc13hEctN`)

**Rules:**
- Usage, issuance, and privacy disclaimers
- Privacy note about IPEX and ACDC specifications

**Dependencies:**
- LERAuthorizationvLEICredential
  - which depends on LegalEntitySubdivisionvLEICredential

**Purpose:** Establishes verifiable roles within organizations, enabling role-based authorization for business processes and API access.

---

### ConnectionAuthorizationvLEICredential.json

**Schema SAID:** `EGDtuI5vnaqd9JEZW2uX2_nLQWjuC9TNeW3Wd7RfZjIn`

**Description:** A sophisticated authorization credential that establishes a verifiable connection between two Legal Entity roles. This credential authorizes bidirectional or unidirectional relationships between organizations or roles (e.g., supplier-buyer, partner agreements, API access permissions).

**Key Attributes:**
- `i` - Issuee AID (the authorizing entity's identifier)
- `dt` - Issuance date/time

**Edge Relationships:**
- `grantee` - References a LegalEntityRolevLEICredential of the role receiving authorization
- `grantor` - References a LegalEntityRolevLEICredential of the role granting authorization
- Both edges must reference credentials with schema SAID: `EC2pLemg70rwCwmTdNsJvX1xEQSTkrKb2ui9G2CbfATv`

**Rules:**
- Usage, issuance, and privacy disclaimers
- Privacy considerations emphasize IPEX protocol usage

**Dependencies:**
- Two LegalEntityRolevLEICredentials (grantee and grantor)
  - Each depends on LERAuthorizationvLEICredential
    - which depends on LegalEntitySubdivisionvLEICredential

**Purpose:** Establishes cryptographically verifiable business relationships between legal entities. This is the most complex credential, sitting at the top of the dependency chain and enabling sophisticated multi-party authorization scenarios.

## Credential Chain Architecture

The credentials form a dependency hierarchy designed to avoid circular SAID dependencies:

```
QualificationAgentvLEICredential (root - no dependencies)
    |
    v
LegalEntitySubdivisionvLEICredential (depends on nothing in our schema)
    |
    v
LERAuthorizationvLEICredential (depends on subdivision)
    |
    v
LegalEntityRolevLEICredential (depends on auth)
    |
    v
ConnectionAuthorizationvLEICredential (depends on two roles)
```

This layered architecture ensures that:
1. SAIDs can be computed in a specific order (leaves first)
2. No circular dependencies exist
3. Credentials reference other credentials via edge blocks using already-computed SAIDs
4. Trust chains can be verified by traversing edges upward

## ACDC Structure

All credentials follow the ACDC specification and contain these top-level blocks:

- **v** - Version string (e.g., "ACDC10JSON000001_")
- **d** - Credential SAID (self-addressing identifier)
- **u** - One-time use nonce
- **i** - Issuer AID (KERI identifier)
- **ri** - Registry identifier (for revocation tracking)
- **s** - Schema SAID (references this schema)
- **a** - Attributes block (credential-specific data, can be SAID or full object)
- **e** - Edges block (references to other credentials, can be SAID or full object)
- **r** - Rules block (legal disclaimers, can be SAID or full object)

Each block can be represented as either:
- A SAID (compact form) - just the hash reference
- A full object (expanded form) - the complete data structure

## How To

### Understanding schema-map.json

The `schema-map.json` file defines the dependency relationships between credential schemas. It maps credential types to their edge dependencies, enabling the `vital generate` command to process schemas in the correct order.

**Structure:**
```json
{
  "CredentialTypeA": {},
  "CredentialTypeB": {
    "edgeName": "CredentialTypeA"
  },
  "CredentialTypeC": {
    "edgeName1": "CredentialTypeA",
    "edgeName2": "CredentialTypeB"
  }
}
```

**How it works:**

1. **Empty object** `{}` - Indicates a leaf node with no dependencies
   ```json
   "QualificationAgentvLEICredential": {}
   ```

2. **Edge mappings** - Maps edge property names to referenced credential types
   ```json
   "LERAuthorizationvLEICredential": {
     "subdivision": "LegalEntitySubdivisionvLEICredential"
   }
   ```
   This tells the generator: "In the LERAuthorizationvLEICredential schema, the edge named 'subdivision' should have its `s.const` value set to the SAID of LegalEntitySubdivisionvLEICredential"

3. **Multiple edges** - Credentials can reference multiple other credentials
   ```json
   "ConnectionAuthorizationvLEICredential": {
     "grantee": "LegalEntityRolevLEICredential",
     "grantor": "LegalEntityRolevLEICredential"
   }
   ```

**Our schema-map.json:**
```json
{
  "QualificationAgentvLEICredential": {},
  "LegalEntitySubdivisionvLEICredential": {},
  "LERAuthorizationvLEICredential": {
    "subdivision": "LegalEntitySubdivisionvLEICredential"
  },
  "LegalEntityRolevLEICredential": {
    "auth": "LERAuthorizationvLEICredential"
  },
  "ConnectionAuthorizationvLEICredential": {
    "grantee": "LegalEntityRolevLEICredential",
    "grantor": "LegalEntityRolevLEICredential"
  }
}
```

This defines the complete dependency graph, ensuring schemas are processed in the correct order.

### Using `vital generate` Command

The `vital generate` command processes all schema files in a directory, generating SAIDs and linking schemas together based on the schema-map.json dependencies.

**Command Syntax:**
```bash
vital generate --dir <path-to-schema-directory>
```

**Example:**
```bash
vital generate --dir ./schema
```

**What it does:**

1. **Phase 1: Load**
   - Loads `schema-map.json` from the specified directory
   - Loads all `.json` files (except schema-map.json)
   - Extracts `credentialType` from each schema
   - Reports number of schemas found

2. **Phase 2: Determine Processing Order**
   - Uses topological sort (Kahn's algorithm) to order schemas
   - Ensures dependencies are processed before dependents
   - Detects circular dependencies and fails if found
   - Displays processing order: `A -> B -> C`

3. **Phase 3: Update Edge Constraints**
   - For each schema (in dependency order):
     - Looks up edge mappings in schema-map.json
     - Locates edge property definitions in the schema
     - Updates `properties.e.oneOf[1].properties.<edgeName>.properties.s.const` with the referenced schema's SAID
   - Reports number of edges updated per schema

4. **Phase 4: Generate SAIDs**
   - Generates SAIDs for nested blocks (attributes `a`, edges `e`, rules `r`)
   - Generates the top-level schema SAID and sets `$id`
   - Uses Blake3-256 hashing algorithm
   - Reports generated SAID for each schema

5. **Phase 5: Save**
   - Writes updated schemas back to their original files
   - Preserves formatting with 2-space indentation
   - Reports success for each saved file

**Example Output:**
```
Processing schemas in: ./schema
Loaded 5 schemas
Processing order: QualificationAgentvLEICredential -> LegalEntitySubdivisionvLEICredential -> LERAuthorizationvLEICredential -> LegalEntityRolevLEICredential -> ConnectionAuthorizationvLEICredential

Processing: QualificationAgentvLEICredential
  Updated 0 edge constraint(s)
  Generated SAID: EOQD1-1y-l3FawXRnc...
  Saved to: QualificationAgentvLEICredential.json

Processing: LegalEntitySubdivisionvLEICredential
  Updated 0 edge constraint(s)
  Generated SAID: EOvrvccCry9lWXMqdl...
  Saved to: LegalEntitySubdivisionvLEICredential.json

Processing: LERAuthorizationvLEICredential
  Updated 1 edge constraint(s)
  Generated SAID: EIM8yGRXvvsXyUnljt...
  Saved to: LERAuthorizationvLEICredential.json

Processing: LegalEntityRolevLEICredential
  Updated 1 edge constraint(s)
  Generated SAID: EC2pLemg70rwCwmTdN...
  Saved to: LegalEntityRolevLEICredential.json

Processing: ConnectionAuthorizationvLEICredential
  Updated 2 edge constraint(s)
  Generated SAID: EGDtuI5vnaqd9JEZW2...
  Saved to: ConnectionAuthorizationvLEICredential.json

Successfully processed 5 schemas
```

**When to run:**

- After creating new schema files
- After modifying schema structures
- After changing edge relationships in schema-map.json
- Before committing schema changes to version control
- When SAIDs need to be regenerated (they will change if schema content changes)

**Common Issues:**

- **"Circular dependency detected"** - Your schema-map.json creates a dependency loop. Review edge relationships.
- **"Warning: Edge property 'X' not found"** - schema-map.json references an edge that doesn't exist in the schema.
- **"Warning: Referenced type 'X' not found"** - schema-map.json references a credential type that doesn't have a corresponding .json file.
- **"SAID not yet generated for X"** - Internal error indicating incorrect processing order (should not happen with proper topological sort).

## References

- ACDC Specification: [IETF ACDC Draft](https://trustoverip.github.io/tswg-acdc-specification/)
- KERI Specification: [IETF KERI Draft](https://weboftrust.github.io/ietf-keri/draft-ssmith-keri.html)
- vLEI Ecosystem: [GLEIF vLEI](https://www.gleif.org/en/lei-solutions/gleifs-digital-strategy-for-the-lei/introducing-the-verifiable-lei-vlei)
- JSON Schema: [json-schema.org](https://json-schema.org/)
- IPEX Protocol: [IETF IPEX](https://github.com/WebOfTrust/IETF-IPEX)
