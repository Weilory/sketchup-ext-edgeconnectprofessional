require 'sketchup' unless Object.private_method_defined?(:file_loaded)

toolbar = UI::Toolbar.new "Edge Connect Professional"

directory = File.dirname(__FILE__)
path_mqp_edge_connect_module = File.expand_path("mq_edge_connect_module", directory)
Sketchup.require(path_mqp_edge_connect_module) unless defined?(MessizQinECPro)

ab_select = File.expand_path("edge_connect_images/mq_select.png", directory)
ab_show_mode = File.expand_path("edge_connect_images/mq_show_mode.png", directory)

ab_dis = File.expand_path("edge_connect_images/mq_dis.png", directory)
ab_rad = File.expand_path("edge_connect_images/mq_rad.png", directory)
ab_sep = File.expand_path("edge_connect_images/mq_sep.png", directory)
ab_lim = File.expand_path("edge_connect_images/mq_lim.png", directory)
ab_res = File.expand_path("edge_connect_images/mq_res.png", directory)

ab_out = File.expand_path("edge_connect_images/mq_out.png", directory)
ab_cro = File.expand_path("edge_connect_images/mq_cro.png", directory)
ab_cur = File.expand_path("edge_connect_images/mq_cur.png", directory)
ab_nor = File.expand_path("edge_connect_images/mq_nor.png", directory)

ab_ec = File.expand_path("edge_connect_images/mq_ec.png", directory)

ab_del_unc = File.expand_path("edge_connect_images/mq_del_unc.png", directory)
ab_del_cur = File.expand_path("edge_connect_images/mq_del_cur.png", directory)
ab_spl_cur = File.expand_path("edge_connect_images/mq_spl_cur.png", directory)


mqp_select = UI::Command.new("mqp_select") {
  MessizQinECPro.messizqin_select
}
mqp_select.small_icon = ab_select
mqp_select.large_icon = ab_select
mqp_select.tooltip = "Reselect"
mqp_select.status_bar_text = "Reselect edges within a panel"
toolbar.add_item mqp_select

mqp_show_mode = UI::Command.new("mqp_show_mode") {
  MessizQinECPro.show_mode()
}
mqp_show_mode.small_icon = ab_show_mode
mqp_show_mode.large_icon = ab_show_mode
mqp_show_mode.tooltip = "Show Setting"
mqp_show_mode.status_bar_text = "Display pre-connecting setting"
toolbar.add_item mqp_show_mode

mqp_mqp_dis = UI::Command.new("mqp_mqp_dis") {
  MessizQinECPro.replace_line(0, 1)
}
mqp_mqp_dis.small_icon = ab_dis
mqp_mqp_dis.large_icon = ab_dis
mqp_mqp_dis.tooltip = "Set Algorithm: Distance"
mqp_mqp_dis.status_bar_text = "Connect from close to far"
toolbar.add_item mqp_mqp_dis

mqp_mqp_rad = UI::Command.new("mqp_mqp_rad") {
  MessizQinECPro.replace_line(0, 2)
}
mqp_mqp_rad.small_icon = ab_rad
mqp_mqp_rad.large_icon = ab_rad
mqp_mqp_rad.tooltip = "Set Algorithm: Radians"
mqp_mqp_rad.status_bar_text = "Connect based on bearing sequence"
toolbar.add_item mqp_mqp_rad

mqp_mqp_sep = UI::Command.new("mqp_mqp_sep") {
  case MessizQinECPro.get_line(0).to_f
  when 1
    MessizQinECPro.replace_line(0, 3)
  when 2
    MessizQinECPro.replace_line(0, 4)
  end
}
mqp_mqp_sep.small_icon = ab_sep
mqp_mqp_sep.large_icon = ab_sep
mqp_mqp_sep.tooltip = "Set Method: Seperate"
mqp_mqp_sep.status_bar_text = "Connect in a separate manner"
toolbar.add_item mqp_mqp_sep


