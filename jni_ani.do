onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /jni_ani_test/clk
add wave -noupdate /jni_ani_test/reset
add wave -noupdate /jni_ani_test/tdm_slot
add wave -noupdate -divider {ReCOP to NoC}
add wave -noupdate -color {Dark Orchid} /jni_ani_test/dpcr_in_recop
add wave -noupdate -color {Dark Orchid} /jni_ani_test/datacall_recop_if_array
add wave -noupdate -divider {NoC to JOP}
add wave -noupdate -color {Medium Spring Green} -expand -subitemconfig {/jni_ani_test/datacall_jop_if_array(2) {-color {Medium Spring Green} -height 15} /jni_ani_test/datacall_jop_if_array(1) {-color {Medium Spring Green} -height 15} /jni_ani_test/datacall_jop_if_array(0) {-color {Medium Spring Green} -height 15}} /jni_ani_test/datacall_jop_if_array
add wave -noupdate -color Gold -expand -subitemconfig {/jni_ani_test/dpcr_ack(2) {-color Gold -height 15} /jni_ani_test/dpcr_ack(1) {-color Gold -height 15} /jni_ani_test/dpcr_ack(0) {-color Gold -height 15}} /jni_ani_test/dpcr_ack
add wave -noupdate -color Gold -expand -subitemconfig {/jni_ani_test/dpcr_out(2) {-color Gold -height 15} /jni_ani_test/dpcr_out(1) {-color Gold -height 15} /jni_ani_test/dpcr_out(0) {-color Gold -height 15}} /jni_ani_test/dpcr_out
add wave -noupdate -divider {JOP to NoC}
add wave -noupdate -color Cyan -expand -subitemconfig {/jni_ani_test/dprr_in(2) {-color Cyan -height 15} /jni_ani_test/dprr_in(1) {-color Cyan -height 15} /jni_ani_test/dprr_in(0) {-color Cyan -height 15}} /jni_ani_test/dprr_in
add wave -noupdate -color {Cornflower Blue} -expand -subitemconfig {/jni_ani_test/result_jop_if_array(2) {-color {Cornflower Blue} -height 15} /jni_ani_test/result_jop_if_array(1) {-color {Cornflower Blue} -height 15} /jni_ani_test/result_jop_if_array(0) {-color {Cornflower Blue} -height 15}} /jni_ani_test/result_jop_if_array
add wave -noupdate -divider {NoC to ASP}
add wave -noupdate -color Violet -expand -subitemconfig {/jni_ani_test/datacall_asp_if_array(0) {-color Violet -height 15}} /jni_ani_test/datacall_asp_if_array
add wave -noupdate -color {Lime Green} /jni_ani_test/ani_gen(0)/asp_ani/asp_busy
add wave -noupdate -divider {ASP to NoC}
add wave -noupdate -color {Yellow Green} -expand -subitemconfig {/jni_ani_test/result_asp_if_array(0) {-color {Yellow Green} -height 15}} /jni_ani_test/result_asp_if_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {227 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 263
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
WaveRestoreZoom {100 ns} {459 ns}
