require '../../seqdiag.rb'

wlib = Model.new('wlib', 'Widget library (dlg_key_event)')
mid = Model.new('mid', 'midnight_callback')
cmdln = Model.new('cmdln', 'Command line')
pnl = Model.new('p', 'Panel')

lookup_style = "color: #000000; background-color: #ffcccc"

start_with(wlib) {

  mid.MSG_KEY(:no_params => true) {
    note "handle main_x_map"
    note "handle ENTER if cmdline non-empty"
    note "handle +, -, * if cmdline empty"
  }

  line ""

  #buttonbar.MSG_HOTKEY() {}
  #note "when menu is active:"
  #menu.MSG_KEY() {}

  note "If key not handled: "

  pnl.MSG_KEY(:no_params => true) {
    line "command = LOOKUP (panel_map, key)", :css => lookup_style
    pnl.panel_execute_cmd("command") {
      line ""
    }
    line ""
    line "/* or handle quick-search */"
  }

  line ""
  note "If panel hasn't handled the key:  "
  mid.MSG_UNHANDLED_KEY(:no_params => true) {
    line "command = LOOKUP (main_map, key)", :css => lookup_style
    mid.midnight_execute_cmd("command") {
      line ""
    }
    line ""
    note "if still not handled: "
    cmdln.send_message("MSG_KEY")
  }
}
