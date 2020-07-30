# -------------------------------------------------------------------------------------------------
# Public root zones
# -------------------------------------------------------------------------------------------------
locals {
  # Transforms from:
  # ----------------
  # var.public_root_zones = [
  #   {
  #     name = "example1.tld",
  #     delegation_set = "deleg-name",
  #   },
  #   {
  #     name = "example2.tld",
  #     delegation_set = null,
  #   },
  # ]
  #
  # Transforms into:
  # ----------------
  # local.public_root_zones = {
  #   "example1.tld" {
  #     "name" = "example1.tld"
  #     "deleg_id" = "N0XXXXXXXXXXXXX"
  #     "deleg_name" = "deleg-name"
  #   },
  #   "example2.tld" {
  #     "name" = "example2.tld"
  #     "deleg_id" = null
  #     "deleg_name" = ""
  #   },
  # }
  public_root_zones = {
    for zone in var.public_root_zones : zone.name => {
      name       = zone.name
      deleg_id   = zone.delegation_set != null ? aws_route53_delegation_set.delegation_sets[zone.delegation_set]["id"] : null
      deleg_name = zone.delegation_set != null ? zone.delegation_set : ""
    }
  }
}


# -------------------------------------------------------------------------------------------------
# Public secondary zones
# -------------------------------------------------------------------------------------------------
locals {
  # Transforms from:
  # ----------------
  # var.public_secondary_zones = [
  #   {
  #     name = "intranet.example.tld",
  #     root = "example.tld",
  #     nameservers = [],
  #     ns_ttl = 30,
  #     delegation_set = "deleg-name",
  #   },
  #   {
  #     name = "private.example.tld",
  #     root = "example.tld",
  #     nameservers = ["1,1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
  #     delegation_set = null,
  #     ns_ttl = 30,
  #   },
  # ]
  #
  # Transforms into:
  # ----------------
  # local.public_secondary_zones = {
  #   "intranet.example1.tld" {
  #     "name" = "intranet.example.tld"
  #     "parent" = "example.tld",
  #     "deleg_id" = "N0XXXXXXXXXXXXX"
  #     "deleg_name" = "deleg-name"
  #   },
  #   "private.example1.tld" {
  #     "name" = "private.example.tld"
  #     "parent" = "example.tld",
  #     "deleg_id" = null
  #     "deleg_name" = ""
  #   },
  # }
  # local.public_secondary_default_ns_records = {
  #   "intranet.example1.tld" {
  #     "name" = "intranet.example.tld"
  #     "parent" = "example.tld",
  #   },
  # }
  # local.public_secondary_custom_ns_records = {
  #   "private.example1.tld" {
  #     "name" = "private.example.tld"
  #     "parent" = "example.tld",
  #     "nameservers" = ["1,1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"],
  #     "ns_ttl" = 30,
  #   },
  # }
  public_secondary_zones = {
    for zone in var.public_secondary_zones : zone.name => {
      name       = zone.name
      parent     = zone.parent
      deleg_id   = zone.delegation_set != null ? aws_route53_delegation_set.delegation_sets[zone.delegation_set]["id"] : null
      deleg_name = zone.delegation_set != null ? zone.delegation_set : ""
    }
  }
  public_secondary_ns_records = {
    for zone in var.public_secondary_zones : zone.name => {
      name       = zone.name
      parent     = zone.parent
      ns_ttl     = zone.ns_ttl
      ns_servers = length(zone.ns_servers) == 0 ? aws_route53_zone.public_secondary_zones[zone.name]["name_servers"] : zone.ns_servers
    }
  }
}
