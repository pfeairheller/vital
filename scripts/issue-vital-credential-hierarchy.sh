#!/bin/bash

# To run this script you need to run the following command in a separate terminals:
#   > kli witness demo


# Schema SAIDs - from ./schema and ./schema/GLEIF
QVI_SCHEMA_SAID="EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao"
LE_SCHEMA_SAID="ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
LE_SUBUNIT_SCHEMA_SAID="EP1jGIb7KXotuUZJf1NSu5wQ089epFfv93cpZECj-YBs"
LESR_AUTH_SCHEMA_SAID="ECoqb1jxC9f9zwh664stMAy6gpnNduvP_3SCQlLvkPAR"
LESR_SCHEMA_SAID="EHfJ563sbivepFRzk506fJenWIeVG2uXdAes8iJhHJan"

kli init --name "Registrar" --salt 0ACDEyMzQ1Njc4OWxtbmregi --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name "Registrar" --alias "Registrar" --file ${VITAL_SCRIPT_DIR}/data/registrar.json
REGISTRAR_AID=$(kli aid --name "Registrar" --alias "Registrar")
kli ends add --name "Registrar" --alias "Registrar" --role controller --eid "${REGISTRAR_AID}"
kli location add --name "Registrar" --alias "Registrar" --url "https://healthkeri-oobi.sfo3.digitaloceanspaces.com/" --eid "${REGISTRAR_AID}"

# EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R
kli init --name "GLEIF External" --salt 0ACDEyMzQ1Njc4OWxtbm9GhI --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name "GLEIF External" --alias "GLEIF External" --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
EXTERNAL_AID=$(kli aid --name "GLEIF External" --alias "GLEIF External")
kli ends add --name "GLEIF External" --alias "GLEIF External" --role registrar --eid "${REGISTRAR_AID}"

# EK4IkBaWvVlkfiscv4w_cOEmGcfnbbumi_Q5fMh_HYO1
kli init --name QVI --salt 0ACDEyMzQ1Njc4OWxtbm9aBc --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name QVI --alias QVI --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
QVI_AID=$(kli aid --name QVI --alias QVI)
kli ends add --name "QVI" --alias "QVI" --role registrar --eid "${REGISTRAR_AID}"

# "${LEGAL_ENTITY_AID}"
kli init --name "ACME Health" --salt 0ACDEyMzQ1Njc4OWxtbm9AbC --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name "ACME Health" --alias "ACME Health" --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
LEGAL_ENTITY_AID=$(kli aid --name "ACME Health" --alias "ACME Health")
kli ends add --name "ACME Health" --alias "ACME Health" --role registrar --eid "${REGISTRAR_AID}"

# "${SUBUNIT_AID}"
kli init --name "ACME Preferred PPO" --salt 0ACDEyMzQ1Njc4OWxtbm9dEf --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
SUBUNIT_AID=$(kli aid --name "ACME Preferred PPO" --alias "ACME Preferred PPO")
kli ends add --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --role registrar --eid "${REGISTRAR_AID}"

echo 'resolving "Registrar"'
kli oobi resolve --name "GLEIF External" --oobi-alias "Registrar" --oobi https://healthkeri-oobi.sfo3.digitaloceanspaces.com/oobi/BFJeHX9lPTpviv-un75-O6Bl0ahSkUjRMLh0lpTiUmIC
kli oobi resolve --name QVI --oobi-alias "Registrar" --oobi https://healthkeri-oobi.sfo3.digitaloceanspaces.com/oobi/BFJeHX9lPTpviv-un75-O6Bl0ahSkUjRMLh0lpTiUmIC
kli oobi resolve --name "ACME Health" --oobi-alias "Registrar" --oobi https://healthkeri-oobi.sfo3.digitaloceanspaces.com/oobi/BFJeHX9lPTpviv-un75-O6Bl0ahSkUjRMLh0lpTiUmIC
kli oobi resolve --name "ACME Preferred PPO" --oobi-alias "Registrar" --oobi https://healthkeri-oobi.sfo3.digitaloceanspaces.com/oobi/BFJeHX9lPTpviv-un75-O6Bl0ahSkUjRMLh0lpTiUmIC
echo 'resolving GLEIF External'
kli oobi resolve --name QVI --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/registrar
kli oobi resolve --name "ACME Health" --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/registrar
kli oobi resolve --name "ACME Preferred PPO" --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/registrar
echo 'resolving QVI'
kli oobi resolve --name "GLEIF External" --oobi-alias QVI --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/registrar
kli oobi resolve --name "ACME Health" --oobi-alias QVI --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/registrar
kli oobi resolve --name "ACME Preferred PPO" --oobi-alias QVI --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/registrar
echo 'resolving "ACME Health"'
kli oobi resolve --name "GLEIF External" --oobi-alias "ACME Health" --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/registrar
kli oobi resolve --name QVI --oobi-alias "ACME Health" --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/registrar
kli oobi resolve --name "ACME Preferred PPO" --oobi-alias "ACME Health" --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/registrar
echo 'resolving "ACME Preferred PPO"'
kli oobi resolve --name "GLEIF External" --oobi-alias "ACME Preferred PPO" --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/registrar
kli oobi resolve --name QVI --oobi-alias "ACME Preferred PPO" --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/registrar
kli oobi resolve --name "ACME Health" --oobi-alias "ACME Preferred PPO" --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/registrar

