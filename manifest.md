apiVersion: krew.googlecontainertools.github.com/v1alpha2
kind: Plugin
metadata:
  # 'name' must match the filename of the manifest. The name defines how
  # the plugin is invoked, for example: `kubectl kubescan`
  name: kubescan
spec:
  # 'version' is a valid semantic version string (see semver.org)
  version: "v0.0.1"
  # 'homepage' usually links to the GitHub repository of the plugin
  homepage: https://github.com/Kubenew/kubectl-kubescan
  # 'shortDescription' explains what the plugin does in only a few words
  shortDescription: "Scan  pods and containers within for errors"
  description: |
  Scan  pods and containers within for errors under the namespaces on k8s clusters and displays the output with events, if found. 
  # 'platforms' specify installation methods for various platforms (os/arch)
  platforms:
  - selector:
      matchExpressions:
      - key: "os"
        operator: "In"
        values:
        - darwin
        - linux
    # 'uri' specifies .zip or .tar.gz archive URL of a plugin
    uri: https://github.com/Kubenew/kubectl-kubescan/archive/v0.0.3.zip
    # 'sha256' is the sha256sum of the url above
    sha256: d7079b79bf4e10e55ded435a2e862efe310e019b6c306a8ff04191238ef4b2b4
               7a1145abb6aeb6aab87c39f8ba98b17c32567282
    # 'files' lists which files should be extracted out from downloaded archive
    files:
    - from: "kubectl-restart-*/kubescan.sh"
      to: "./kubescan.sh"
    - from: "LICENSE"
      to: "."
    # 'bin' specifies the path to the the plugin executable among extracted files
    bin: kubescan.sh
