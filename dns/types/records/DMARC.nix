#
# SPDX-FileCopyrightText: 2020 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 or MIT
#

# This is a “fake” record type, not actually part of DNS.
# It gets compiled down to a TXT record.

# RFC 7208

{ lib }:

let
  inherit (lib) dns mkOption types;

in

rec {
  rtype = "TXT";
  options = {
    adkim = mkOption {
      type = types.enum ["relaxed" "strict"];
      default = "relaxed";
      example = "strict";
      description = "DKIM Identifier Alignment mode";
      apply = builtins.substring 0 1;
    };
    aspf = mkOption {
      type = types.enum ["relaxed" "strict"];
      default = "relaxed";
      example = "strict";
      description = "SPF Identifier Alignment mode";
      apply = builtins.substring 0 1;
    };
    fo = mkOption {
      type = types.listOf (types.enum ["0" "1" "d" "s"]);
      default = ["0"];
      example = ["0" "1" "s"];
      description = "Failure reporting options";
      apply = lib.concatStringsSep ":";
    };
    p = mkOption {
      type = types.enum ["none" "quarantine" "reject"];
      example = "quarantine";
      description = "Requested Mail Receiver policy";
    };
    pct = mkOption {
      type = types.ints.between 0 100;
      default = 100;
      example = 30;
      description = "Percentage of messages to which the DMARC policy is to be applied";
      apply = builtins.toString;
    };
    rf = mkOption {
      type = types.listOf (types.enum ["afrf"]);
      default = ["afrf"];
      example = ["afrf"];
      description = "Format to be used for message-specific failure reports";
      apply = lib.concatStringsSep ":";
    };
    ri = mkOption {
      type = types.ints.unsigned;  # FIXME: u32
      default = 86400;
      example = 12345;
      description = "Interval requested between aggregate reports";
      apply = builtins.toString;
    };
    rua = mkOption {
      type = types.oneOf [types.str (types.listOf types.str)];
      default = [];
      example = "mailto:dmarc+rua@example.com";
      description = "Addresses to which aggregate feedback is to be sent";
      apply = val:  # FIXME: need to encode commas in URIs
        if builtins.isList val
        then lib.concatStringsSep "," val
        else val;
    };
    ruf = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["mailto:dmarc+ruf@example.com" "mailto:another+ruf@example.com"];
      description = "Addresses to which message-specific failure information is to be reported";
      apply = val:  # FIXME: need to encode commas in URIs
        if builtins.isList val
        then lib.concatStringsSep "," val
        else val;
    };
    sp = mkOption {
      type = types.nullOr (types.enum ["none" "quarantine" "reject"]);
      default = null;
      example = "quarantine";
      description = "Requested Mail Receiver policy for all subdomains";
    };
  };
  dataToString = data:
    let
      # The specification could be more clear on this, but `v` and `p` MUST
      # be the first two tags in the record.
      items = ["v=DMARC1; p=${data.p}"] ++ lib.pipe data [
        (builtins.intersectAttrs options)  # remove garbage list `_module`
        (lib.filterAttrs (k: v: v != null && v != "" && k != "p"))
        (lib.mapAttrsToList (k: v: "${k}=${v}"))
      ];
      result = lib.concatStringsSep "; " items + ";";
    in dns.util.writeCharacterString result;
  nameFixup = name: _self:
    "_dmarc${lib.optionalString (name != "@") ".${name}"}";
}