mqp_mqp_lim = UI::Command.new("mqp_mqp_lim") {
  MessizQinECPro.set_limit()
}
mqp_mqp_lim.small_icon = ab_lim
mqp_mqp_lim.large_icon = ab_lim
mqp_mqp_lim.tooltip = "Set Limit: Numeric"
mqp_mqp_lim.status_bar_text = "Set a value as maximun adding length"
toolbar.add_item mqp_mqp_lim



mqp_mqp_res = UI::Command.new("mqp_mqp_res") {
  MessizQinECPro.reset_limit()
}
mqp_mqp_res.small_icon = ab_res
mqp_mqp_res.large_icon = ab_res
mqp_mqp_res.tooltip = "Set Limit: None"
mqp_mqp_res.status_bar_text = "Clear maximun value set up"
toolbar.add_item mqp_mqp_res


mqp_mqp_out = UI::Command.new("mqp_mqp_out") {
  MessizQinECPro.set_mode(1)
}
mqp_mqp_out.small_icon = ab_out
mqp_mqp_out.large_icon = ab_out
mqp_mqp_out.tooltip = "Set Mode: Outline"
mqp_mqp_out.status_bar_text = "Set mode: only connect outline"
toolbar.add_item mqp_mqp_out

mqp_mqp_cro = UI::Command.new("mqp_mqp_cro") {
  MessizQinECPro.set_mode(2)
}
mqp_mqp_cro.small_icon = ab_cro
mqp_mqp_cro.large_icon = ab_cro
mqp_mqp_cro.tooltip = "Set Mode: Cross"
mqp_mqp_cro.status_bar_text = "Set mode: Leave out curve diameter connection"
toolbar.add_item mqp_mqp_cro

mqp_mqp_cur = UI::Command.new("mqp_mqp_cur") {
  MessizQinECPro.set_mode(3)
}
mqp_mqp_cur.small_icon = ab_cur
mqp_mqp_cur.large_icon = ab_cur
mqp_mqp_cur.tooltip = "Set Mode: Curve"
mqp_mqp_cur.status_bar_text = "Set mode: Leave out connected-edges diameter connection"
toolbar.add_item mqp_mqp_cur

mqp_mqp_nor = UI::Command.new("mqp_mqp_nor") {
  MessizQinECPro.set_mode(4)
}
mqp_mqp_nor.small_icon = ab_nor
mqp_mqp_nor.large_icon = ab_nor
mqp_mqp_nor.tooltip = "Set Mode: Normal"
mqp_mqp_nor.status_bar_text = "Set mode: For selected edges, connect all"
toolbar.add_item mqp_mqp_nor


mqp_mqp_ec = UI::Command.new("mqp_mqp_ec") {
  MessizQinECPro.messizqin_edge_connect
}
mqp_mqp_ec.small_icon = ab_ec
mqp_mqp_ec.large_icon = ab_ec
mqp_mqp_ec.tooltip = "Operate"
mqp_mqp_ec.status_bar_text = "Execute connecting"
toolbar.add_item mqp_mqp_ec


mqp_spl_cur = UI::Command.new("mqp_spl_cur") {
  MessizQinECPro.messizqin_cross_split(3)
}
mqp_spl_cur.small_icon = ab_spl_cur
mqp_spl_cur.large_icon = ab_spl_cur
mqp_spl_cur.tooltip = "Split"
mqp_spl_cur.status_bar_text = "Split crossed elements"
toolbar.add_item mqp_spl_cur

mqp_del_unc = UI::Command.new("mqp_del_unc") {
  MessizQinECPro.messizqin_cross_split(1)
}
mqp_del_unc.small_icon = ab_del_unc
mqp_del_unc.large_icon = ab_del_unc
mqp_del_unc.tooltip = "Delete Cross"
mqp_del_unc.status_bar_text = "Delete crossed elements"
toolbar.add_item mqp_del_unc

mqp_del_cur = UI::Command.new("mqp_del_cur") {
  MessizQinECPro.messizqin_cross_split(2)
}
mqp_del_cur.small_icon = ab_del_cur
mqp_del_cur.large_icon = ab_del_cur
mqp_del_cur.tooltip = "Delete Crossed (/Curve)"
mqp_del_cur.status_bar_text = "Delete crossed elements except for curve"
toolbar.add_item mqp_del_cur
