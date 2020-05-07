# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# Overrides for unit tests:
#
# * udhcpc_handler: capture whatever happens with udhcpc
# * udhcpd_handler: capture whatever happens with udhcpd
# * interface_renamer: capture interfaces that get renamed
# * resolvconf: don't update the real resolv.conf
# * persistence_dir: use the current directory
# * bin_ip: just fail if anything calls ip rather that run it
# * power_managers: register a manager for test0 so that tests
#      that need to validate power management calls can use it.
#
# NOTE: the power_managers list here exercises common error cases
# that would cause exceptions, but instead print logs so that
# they don't take down an otherwise working system. This leads
# to extra prints when running locally.
config :vintage_net,
  udhcpc_handler: VintageNetTest.CapturingUdhcpcHandler,
  udhcpd_handler: VintageNetTest.CapturingUdhcpdHandler,
  interface_renamer: VintageNetTest.CapturingInterfaceRenamer,
  resolvconf: "/dev/null",
  persistence_dir: "./test_tmp/persistence",
  bin_ip: "false",
  power_managers: [
    {VintageNetTest.TestPowerManager, [ifname: "test0", watchdog_timeout: 50]},
    {VintageNetTest.BadPowerManager, [ifname: "bad_power0"]},
    {NonExistentPowerManager, [ifname: "test_does_not_exist_case"]}
  ]
