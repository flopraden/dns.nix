#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

# RFC 6672

{ lib }:

let
  inherit (lib) dns mkOption;

in

{
  rtype = "DNAME";
  options = {
    dname = mkOption {
      type = dns.types.domain-name;
      example = "www.test.com";
      description = "A <domain-name> which provides redirection from a part of the DNS name tree to another part of the DNS name tree";
    };
  };
  dataToString = {dname, ...}: "${dname}";
  fromString = dname: { inherit dname; };
}
