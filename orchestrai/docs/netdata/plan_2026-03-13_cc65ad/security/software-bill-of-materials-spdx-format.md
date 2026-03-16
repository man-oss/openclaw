---

## 1. SPDX Document Creation Information

```
SPDXVersion: SPDX-2.3
DataLicense: CC0-1.0

##------------------------------
## Document Information
##------------------------------

DocumentNamespace: https://netdata.io/spdx/netdata-v2.9.0-153-nightly
DocumentName: netdata-agent-sbom

##------------------------------
## Creation Information
##------------------------------

Creator: Tool: spdx-sbom-generator
Creator: Organization: Netdata Inc.
Created: 2025-01-01T00:00:00Z
CreatorComment: Generated from src/go/go.mod (go module: github.com/netdata/netdata/go/plugins, go toolchain: go1.25.7). C/system library dependencies listed separately. This SBOM covers the netdata-agent at version v2.9.0-153-nightly.
```

---

## 2. Primary Package — Netdata Agent

```
##------------------------------
## Package: netdata
##------------------------------

PackageName: netdata
SPDXID: SPDXRef-DOCUMENT
PackageVersion: v2.9.0-153-nightly
PackageDownloadLocation: https://github.com/netdata/netdata/archive/refs/tags/v2.9.0.tar.gz
FilesAnalyzed: true
PackageHomePage: https://www.netdata.cloud
PackageLicenseConcluded: GPL-3.0-or-later
PackageLicenseDeclared: GPL-3.0-or-later
PackageCopyrightText: Copyright Netdata Inc.
PackageComment: Primary package. Go plugin module path: github.com/netdata/netdata/go/plugins. C core under src/. Python collectors under src/collectors/.
```

> **License Note:** Source file headers in `src/` carry `GPL-3.0-or-later`. The Go sub-module at `src/go/` is built as a plugin binary and compiled into the agent. Plugins that link external drivers (IBM DB2 via `github.com/ibmdb/go_ibm_db`, IBM MQ via `github.com/ibm-messaging/mq-golang`) require CGO and their respective proprietary runtime libraries.

---

## 3. Go Module Dependencies (SPDX Packages)

Go module path: `github.com/netdata/netdata/go/plugins`
Go toolchain minimum: `go 1.25.7`
Source: `src/go/go.mod`

### 3.1 Direct Dependencies

