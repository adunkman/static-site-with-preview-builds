/**
 * This Lambda function handles incoming requests for pull request preview
 * environments and rewrites the origin request to the correct folder in S3.
 *
 * @param {Lambda@EdgeViewerRequestEvent} event
 */
exports.handler = async (event) => {
  const { request } = event.Records[0].cf;
  const { uri, headers } = request;
  const host = headers.host[0].value;
  const parsedPreviewEnvironment = parsePreviewEnvironment(host);

  if (parsedPreviewEnvironment) {
    request.uri = `/${parsedPreviewEnvironment}${request.uri}`;
  }

  console.log(parsedPreviewEnvironment
    ? `Rewrote request from '${uri}' to '${request.uri}' based on parsed subdomain preview environment of '${parsedPreviewEnvironment}'`
    : `Did not rewrite request for '${uri}'; could not find a preview environment name in host '${host}'`
  );

  return request;
};

/**
 * Parses the lowest subdomain out of a host header, looking for a pull request
 * number prefixed by 'pr'. If found, returns the number with prefix.
 *
 * @param {string} host
 */
const parsePreviewEnvironment = (host) => {
  const subdomain = host.split('.')[0];

  if (/^pr\d+$/.test(subdomain)) {
    return subdomain;
  }
};