kli vc registry incept --name "GLEIF External" --alias "GLEIF External" --registry-name vLEI-external
kli vc registry incept --name QVI --alias QVI --registry-name vLEI-QVI
kli vc registry incept --name QVI --alias QVI --registry-name EHfJ563sbivepFRzk506fJenWIeVG2uXdAes8iJhHJan
kli vc registry incept --name "ACME Health" --alias "ACME Health" --registry-name vLEI-legal-entity
kli vc registry incept --name "ACME Preferred PPO"  --alias "ACME Preferred PPO" --registry-name vLEI-subunit

echo -e "\nIssue QVI credential vLEI from GLEIF External to QVI"
kli vc create --name "GLEIF External" --alias "GLEIF External" --registry-name vLEI-external --schema ${QVI_SCHEMA_SAID} --recipient "${QVI_AID}" --data @${VITAL_SCRIPT_DIR}/data/qvi-data.json
QVI_SAID=$(kli vc list --name "GLEIF External" --alias "GLEIF External" --issued --said --schema ${QVI_SCHEMA_SAID})
kli ipex grant --name "GLEIF External" --alias "GLEIF External" --said "${QVI_SAID}" --recipient "${QVI_AID}"
GRANT=$(kli ipex list --name QVI --alias QVI --poll --said)
kli ipex admit --name QVI --alias QVI --said "${GRANT}"
kli vc export --name QVI --alias QVI --said "${QVI_SAID}" --full> /tmp/qvi.cesr
kli vc list --name QVI --alias QVI

echo -e "\nIssue LE credential from QVI to Legal Entity - have to create the edges first"
QVI_SAID=`kli vc list --name QVI --alias QVI --said --schema ${QVI_SCHEMA_SAID}`
echo \"$QVI_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/legal-entity-edges-filter.jq  > /tmp/legal-entity-edges.json
kli saidify --file /tmp/legal-entity-edges.json
kli vc create --name QVI --alias QVI --registry-name vLEI-QVI --schema "${LE_SCHEMA_SAID}" --recipient "${LEGAL_ENTITY_AID}" --data @${VITAL_SCRIPT_DIR}/data/legal-entity-data.json --edges @/tmp/legal-entity-edges.json --rules @${VITAL_SCRIPT_DIR}/data/rules.json
LE_SAID=$(kli vc list --name QVI --alias QVI --issued --said --schema "${LE_SCHEMA_SAID}")
kli ipex grant --name QVI --alias QVI --said "${LE_SAID}" --recipient "${LEGAL_ENTITY_AID}"
GRANT=$(kli ipex list --name "ACME Health" --alias "ACME Health" --poll --said)
kli ipex admit --name "ACME Health" --alias "ACME Health" --said "${GRANT}"
kli vc export --name "ACME Health" --alias "ACME Health" --said "${LE_SAID}" --full> /tmp/le.cesr
kli vc list --name "ACME Health" --alias "ACME Health"

