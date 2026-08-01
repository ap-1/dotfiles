locals {
  account_id = "1aeefdcd08c221dbe83c20913cc21c50"
  zone_id    = "b2fed9e9f7207a1067f88360e4011ed9"

  affogato_ipv4 = "167.233.47.157"
  affogato_ipv6 = "2a01:4f8:1c18:fd::1"

  subdomains = [
    "headscale",
    "pds",
  ]

  tunnel_subdomains = [
    "idp",
    "headplane",
    "vault",
    "git",
  ]
}
