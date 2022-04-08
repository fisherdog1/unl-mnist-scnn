onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand /tb_axpc5/dut/sn_vec_out
add wave -noupdate /tb_axpc5/shiftreg
add wave -noupdate /tb_axpc5/s2b/symbols_out
add wave -noupdate /tb_axpc5/s2b/clk
add wave -noupdate /tb_axpc5/s2b/cke
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {41227442 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {40953600 ps} {41465600 ps}
