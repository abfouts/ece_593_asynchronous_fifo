onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/PROD_CLK
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/CON_CLK
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/O_DATA
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/I_DATA
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/O_WR_EN
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/O_RD_EN
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/I_FULL
add wave -noupdate -expand -group CCD_IF_TB /top/ccd_inst_if/I_EMPTY
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {61508960626 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {158935913325 ps}
