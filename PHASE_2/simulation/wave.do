onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_asp_ani_combined/t_clk
add wave -noupdate /test_asp_ani_combined/t_reset
add wave -noupdate /test_asp_ani_combined/t_d_from_noc
add wave -noupdate /test_asp_ani_combined/t_d_to_noc
add wave -noupdate /test_asp_ani_combined/t_tdm_slot
add wave -noupdate /test_asp_ani_combined/t_key
add wave -noupdate /test_asp_ani_combined/t_sw
add wave -noupdate /test_asp_ani_combined/t_clk_period
add wave -noupdate /test_asp_ani_combined/t_tdm_slot_width
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/asp_valid
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/asp_busy
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/asp_res_ready
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/d_to_asp
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/d_from_asp
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/ani_component/s_inc_wr_en
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/ani_component/s_inc_rd_en
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/asp_component/busy
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/asp_component/CS
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/asp_component/s_pointer
add wave -noupdate /test_asp_ani_combined/t_asp_ani_combined/asp_component/s_end_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2641 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 411
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
WaveRestoreZoom {2409 ns} {3219 ns}
