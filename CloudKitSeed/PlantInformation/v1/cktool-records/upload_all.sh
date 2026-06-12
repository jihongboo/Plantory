#!/usr/bin/env bash
set -euo pipefail

: "${CK_TEAM_ID:?Set CK_TEAM_ID}"
: "${CK_CONTAINER_ID:?Set CK_CONTAINER_ID, for example iCloud.com.example.Plantory}"
: "${CK_ENVIRONMENT:=development}"

CKTOOL="${CKTOOL:-xcrun cktool}"

echo "Creating monstera-deliciosa"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/monstera-deliciosa/fields.json

echo "Creating epipremnum-aureum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/epipremnum-aureum/fields.json

echo "Creating dracaena-trifasciata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/dracaena-trifasciata/fields.json

echo "Creating zamioculcas-zamiifolia"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/zamioculcas-zamiifolia/fields.json

echo "Creating spathiphyllum-wallisii"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/spathiphyllum-wallisii/fields.json

echo "Creating chlorophytum-comosum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/chlorophytum-comosum/fields.json

echo "Creating ficus-elastica"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/ficus-elastica/fields.json

echo "Creating ficus-lyrata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/ficus-lyrata/fields.json

echo "Creating pilea-peperomioides"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/pilea-peperomioides/fields.json

echo "Creating nephrolepis-exaltata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/nephrolepis-exaltata/fields.json

echo "Creating goeppertia-orbifolia"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/goeppertia-orbifolia/fields.json

echo "Creating philodendron-hederaceum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/philodendron-hederaceum/fields.json

echo "Creating aloe-barbadensis-miller"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/aloe-barbadensis-miller/fields.json

echo "Creating echeveria-elegans"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/echeveria-elegans/fields.json

echo "Creating crassula-ovata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/crassula-ovata/fields.json

echo "Creating mammillaria-elongata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/mammillaria-elongata/fields.json

echo "Creating phalaenopsis-amabilis"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/phalaenopsis-amabilis/fields.json

echo "Creating anthurium-andraeanum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/anthurium-andraeanum/fields.json

echo "Creating dracaena-sanderiana"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/dracaena-sanderiana/fields.json

echo "Creating hedera-helix"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/hedera-helix/fields.json