| SPDXID | PackageName | Version | PackageLicenseConcluded | Download Location |
|--------|-------------|---------|------------------------|-------------------|
| SPDXRef-go-sqlmock | github.com/DATA-DOG/go-sqlmock | v1.5.2 | Apache-2.0 | https://pkg.go.dev/github.com/DATA-DOG/go-sqlmock@v1.5.2 |
| SPDXRef-sprig | github.com/Masterminds/sprig/v3 | v3.3.0 | MIT | https://pkg.go.dev/github.com/Masterminds/sprig/v3@v3.3.0 |
| SPDXRef-ltsv | github.com/Wing924/ltsv | v0.4.0 | MIT | https://pkg.go.dev/github.com/Wing924/ltsv@v0.4.0 |
| SPDXRef-dateparse | github.com/araddon/dateparse | v0.0.0-20210429162001-6b43995a97de | MIT | https://pkg.go.dev/github.com/araddon/dateparse@v0.0.0-20210429162001-6b43995a97de |
| SPDXRef-hyperloglog | github.com/axiomhq/hyperloglog | v0.2.6 | MIT | https://pkg.go.dev/github.com/axiomhq/hyperloglog@v0.2.6 |
| SPDXRef-semver-blang | github.com/blang/semver/v4 | v4.0.0 | MIT | https://pkg.go.dev/github.com/blang/semver/v4@v4.0.0 |
| SPDXRef-doublestar | github.com/bmatcuk/doublestar/v4 | v4.10.0 | MIT | https://pkg.go.dev/github.com/bmatcuk/doublestar/v4@v4.10.0 |
| SPDXRef-rfile | github.com/clbanning/rfile/v2 | v2.0.0-20231024120205-ac3fca974b0e | MIT | https://pkg.go.dev/github.com/clbanning/rfile/v2@v2.0.0-20231024120205-ac3fca974b0e |
| SPDXRef-cfssl | github.com/cloudflare/cfssl | v1.6.5 | BSD-2-Clause | https://pkg.go.dev/github.com/cloudflare/cfssl@v1.6.5 |
| SPDXRef-go-systemd | github.com/coreos/go-systemd/v22 | v22.7.0 | Apache-2.0 | https://pkg.go.dev/github.com/coreos/go-systemd/v22@v22.7.0 |
| SPDXRef-docker | github.com/docker/docker | v28.5.2+incompatible | Apache-2.0 | https://pkg.go.dev/github.com/docker/docker@v28.5.2+incompatible |
| SPDXRef-facebook-time | github.com/facebook/time | v0.0.0-20250211113239-e3e1421a0980 | Apache-2.0 | https://pkg.go.dev/github.com/facebook/time@v0.0.0-20250211113239-e3e1421a0980 |
| SPDXRef-fsnotify | github.com/fsnotify/fsnotify | v1.9.0 | BSD-3-Clause | https://pkg.go.dev/github.com/fsnotify/fsnotify@v1.9.0 |
| SPDXRef-go-ldap | github.com/go-ldap/ldap/v3 | v3.4.12 | MIT | https://pkg.go.dev/github.com/go-ldap/ldap/v3@v3.4.12 |
| SPDXRef-go-sql-driver | github.com/go-sql-driver/mysql | v1.9.3 | MPL-2.0 | https://pkg.go.dev/github.com/go-sql-driver/mysql@v1.9.3 |
| SPDXRef-godbus | github.com/godbus/dbus/v5 | v5.2.2 | BSD-2-Clause | https://pkg.go.dev/github.com/godbus/dbus/v5@v5.2.2 |
| SPDXRef-flock | github.com/gofrs/flock | v0.13.0 | BSD-3-Clause | https://pkg.go.dev/github.com/gofrs/flock@v0.13.0 |
| SPDXRef-hashstructure | github.com/gohugoio/hashstructure | v0.6.0 | MIT | https://pkg.go.dev/github.com/gohugoio/hashstructure@v0.6.0 |
| SPDXRef-golang-mock | github.com/golang/mock | v1.6.0 | Apache-2.0 | https://pkg.go.dev/github.com/golang/mock@v1.6.0 |
| SPDXRef-google-uuid | github.com/google/uuid | v1.6.0 | BSD-3-Clause | https://pkg.go.dev/github.com/google/uuid@v1.6.0 |
| SPDXRef-gorcon | github.com/gorcon/rcon | v1.4.0 | MIT | https://pkg.go.dev/github.com/gorcon/rcon@v1.4.0 |
| SPDXRef-gosnmp | github.com/gosnmp/gosnmp | v1.42.1 | BSD-2-Clause | https://pkg.go.dev/github.com/gosnmp/gosnmp@v1.42.1 |
| SPDXRef-go-ibm-db | github.com/ibmdb/go_ibm_db | v0.5.4 | Apache-2.0 | https://pkg.go.dev/github.com/ibmdb/go_ibm_db@v0.5.4 |
| SPDXRef-pgx | github.com/jackc/pgx/v5 | v5.8.0 | MIT | https://pkg.go.dev/github.com/jackc/pgx/v5@v5.8.0 |
| SPDXRef-go-flags | github.com/jessevdk/go-flags | v1.6.1 | BSD-3-Clause | https://pkg.go.dev/github.com/jessevdk/go-flags@v1.6.1 |
| SPDXRef-fcgi-client | github.com/kanocz/fcgi_client | v0.0.0-20210113082628-fff85c8adfb7 | MIT | https://pkg.go.dev/github.com/kanocz/fcgi_client@v0.0.0-20210113082628-fff85c8adfb7 |
| SPDXRef-whois | github.com/likexian/whois | v1.15.7 | Apache-2.0 | https://pkg.go.dev/github.com/likexian/whois@v1.15.7 |
| SPDXRef-whois-parser | github.com/likexian/whois-parser | v1.24.21 | Apache-2.0 | https://pkg.go.dev/github.com/likexian/whois-parser@v1.24.21 |
| SPDXRef-tint | github.com/lmittmann/tint | v1.1.3 | MIT | https://pkg.go.dev/github.com/lmittmann/tint@v1.1.3 |
| SPDXRef-go-isatty | github.com/mattn/go-isatty | v0.0.20 | MIT | https://pkg.go.dev/github.com/mattn/go-isatty@v0.0.20 |
| SPDXRef-go-xmlrpc | github.com/mattn/go-xmlrpc | v0.0.3 | MIT | https://pkg.go.dev/github.com/mattn/go-xmlrpc@v0.0.3 |
| SPDXRef-miekg-dns | github.com/miekg/dns | v1.1.72 | BSD-3-Clause | https://pkg.go.dev/github.com/miekg/dns@v1.1.72 |
| SPDXRef-go-homedir | github.com/mitchellh/go-homedir | v1.1.0 | MIT | https://pkg.go.dev/github.com/mitchellh/go-homedir@v1.1.0 |
| SPDXRef-pro-bing | github.com/prometheus-community/pro-bing | v0.8.0 | MIT | https://pkg.go.dev/github.com/prometheus-community/pro-bing@v0.8.0 |
| SPDXRef-prom-common | github.com/prometheus/common | v0.67.5 | Apache-2.0 | https://pkg.go.dev/github.com/prometheus/common@v0.67.5 |
| SPDXRef-prom-prometheus | github.com/prometheus/prometheus | v0.302.0 | Apache-2.0 | https://pkg.go.dev/github.com/prometheus/prometheus@v0.302.0 |
| SPDXRef-go-redis | github.com/redis/go-redis/v9 | v9.18.0 | BSD-2-Clause | https://pkg.go.dev/github.com/redis/go-redis/v9@v9.18.0 |
| SPDXRef-go-ora | github.com/sijms/go-ora/v2 | v2.9.0 | MIT | https://pkg.go.dev/github.com/sijms/go-ora/v2@v2.9.0 |
| SPDXRef-conc | github.com/sourcegraph/conc | v0.3.0 | MIT | https://pkg.go.dev/github.com/sourcegraph/conc@v0.3.0 |
| SPDXRef-testify | github.com/stretchr/testify | v1.11.1 | MIT | https://pkg.go.dev/github.com/stretchr/testify@v1.11.1 |
| SPDXRef-gjson | github.com/tidwall/gjson | v1.18.0 | MIT | https://pkg.go.dev/github.com/tidwall/gjson@v1.18.0 |
| SPDXRef-fastjson | github.com/valyala/fastjson | v1.6.10 | MIT | https://pkg.go.dev/github.com/valyala/fastjson@v1.6.10 |
| SPDXRef-govmomi | github.com/vmware/govmomi | v0.53.0 | Apache-2.0 | https://pkg.go.dev/github.com/vmware/govmomi@v0.53.0 |
| SPDXRef-mongo-driver | go.mongodb.org/mongo-driver | v1.17.9 | Apache-2.0 | https://pkg.go.dev/go.mongodb.org/mongo-driver@v1.17.9 |
| SPDXRef-otlp-proto | go.opentelemetry.io/proto/otlp | v1.9.0 | Apache-2.0 | https://pkg.go.dev/go.opentelemetry.io/proto/otlp@v1.9.0 |
| SPDXRef-automaxprocs | go.uber.org/automaxprocs | v1.6.0 | MIT | https://pkg.go.dev/go.uber.org/automaxprocs@v1.6.0 |
| SPDXRef-golang-net | golang.org/x/net | v0.52.0 | BSD-3-Clause | https://pkg.go.dev/golang.org/x/net@v0.52.0 |
| SPDXRef-golang-sync | golang.org/x/sync | v0.20.0 | BSD-3-Clause | https://pkg.go.dev/golang.org/x/sync@v0.20.0 |
| SPDXRef-golang-text | golang.org/x/text | v0.35.0 | BSD-3-Clause | https://pkg.go.dev/golang.org/x/text@v0.35.0 |
| SPDXRef-wgctrl | golang.zx2c4.com/wireguard/wgctrl | v0.0.0-20220504211119-3d4a969bb56b | MIT | https://pkg.go.dev/golang.zx2c4.com/wireguard/wgctrl@v0.0.0-20220504211119-3d4a969bb56b |
| SPDXRef-grpc | google.golang.org/grpc | v1.79.1 | Apache-2.0 | https://pkg.go.dev/google.golang.org/grpc@v1.79.1 |
| SPDXRef-ini | gopkg.in/ini.v1 | v1.67.1 | Apache-2.0 | https://pkg.go.dev/gopkg.in/ini.v1@v1.67.1 |
| SPDXRef-rethinkdb | gopkg.in/rethinkdb/rethinkdb-go.v6 | v6.2.2 | Apache-2.0 | https://pkg.go.dev/gopkg.in/rethinkdb/rethinkdb-go.v6@v6.2.2 |
| SPDXRef-yaml-v2 | gopkg.in/yaml.v2 | v2.4.0 | Apache-2.0 | https://pkg.go.dev/gopkg.in/yaml.v2@v2.4.0 |
| SPDXRef-k8s-api | k8s.io/api | v0.34.3 | Apache-2.0 | https://pkg.go.dev/k8s.io/api@v0.34.3 |
| SPDXRef-k8s-apimachinery | k8s.io/apimachinery | v0.34.3 | Apache-2.0 | https://pkg.go.dev/k8s.io/apimachinery@v0.34.3 |
| SPDXRef-k8s-client-go | k8s.io/client-go | v0.34.3 | Apache-2.0 | https://pkg.go.dev/k8s.io/client-go@v0.34.3 |
| SPDXRef-radius | layeh.com/radius | v0.0.0-20190322222518-890bc1058917 | MIT | https://pkg.go.dev/layeh.com/radius@v0.0.0-20190322222518-890bc1058917 |

