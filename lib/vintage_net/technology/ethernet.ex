defmodule VintageNet.Technology.Ethernet do
  @behaviour VintageNet.Technology

  alias VintageNet.Interface.RawConfig

  def to_raw_config(ifname, %{type: __MODULE__} = config, opts) do
    ifup = Keyword.fetch!(opts, :bin_ifup)
    ifdown = Keyword.fetch!(opts, :bin_ifdown)

    hostname = config[:hostname] || get_hostname()

    %RawConfig{
      ifname: ifname,
      type: __MODULE__,
      source_config: config,
      files: [
        {"/tmp/network_interfaces.#{ifname}",
         "iface #{ifname} inet dhcp" <> dhcp_options(hostname)}
      ],
      # ifup hangs forever until Ethernet is plugged in
      up_cmd_millis: 60_000,
      up_cmds: [{:run, ifup, ["-i", "/tmp/network_interfaces.#{ifname}", ifname]}],
      down_cmd_millis: 5_000,
      down_cmds: [{:run, ifdown, ["-i", "/tmp/network_interfaces.#{ifname}", ifname]}]
    }
  end

  defp dhcp_options(hostname) do
    """

      script #{udhcpc_handler_path()}
      hostname #{hostname}
    """
  end

  def handle_ioctl(_ifname, _ioctl) do
    {:error, :unsupported}
  end

  defp udhcpc_handler_path() do
    Application.app_dir(:vintage_net, ["priv", "udhcpc_handler"])
  end

  defp get_hostname do
    {:ok, hostname} = :inet.gethostname()
    to_string(hostname)
  end
end
