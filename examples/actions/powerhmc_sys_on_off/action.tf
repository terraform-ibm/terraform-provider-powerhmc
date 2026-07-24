# Power a whole managed system (CEC) on or off. Actions run at lifecycle
# events via the `action_trigger` lifecycle block on a resource.

# Power on a managed system.
action "powerhmc_sys_on_off" "power_on" {
  config {
    name      = "Server-9009-22A-SN123456"
    operation = "on" # "on" | "off" | "onstandby" | "onhwdisc" | "onstartpolicy"
    timeout   = 15   # minutes, 10-60
  }
}

# Immediate power off with restart. `restart` requires `immed = true`, and
# both `immed` and `restart` only apply to the "off" operation.
action "powerhmc_sys_on_off" "power_cycle" {
  config {
    name      = "Server-9009-22A-SN123456"
    operation = "off"
    immed     = true
    restart   = true
    timeout   = 30
  }
}