### 3.2 Additional Direct Dependencies (Secondary Block)

| SPDXID | PackageName | Version | PackageLicenseConcluded | Download Location |
|--------|-------------|---------|------------------------|-------------------|
| SPDXRef-azure-azcore | github.com/Azure/azure-sdk-for-go/sdk/azcore | v1.21.0 | MIT | https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azcore@v1.21.0 |
| SPDXRef-azure-azidentity | github.com/Azure/azure-sdk-for-go/sdk/azidentity | v1.13.1 | MIT | https://pkg.go.dev/github.com/Azure/azure-sdk-for-go/sdk/azidentity@v1.13.1 |
| SPDXRef-odbc | github.com/alexbrainman/odbc | v0.0.0-20250601004241-49e6b2bc0cf0 | BSD-3-Clause | https://pkg.go.dev/github.com/alexbrainman/odbc@v0.0.0-20250601004241-49e6b2bc0cf0 |
| SPDXRef-xxhash | github.com/cespare/xxhash/v2 | v2.3.0 | MIT | https://pkg.go.dev/github.com/cespare/xxhash/v2@v2.3.0 |
| SPDXRef-docker-go-units | github.com/docker/go-units | v0.5.0 | Apache-2.0 | https://pkg.go.dev/github.com/docker/go-units@v0.5.0 |
| SPDXRef-ibm-mq | github.com/ibm-messaging/mq-golang/v5 | v5.7.1 | Apache-2.0 | https://pkg.go.dev/github.com/ibm-messaging/mq-golang/v5@v5.7.1 |
| SPDXRef-go-mssqldb | github.com/microsoft/go-mssqldb | v1.9.8 | BSD-3-Clause | https://pkg.go.dev/github.com/microsoft/go-mssqldb@v1.9.8 |
| SPDXRef-jsonschema | github.com/santhosh-tekuri/jsonschema/v6 | v6.0.2 | Apache-2.0 | https://pkg.go.dev/github.com/santhosh-tekuri/jsonschema/v6@v6.0.2 |
| SPDXRef-yaml-v3 | gopkg.in/yaml.v3 | v3.0.1 | MIT | https://pkg.go.dev/gopkg.in/yaml.v3@v3.0.1 |

