###########################################################################
#
# Generated by : Version 11.0 Build 208 07/03/2011 Service Pack 1 SJ Full Version
#
# Project      : NoC-HMP
# Revision     : NoC-HMP
#
# Date         : Mon Jun 16 17:11:22 +1200 2014
#
###########################################################################
 
 
# WARNING: Expected ENABLE_CLOCK_LATENCY to be set to 'ON', but it is set to 'OFF'
#          In SDC, create_generated_clock auto-generates clock latency
#
# ------------------------------------------
#
# Create generated clocks based on PLLs
derive_pll_clocks -use_tan_name
#
# ------------------------------------------


# Original Clock Setting Name: clk1_in
create_clock -period "20.000 ns" \
             -name {clk1_in} {clk1_in}
# ---------------------------------------------


# Original Clock Setting Name: clk0_in
create_clock -period "20.000 ns" \
             -name {clk0_in} {clk0_in}
# ---------------------------------------------

# ** Clock Latency
#    -------------

# ** Clock Uncertainty
#    -----------------

# ** Multicycles
#    -----------
# ** Cuts
#    ----

# ** Input/Output Delays
#    -------------------




# ** Tpd requirements
#    ----------------

# ** Setup/Hold Relationships
#    ------------------------

# ** Tsu/Th requirements
#    -------------------


# ** Tco/MinTco requirements
#    -----------------------



# ---------------------------------------------
# The following clock group is added to try to 
# match the behavior of:
#   CUT_OFF_PATHS_BETWEEN_CLOCK_DOMAINS = ON
# ---------------------------------------------

set_clock_groups -asynchronous \
                 -group { \
                       sys_pll:sys_pll_inst|altpll:altpll_component|_clk0 \
                       sys_pll:sys_pll_inst|altpll:altpll_component|_clk1 \
                       clk0_in \
                        } \
                 -group { \
                       jop_cmp:jop_container|pll:pll_inst|altpll:altpll_component|_clk0 \
                       jop_cmp:jop_container|pll:pll_inst|altpll:altpll_component|_clk1 \
                       clk1_in \
                        } \

# ---------------------------------------------

