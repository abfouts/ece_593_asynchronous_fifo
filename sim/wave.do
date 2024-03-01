onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/PROD_CLK
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/CON_CLK
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/RST_n
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/DATA_IN
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/W_EN
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/R_EN
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/DATA_OUT
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/FULL
add wave -noupdate -expand -group ASYNC_FIFO /top/dut/EMPTY
add wave -noupdate /top/dut/write
add wave -noupdate /top/dut/read
add wave -noupdate -radix decimal /top/dut/wr_ptr
add wave -noupdate -radix decimal /top/dut/rd_ptr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2163762 ps} 0}
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
WaveRestoreZoom {58899 ps} {186722 ps}
