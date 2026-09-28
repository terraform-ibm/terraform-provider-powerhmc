# NetworkBridges are imported using the managed system name and the bridge PVID
# (the VLAN ID of the untagged virtual network), separated by a forward slash:
#   <system_name>/<bridge_pvid>
terraform import powerhmc_network_bridge.basic managed-system/145