### 3.3 Transitive (Indirect) Dependencies

| SPDXID | PackageName | Version | PackageLicenseConcluded |
|--------|-------------|---------|------------------------|
| SPDXRef-mergo | dario.cat/mergo | v1.0.1 | BSD-3-Clause |
| SPDXRef-edwards25519 | filippo.io/edwards25519 | v1.1.1 | BSD-3-Clause |
| SPDXRef-azure-internal | github.com/Azure/azure-sdk-for-go/sdk/internal | v1.11.2 | MIT |
| SPDXRef-azure-ansiterm | github.com/Azure/go-ansiterm | v0.0.0-20210617225240-d185dfc1b5a1 | MIT |
| SPDXRef-azure-ntlmssp | github.com/Azure/go-ntlmssp | v0.0.0-20221128193559-754e69321358 | MIT |
| SPDXRef-msal-go | github.com/AzureAD/microsoft-authentication-library-for-go | v1.6.0 | MIT |
| SPDXRef-goutils | github.com/Masterminds/goutils | v1.1.1 | Apache-2.0 |
| SPDXRef-semver-masterminds | github.com/Masterminds/semver/v3 | v3.3.0 | MIT |
| SPDXRef-go-winio | github.com/Microsoft/go-winio | v0.6.1 | MIT |
| SPDXRef-errdefs | github.com/containerd/errdefs | v1.0.0 | Apache-2.0 |
| SPDXRef-errdefs-pkg | github.com/containerd/errdefs/pkg | v0.3.0 | Apache-2.0 |
| SPDXRef-containerd-log | github.com/containerd/log | v0.1.0 | Apache-2.0 |
| SPDXRef-go-spew | github.com/davecgh/go-spew | v1.1.2-0.20180830191138-d8f796af33cc | ISC |
| SPDXRef-go-metro | github.com/dgryski/go-metro | v0.0.0-20250106013310-edb8663e5e33 | MIT |
| SPDXRef-go-rendezvous | github.com/dgryski/go-rendezvous | v0.0.0-20200823014737-9f7001d12a5f | MIT |
| SPDXRef-dist-reference | github.com/distribution/reference | v0.5.0 | Apache-2.0 |
| SPDXRef-regexp2 | github.com/dlclark/regexp2 | v1.11.4 | MIT |
| SPDXRef-docker-connections | github.com/docker/go-connections | v0.4.0 | Apache-2.0 |
| SPDXRef-go-restful | github.com/emicklei/go-restful/v3 | v3.12.2 | MIT |
| SPDXRef-httpsnoop | github.com/felixge/httpsnoop | v1.0.4 | MIT |
| SPDXRef-cbor | github.com/fxamacker/cbor/v2 | v2.9.0 | MIT |
| SPDXRef-asn1-ber | github.com/go-asn1-ber/asn1-ber | v1.5.8-0.20250403174932-29230038a667 | MIT |
| SPDXRef-go-logr | github.com/go-logr/logr | v1.4.3 | Apache-2.0 |
| SPDXRef-go-logr-stdr | github.com/go-logr/stdr | v1.2.2 | Apache-2.0 |
| SPDXRef-jsonpointer | github.com/go-openapi/jsonpointer | v0.21.0 | Apache-2.0 |
| SPDXRef-jsonreference | github.com/go-openapi/jsonreference | v0.21.0 | Apache-2.0 |
| SPDXRef-openapi-swag | github.com/go-openapi/swag | v0.23.0 | Apache-2.0 |
| SPDXRef-gogo-protobuf | github.com/gogo/protobuf | v1.3.2 | BSD-3-Clause |
| SPDXRef-golang-jwt | github.com/golang-jwt/jwt/v5 | v5.3.1 | MIT |
| SPDXRef-golang-sql-civil | github.com/golang-sql/civil | v0.0.0-20220223132316-b832511892a9 | Apache-2.0 |
| SPDXRef-golang-sql-exp | github.com/golang-sql/sqlexp | v0.1.0 | BSD-3-Clause |
| SPDXRef-golang-protobuf | github.com/golang/protobuf | v1.5.4 | BSD-3-Clause |
| SPDXRef-golang-snappy | github.com/golang/snappy | v0.0.4 | BSD-3-Clause |
| SPDXRef-ct-go | github.com/google/certificate-transparency-go | v1.1.7 | Apache-2.0 |
| SPDXRef-gnostic-models | github.com/google/gnostic-models | v0.7.0 | Apache-2.0 |
| SPDXRef-go-cmp | github.com/google/go-cmp | v0.7.0 | BSD-3-Clause |
| SPDXRef-grafana-regexp | github.com/grafana/regexp | v0.0.0-20240518133315-a468a5bfb3bc | BSD-3-Clause |
| SPDXRef-grpc-gateway | github.com/grpc-ecosystem/grpc-gateway/v2 | v2.27.2 | BSD-3-Clause |
| SPDXRef-go-hostpool | github.com/hailocab/go-hostpool | v0.0.0-20160125115350-e80d13ce29ed | MIT |
| SPDXRef-xstrings | github.com/huandu/xstrings | v1.5.0 | MIT |
| SPDXRef-go-recordio | github.com/ibmruntimes/go-recordio/v2 | v2.0.0-20240416213906-ae0ad556db70 | Apache-2.0 |
| SPDXRef-pgpassfile | github.com/jackc/pgpassfile | v1.0.0 | MIT |
| SPDXRef-pgservicefile | github.com/jackc/pgservicefile | v0.0.0-20240606120523-5a60cdf6a761 | MIT |
| SPDXRef-pgx-puddle | github.com/jackc/puddle/v2 | v2.2.2 | MIT |
| SPDXRef-intern | github.com/josharian/intern | v1.0.0 | MIT |
| SPDXRef-native | github.com/josharian/native | v1.1.0 | MIT |
| SPDXRef-json-iterator | github.com/json-iterator/go | v1.1.12 | MIT |
| SPDXRef-intmap | github.com/kamstrup/intmap | v0.5.2 | MPL-2.0 |
| SPDXRef-compress | github.com/klauspost/compress | v1.17.11 | Apache-2.0 AND MIT |
| SPDXRef-godebug | github.com/kylelemons/godebug | v1.1.0 | Apache-2.0 |
| SPDXRef-gokit | github.com/likexian/gokit | v0.25.16 | Apache-2.0 |
| SPDXRef-easyjson | github.com/mailru/easyjson | v0.9.0 | MIT |
| SPDXRef-genetlink | github.com/mdlayher/genetlink | v1.3.2 | MIT |
| SPDXRef-mdlayher-netlink | github.com/mdlayher/netlink | v1.7.2 | MIT |
| SPDXRef-mdlayher-socket | github.com/mdlayher/socket | v0.4.1 | MIT |
| SPDXRef-copystructure | github.com/mitchellh/copystructure | v1.2.0 | MIT |
| SPDXRef-reflectwalk | github.com/mitchellh/reflectwalk | v1.0.2 | MIT |
| SPDXRef-docker-image-spec | github.com/moby/docker-image-spec | v1.3.1 | Apache-2.0 |
| SPDXRef-atomicwriter | github.com/moby/sys/atomicwriter | v0.1.0 | Apache-2.0 |
| SPDXRef-sequential | github.com/moby/sys/sequential | v0.6.0 | Apache-2.0 |
| SPDXRef-modern-concurrent | github.com/modern-go/concurrent | v0.0.0-20180306012644-bacd9c7ef1dd | Apache-2.0 |
| SPDXRef-modern-reflect2 | github.com/modern-go/reflect2 | v1.0.3-0.20250322232337-35a7c28c31ee | Apache-2.0 |
| SPDXRef-stats | github.com/montanaflynn/stats | v0.7.1 | MIT |
| SPDXRef-goautoneg | github.com/munnerz/goautoneg | v0.0.0-20191010083416-a7dc8b61c822 | BSD-3-Clause |
| SPDXRef-go-digest | github.com/open