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
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/monstera-deliciosa/fields.json \
  --asset-files monstera-deliciosa.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/monstera-deliciosa.png

echo "Creating epipremnum-aureum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/epipremnum-aureum/fields.json \
  --asset-files epipremnum-aureum.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/epipremnum-aureum.png

echo "Creating dracaena-trifasciata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/dracaena-trifasciata/fields.json \
  --asset-files dracaena-trifasciata.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/dracaena-trifasciata.png

echo "Creating zamioculcas-zamiifolia"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/zamioculcas-zamiifolia/fields.json \
  --asset-files zamioculcas-zamiifolia.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/zamioculcas-zamiifolia.png

echo "Creating spathiphyllum-wallisii"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/spathiphyllum-wallisii/fields.json \
  --asset-files spathiphyllum-wallisii.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/spathiphyllum-wallisii.png

echo "Creating chlorophytum-comosum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/chlorophytum-comosum/fields.json \
  --asset-files chlorophytum-comosum.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/chlorophytum-comosum.png

echo "Creating ficus-elastica"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/ficus-elastica/fields.json \
  --asset-files ficus-elastica.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/ficus-elastica.png

echo "Creating ficus-lyrata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/ficus-lyrata/fields.json \
  --asset-files ficus-lyrata.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/ficus-lyrata.png

echo "Creating pilea-peperomioides"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/pilea-peperomioides/fields.json \
  --asset-files pilea-peperomioides.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/pilea-peperomioides.png

echo "Creating nephrolepis-exaltata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/nephrolepis-exaltata/fields.json \
  --asset-files nephrolepis-exaltata.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/nephrolepis-exaltata.png

echo "Creating goeppertia-orbifolia"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/goeppertia-orbifolia/fields.json \
  --asset-files goeppertia-orbifolia.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/goeppertia-orbifolia.png

echo "Creating philodendron-hederaceum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/philodendron-hederaceum/fields.json \
  --asset-files philodendron-hederaceum.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/philodendron-hederaceum.png

echo "Creating aloe-barbadensis-miller"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/aloe-barbadensis-miller/fields.json \
  --asset-files aloe-barbadensis-miller.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/aloe-barbadensis-miller.png

echo "Creating echeveria-elegans"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/echeveria-elegans/fields.json \
  --asset-files echeveria-elegans.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/echeveria-elegans.png

echo "Creating crassula-ovata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/crassula-ovata/fields.json \
  --asset-files crassula-ovata.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/crassula-ovata.png

echo "Creating mammillaria-elongata"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/mammillaria-elongata/fields.json \
  --asset-files mammillaria-elongata.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/mammillaria-elongata.png

echo "Creating phalaenopsis-amabilis"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/phalaenopsis-amabilis/fields.json \
  --asset-files phalaenopsis-amabilis.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/phalaenopsis-amabilis.png

echo "Creating anthurium-andraeanum"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/anthurium-andraeanum/fields.json \
  --asset-files anthurium-andraeanum.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/anthurium-andraeanum.png

echo "Creating dracaena-sanderiana"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/dracaena-sanderiana/fields.json \
  --asset-files dracaena-sanderiana.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/dracaena-sanderiana.png

echo "Creating hedera-helix"
${CKTOOL} create-record \
  --team-id "${CK_TEAM_ID}" \
  --container-id "${CK_CONTAINER_ID}" \
  --environment "${CK_ENVIRONMENT}" \
  --database-type public \
  --record-type PlantInformation \
  --fields-file /Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/cktool-records/hedera-helix/fields.json \
  --asset-files hedera-helix.png=/Users/jihongbo/Developer/Plantory/CloudKitSeed/PlantInformation/v1/images/hedera-helix.png

