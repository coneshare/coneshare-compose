echo "${_group}Fetching and updating Docker images ..."

echo "CONESHARE IMAGE: ${CONESHARE_IMAGE}"
docker pull ${CONESHARE_IMAGE}

if [[ -n "${CONESHARE_MCP_IMAGE}" ]]; then
  echo "CONESHARE MCP IMAGE: ${CONESHARE_MCP_IMAGE}"
  docker pull ${CONESHARE_MCP_IMAGE}
fi

echo "${_endgroup}"