echo -e "\nIssue LegalEntitySubunitvLEICredential from Legal Entity to "ACME Preferred PPO""
kli vc import --name "ACME Preferred PPO" --file /tmp/qvi.cesr --said "${QVI_SAID}"
LE_SAID=`kli vc list --name "ACME Health" --alias "ACME Health" --said --schema ${LE_SCHEMA_SAID}`
echo \"$LE_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/subunit-edges-filter.jq > /tmp/subunit-edges.json
kli saidify --file /tmp/subunit-edges.json
kli vc create --name "ACME Health" --alias "ACME Health" --registry-name vLEI-legal-entity \
  --schema ${LE_SUBUNIT_SCHEMA_SAID} \
  --recipient "${SUBUNIT_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/subunit-data.json \
  --edges @/tmp/subunit-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
SUBUNIT_SAID=$(kli vc list --name "ACME Health" --alias "ACME Health" --issued --said --schema ${LE_SUBUNIT_SCHEMA_SAID})
kli ipex grant --name "ACME Health" --alias "ACME Health" --said "${SUBUNIT_SAID}" --recipient "${SUBUNIT_AID}"
GRANT=$(kli ipex list --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --poll --said)
kli ipex admit --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --said "${GRANT}"
kli vc export --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --said "${SUBUNIT_SAID}" --full> /tmp/subunit.cesr
kli vc list --name "ACME Preferred PPO" --alias "ACME Preferred PPO"

echo -e "\nIssue LESRAuthorizationvLEICredential from Legal Entity to QVI"
SUBUNIT_SAID=`kli vc list --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --said --schema ${LE_SUBUNIT_SCHEMA_SAID}`
kli vc import --name QVI --file /tmp/subunit.cesr --said "${SUBUNIT_SAID}"
echo \"$SUBUNIT_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/lesr-auth-edges-filter.jq > /tmp/lesr-auth-edges.json
kli saidify --file /tmp/lesr-auth-edges.json
kli vc create --name "ACME Health" --alias "ACME Health" --registry-name vLEI-legal-entity \
  --schema ${LESR_AUTH_SCHEMA_SAID} \
  --recipient "${QVI_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/lesr-auth-data.json \
  --edges @/tmp/lesr-auth-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
LESR_AUTH_SAID=$(kli vc list --name "ACME Health" --alias "ACME Health" --issued --said --schema ${LESR_AUTH_SCHEMA_SAID})
kli ipex grant --name "ACME Health" --alias "ACME Health" --said "${LESR_AUTH_SAID}" --recipient "${QVI_AID}"
GRANT=$(kli ipex list --name QVI --alias QVI --poll --said | tail -1)
kli ipex admit --name QVI --alias QVI --said "${GRANT}"
kli vc export --name QVI --alias QVI --said "${LESR_AUTH_SAID}" --full> /tmp/lesr_auth.cesr
kli vc list --name QVI --alias QVI

echo -e "\nIssue LegalEntitySubunitRolevLEICredential from QVI to Subunit"
AUTH_SAID=`kli vc list --name QVI --alias QVI --said --schema ${LESR_AUTH_SCHEMA_SAID}`
echo \"$AUTH_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/lesr-edges-filter.jq > /tmp/lesr-edges.json
kli vc import --name "ACME Preferred PPO" --file /tmp/lesr_auth.cesr --said "${LESR_AUTH_SAID}"
kli saidify --file /tmp/lesr-edges.json
kli vc create --name QVI --alias QVI --registry-name vLEI-QVI \
  --schema ${LESR_SCHEMA_SAID} \
  --recipient "${SUBUNIT_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/lesr-data.json \
  --edges @/tmp/lesr-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
LESR_SAID=$(kli vc list --name QVI --alias QVI --issued --said --schema ${LESR_SCHEMA_SAID})
kli ipex grant --name QVI --alias QVI --said "${LESR_SAID}" --recipient "${SUBUNIT_AID}"
GRANT=$(kli ipex list --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --poll --said | tail -1)
kli ipex admit --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --said "${GRANT}"
kli vc export --name "ACME Preferred PPO" --alias "ACME Preferred PPO" --said "${LESR_SAID}" --full> /tmp/lesr.cesr
kli vc list --name "ACME Preferred PPO" --alias "ACME Preferred PPO"

source ${VITAL_SCRIPT_DIR}/upload_credentials.sh