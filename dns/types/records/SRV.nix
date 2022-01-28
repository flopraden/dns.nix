#
# SPDX-FileCopyrightText: 2019 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

# RFC 2782

{ lib }:

let
  inherit (lib) dns mkOption types;

in

{
  rtype = "SRV";
  options = {
    service = mkOption {
      type = types.str;
      example = "foobar";
      description = "The symbolic name of the desired service. Do not add the underscore!";
    };
    proto = mkOption {
      type = types.str;
      example = "tcp";
      description = "The symbolic name of the desired protocol. Do not add the underscore!";
    };
    priority = mkOption {
      type = types.ints.u16;
      default = 0;
      example = 0;
      description = "The priority of this target host";
    };
    weight = mkOption {
      type = types.ints.u16;
      default = 100;
      example = 20;
      description = "The weight field specifies a relative weight for entries with the same priority. Larger weights SHOULD be given a proportionately higher probability of being selected";
    };
    port = mkOption {
      type = types.ints.u16;
      example = 9;
      description = "The port on this target host of this service";
    };
    target = mkOption {
      type = dns.types.domain-name;
      example = "";
      description = "The domain name of the target host";
    };
  };
  dataToString = data: with data;
    "${toString priority} ${toString weight} ${toString port} ${target}";
  nameFixup = name: self:
    "_${self.service}._${self.proto}${lib.optionalString (name != "@") ".${name}"}";
}
