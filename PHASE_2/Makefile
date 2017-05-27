#
#	Makefile
#
#	Should build HCMP_ReCOP:JOP and all tools from scratch.
#
#	not included at the moment:
#		ACEX board
#		configuration CPLD compiling
#		Spartan-3 targets
#
#	You probably want to change the folloing parts in the Makefile:
#
#		QPROJ ... your Quartus FPGA project
#		COM_* ... your communication settings
#		TARGET_APP_PATH, MAIN_CLASS ... your target application
#
#	for a quick change you can also use command line arguments when invoking make:
#		make japp -e QPROJ=cycwrk TARGET_APP_PATH=java/target/src/bench MAIN_CLASS=jbe/DoAll
#
#

################################################################################
# Board configuration
################################################################################

#
#	Set USB to true for an FTDI chip based board (dspio, usbmin, lego)
#
USB=false

#
#	com1 is the usual serial port
#	com5 is the FTDI VCOM for the USB download
#		use -usb to download the Java application
#		without the echo 'protocol' on USB
#
ifeq ($(USB),true)
	COM_PORT=COM5
	COM_FLAG=-e -usb
else
	COM_FLAG=-e
ifeq ($(WINDIR),)
	COM_PORT=/dev/ttyUSB0
else 
	COM_PORT=COM1
endif
endif

#
#	Select the Quartus project
#
# 'some' different Quartus projects
QPROJ=altde2-115

# if you want to build only one Quartus project use e.q.:
ifeq ($(USB),true)
	QPROJ=usbmin
else
	QPROJ=altde2-115
endif

#
#	Select the Xilinx project byt setting XFPGA to true
#	Currently only the ml50x is supported
#	with a full make integration
XPROJ=ml50x
XFPGA=false

# Altera FPGA configuration cable
#BLASTER_TYPE=ByteBlasterMV
BLASTER_TYPE=USB-Blaster

ifeq ($(WINDIR),)
	DOWN=./down
	USBRUNNER=./USBRunner
	S=:
else
	DOWN=./down.exe
	USBRUNNER=USBRunner.exe
	S=\;
endif

#
#	Set CLDC11 to true to use the CLDC11 JDK
#
CLDC11=false

#
#	Whether to use JDK 1.6
#
JDK16=false

# Currently same hardware is used so all three cannot be "yes" at the same time
# Remember to edit decode.vhd file and uncomment/comment the appropriate microcode
#
# STPSR = start put static reference
# STPFR = start put filed reference
# STASTR = start array store reference
# 
# The same should be done in Instruction.java and uncomment/comment the lines where 
# stpfr, stsr, stastr are defined
#
# After that a full make is necessary

USE_HW_PUTFIELD_REF=no
USE_HW_PUTSTATIC_REF=no
USE_HW_AASTORE=no

#
# Number of cores for JopSim and RTTM simulation
#
CORE_CNT=3

# Which project do you want to be downloaded?
DLPROJ=$(QPROJ)

# Which project do you want to be programmed into the flash?
FLPROJ=$(DLPROJ)

# IP address for Flash programming
IPDEST=192.168.1.2
IPDEST=192.168.0.123

################################################################################
# Application configuration
################################################################################

# Jop RTS configuration
USE_SCOPES=false
USE_SCOPECHECKS=false
ADD_REF_INFO=false
MEASURE=true
JOP_CONF_STR=USE_SCOPES=$(USE_SCOPES) USE_SCOPECHECKS=$(USE_SCOPECHECKS) ADD_REF_INFO=$(ADD_REF_INFO) MEASURE=$(MEASURE)

P1=systemj
P2=hmpsoc
P3=RTSMain

#
# Run JVM Tests
# 
#P2=jvm
#P3=DoAll

#
# The test program for Basio and the NAND Flash
#
#P3=FlashBaseio


################################################################################
# Tool configuration
################################################################################

#
# Callstring length for analysis and optimization
#
CALLSTRING_LENGTH=0

#
# dataflow analysis
#
USE_DFA?=no

ifeq ($(USE_DFA),yes)
DFA_CACHE=--dfa-cache-dir java/target/wcet/dfa-cache
endif


#
#	Application optimization with JCopter
#
USE_JCOPTER?=no
JCOPTER_OPT?=--dump-callgraph merged --dump-jvm-callgraph off -O 2
JCOPTER_USE_WCA?=no


#
#       WCET analysis
#
WCET_CMP_ANALYSE=false
WCET_CMP_CORES=2
WCET_CMP_SLOTLENGHT=1
WCET_CMP_PERIOD=$(shell echo $(WCET_CMP_CORES)\*$(WCET_CMP_SLOTLENGHT) | bc)
WCET_METHOD=measure
WCET_OPTIONS=	--jop.jop-cmp $(WCET_CMP_ANALYSE) \
				--jop.jop-cmp-cpus $(WCET_CMP_CORES) \
				--jop.jop-cmp-timeslot $(WCET_CMP_PERIOD)


################## end of configuration section ###################

#
#	some variables
#
TOOLS=java/tools
# setting for my Eclipse CVS project
# TOOLS=../../workspace/cvs_jop_tools
EXT_CP=java/lib/bcel-5.2.jar$(S)java/lib/jakarta-regexp-1.3.jar$(S)java/lib/RXTXcomm.jar$(S)java/lib/lpsolve55j.jar$(S)java/lib/log4j-1.2.15.jar$(S)java/lib/jgrapht-jdk1.5.jar$(S)java/lib/velocity-1.5.jar$(S)java/lib/velocity-dep-1.5.jar

# The line below makes the compilation crash, because it causes JOPizer to include a *lot*
# of classes which are actually not necessary.
#EXT_CP=java/jopeclipse/com.jopdesign.jopeclipse/lib/bcel-5.2.jar$(S)java/lib/jakarta-regexp-1.3.jar$(S)java/lib/RXTXcomm.jar$(S)java/lib/lpsolve55j.jar
#EXT_CP=java/lib/recompiled_bcel-5.2.jar$(S)java/lib/jakarta-regexp-1.3.jar$(S)java/lib/RXTXcomm.jar$(S)java/lib/lpsolve55j.jar

#TOOLS_JFLAGS=-d $(TOOLS)/dist/classes -classpath $(EXT_CP) -sourcepath $(TOOLS)/src$(S)$(TARGET_SRC_PATH)/common
TOOLS_JFLAGS=-g -d $(TOOLS)/dist/classes -classpath $(EXT_CP) -sourcepath $(TOOLS)/src$(S)$(TARGET_SRC_PATH)/common -encoding Latin1

PCTOOLS=java/pc
PCTOOLS_JFLAGS=-g -d $(PCTOOLS)/dist/classes -sourcepath $(PCTOOLS)/src -encoding Latin1


TARGET=java/target
TARGET_SRC_PATH=$(TARGET)/src

# changed to add another class to the tool chain
#TOOLS_CP=-classpath $(EXT_CP)$(S)$(TOOLS)/dist/lib/jop-tools.jar
TOOLS_CP=-classpath $(TOOLS)/dist/lib/jop-tools.jar$(S)$(TOOLS)/dist/lib/JopDebugger.jar$(S)$(EXT_CP)

ifeq ($(CLDC11),true)
	TARGET_SOURCE=$(TARGET_SRC_PATH)/common$(S)$(TARGET_SRC_PATH)/cldc11/cldc_orig$(S)$(TARGET_SRC_PATH)/cldc11/cldc_mod$(S)$(TARGET_SRC_PATH)/cldc11/jdk_base_orig$(S)$(TARGET_SRC_PATH)/cldc11/jdk_base_mod$(S)$(TARGET_SRC_PATH)/rtapi$(S)$(TARGET_APP_SOURCE_PATH)
else
ifeq ($(JDK16),true)
	TARGET_SOURCE=$(TARGET_SRC_PATH)/common$(S)$(TARGET_SRC_PATH)/jdk_base$(S)$(TARGET_SRC_PATH)/jdk16$(S)$(TARGET_SRC_PATH)/rtapi$(S)$(TARGET_APP_SOURCE_PATH)
else
	TARGET_SOURCE=$(TARGET_SRC_PATH)/common$(S)$(TARGET_SRC_PATH)/jdk_base$(S)$(TARGET_SRC_PATH)/jdk11$(S)$(TARGET_SRC_PATH)/rtapi$(S)$(TARGET_APP_SOURCE_PATH)
endif
endif
TARGET_JFLAGS=-d $(TARGET)/dist/classes -sourcepath $(TARGET_SOURCE) -bootclasspath "" -extdirs "" -classpath "" -source 1.5 -target 1.5 -encoding Latin1
GCC_PARAMS=

# uncomment this to use RTTM
#USE_RTTM=yes

ifeq ($(USE_RTTM),yes)
GCC_PARAMS=-DRTTM
endif

# uncomment this if you want floating point operations in hardware
# ATTN: be sure to choose 'cycfpu' as QPROJ else no FPU will be available
#GCC_PARAMS=-DFPU_ATTACHED

#
#	Add your application source pathes and class that contains the
#	main method here. We are using those simple P1/2/3 variables for
#		P1=directory, P2=package name, and P3=main class
#	for sources 'inside' the JOP source tree
#
#	TARGET_APP_PATH is the path to your application source
#
#	MAIN_CLASS is the class that contains the Main method with package names
#
TARGET_APP_PATH=$(TARGET_SRC_PATH)/$(P1)
MAIN_CLASS=$(P2)/$(P3)

# here an example how to define an application outside
# from the jop directory tree
#TARGET_APP_PATH=/usr2/muvium/jopaptalone/src
#MAIN_CLASS=com/muvium/eclipse/PeriodicTimer/JOPBootstrapLauncher


#	add more directoies here when needed
#		(and use \; to escape the ';' when using a list!)
TARGET_APP_SOURCE_PATH=$(TARGET_APP_PATH)$(S)$(TARGET_SRC_PATH)/bench$(S)$(TARGET_SRC_PATH)/app
TARGET_APP=$(TARGET_APP_PATH)/$(MAIN_CLASS).java


# setting for rup DSVM on JopCMP
#TARGET_APP_PATH=/usrx/DSVMFP/src

# just any name that the .jop file gets.
JOPBIN=$(P3).NoC-HMP


#
#	Debugger stuff
#
# Added flags for development with JDWP
#DEBUG_PORT = 8000
DEBUG_PORT = 8001
DEBUG_PARAMETERS= -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=$(DEBUG_PORT)
#DEBUG_PARAMETERS= 

#DEBUG_JOPIZER=$(DEBUG_PARAMETERS)
DEBUG_JOPIZER=

#DEBUG_JOPSIM=$(DEBUG_PARAMETERS)
DEBUG_JOPSIM=

# Use local RXTX libary if other not specified
# e.g RXTXcomm-2.2pre2
JAVA_RXTX_LIB?=java/lib/RXTXcomm.jar

#
#	application optimization with ProGuard:
#	proguard.sourceforge.net/
#	uncomment following line to use it
#OPTIMIZE=mv java/target/dist/lib/classes.jar java/target/dist/lib/in.zip; java -jar java/lib/proguard.jar @optimize.pro

################################################################################
# Make rules
################################################################################

# build everything from scratch
all:
	make init
	#make sysjtools sysj
ifeq ($(USB),true)
	make jopusb
else
	make jopser
endif
	make japp

SYSJ_BASE=systemj
SYSJ_COMPILER=$(SYSJ_BASE)/compiler
SYSJ_RTE=$(SYSJ_BASE)/rts
MRASM_DIR=$(SYSJ_BASE)/mrasm
SYSJ_ASM=$(MRASM_DIR)/mrasm
SYSJ_HMPSOC=$(SYSJ_BASE)/hmpsoc-backend
SYSJ_EMBRTS_PATH=$(SYSJ_RTE)/embedded/src/main/resources

SYSJ_CMD=systemj/bin/sysjc
HMPSOC_CMD=systemj/bin/hmpsoc
#  SYSJ_CMD=sysjc
#  HMPSOC_CMD=hmpsoc

TARGET_SYSJ_SRC_PATH=$(TARGET_SRC_PATH)/systemj

ALLOC=bottling_station/alloc.json
CFG=bottling_station/bs.xml
SYSJ=bottling_station/bs.sysj

ifeq ($(DISTMEM),true)
override DISTMEM=-i
endif
ifeq ($(DYN),true)
override DYN=-y
endif

METHOD=-Sm # -l $(shell find java/target/dist/bin/* -not -name '*.txt')
ifeq ($(METHOD),false)
override METHOD=
else ifeq ($(METHOD),true)
override METHOD=-Sm # -l $(shell find java/target/dist/bin/* -not -name '*.txt')
endif

ifeq ($(SCHED1),true)
override SCHED=-s 1
else ifeq ($(SCHED2),true)
override SCHED=-s 2
endif

sysjtools:
	cd $(MRASM_DIR) && make


define sysj-resolve-addrs=
mkdir -p hmpsoc/jopbins;\
for f in $$(find $(TARGET_SYSJ_SRC_PATH)/hmpsoc -name 'RTSMain*.java') ; do\
	p=$$(basename $$f);\
	make java_app P3=$${p%.*} || exit 1; \
	cp $$(find java/target/dist/bin/* -not -name '*.txt') hmpsoc/jopbins ;\
done
for f in $$(find hmpsoc -name '*.s') ; do\
	$(HMPSOC_CMD) $$f -d hmpsoc -l $$(find hmpsoc/jopbins -type f) ;\
done
endef

define sysj-assemble=
for FILE in hmpsoc/*.asm ; do \
	NUM=$$(echo $$FILE | sed -e s/[^0-9]//g) ; \
	$(SYSJ_ASM)/mrasm $$FILE -s65535 -i$(SYSJ_ASM)/newr;\
	mv -v rawOutput.mif asm/recop_src/rawOutput$$NUM.mif; \
done
endef

sim_sysj: init sysjtools sysj sim

sysj:
	rm -rf $(TARGET_SYSJ_SRC_PATH)/hmpsoc
	rm -rf hmpsoc
	find $(SYSJ_EMBRTS_PATH) -maxdepth 1 \( ! -path $(SYSJ_EMBRTS_PATH) -a -type d -o -name \*.java \) -exec cp -rf {} $(TARGET_SYSJ_SRC_PATH) \;
	$(SYSJ_CMD) --verbose --hmpsoc $(DISTMEM),$(DYN),$(METHOD),$(SCHED),-j,$(SYSJ_BASE)/src/$(ALLOC),-c,$(SYSJ_BASE)/src/$(CFG) -- $(SYSJ_BASE)/src/$(SYSJ)
	-mkdir asm/recop_src
ifeq ($(METHOD),)
else
	cp -r hmpsoc/ $(TARGET_SYSJ_SRC_PATH)
	$(sysj-resolve-addrs)
endif
	$(sysj-assemble)
	cp -rf hmpsoc $(TARGET_SYSJ_SRC_PATH)

update_addrs:
	$(sysj-resolve-addrs)
	$(sysj-assemble)
	cp -rf hmpsoc/*.asm $(TARGET_SYSJ_SRC_PATH)/hmpsoc
	cp -rf hmpsoc/jopbins/* $(TARGET_SYSJ_SRC_PATH)/hmpsoc/jopbins/*
	make update_mif

# Build toolchain and autogenerate source files
init:
	make directories
	make tools
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SERIAL
	make jop_config 

# build the Java application and download it
japp:
	make java_app
	make config
	make download

# configure the FPGA
config:
ifeq ($(USB),true)
	make config_usb
else
ifeq ($(XFPGA),true)
	make config_xilinx
else
	make config_byteblaster
endif
endif

install:
	@echo nothing to install

# cleanup
EXTENSIONS=class rbf rpt sof pin summary ttf qdf dat wlf done qws

clean:
	for ext in $(EXTENSIONS); do \
		find `ls` -name \*.$$ext -print -exec rm -r -f {} \; ; \
	done
	-find `ls` -name NoC-HMP.pof -print -exec rm -r -f {} \;
	-find `ls` -name db -print -exec rm -r -f {} \;
	-find `ls` -name incremental_db -print -exec rm -r -f {} \;
	-rm -rf asm/generated
#    -rm -f vhdl/*.vhd # This need to be updated so non-artifact vhdl files are not cleaned up!
	-rm -rf $(TOOLS)/dist
	-rm -rf $(PCTOOLS)/dist
	-rm -rf $(TARGET)/dist
	-rm -rf modelsim/work
	-rm -rf modelsim/transcript
	-rm -rf modelsim/gaisler
	-rm -rf modelsim/grlib
	-rm -rf modelsim/techmap


#
#	build all the (Java) tools
#
tools:
	-rm -rf $(TOOLS)/dist
	mkdir $(TOOLS)/dist
	mkdir $(TOOLS)/dist/lib
	mkdir $(TOOLS)/dist/classes
	javac $(TOOLS_JFLAGS) $(TOOLS)/src/*.java
	javac $(TOOLS_JFLAGS) $(TOOLS)/src/org/apache/bcel/util/*.java
	javac $(TOOLS_JFLAGS) $(TOOLS)/src/com/jopdesign/build/*.java
	javac $(TOOLS_JFLAGS) $(TOOLS)/src/com/jopdesign/tools/*.java
	javac $(TOOLS_JFLAGS) $(TOOLS)/src/com/jopdesign/dfa/*.java
	javac $(TOOLS_JFLAGS) $(TOOLS)/src/com/jopdesign/jcopter/*.java
	javac $(TOOLS_JFLAGS) $(TOOLS)/src/com/jopdesign/wcet/*.java
	cp $(TOOLS)/src/com/jopdesign/wcet/report/*.vm $(TOOLS)/dist/classes/com/jopdesign/wcet/report
# quick hack to get the tools with the debugger ok
# the build.xml from the debugger contains the correct info
# but also some more (old?) stuff
# does not work as some Sun classes for JDWP are missing
#	javac $(TOOLS_JFLAGS) $(TOOLS)/src/com/jopdesign/debug/jdwp/*.java
	cd $(TOOLS)/dist/classes && jar cf ../lib/jop-tools.jar *


# we moved the pc stuff to it's own target to be
# NOT built on make all.
# It depends on javax.comm which is NOT installed
# by default - Blame SUN on this!
#
#	TODO: change it to RXTXcomm if it's working ok
#
pc:
	-rm -rf $(PCTOOLS)/dist
	mkdir $(PCTOOLS)/dist
	mkdir $(PCTOOLS)/dist/lib
	mkdir $(PCTOOLS)/dist/classes
#	make compile_java -e JAVA_DIR=$(PCTOOLS)/src
	javac $(PCTOOLS_JFLAGS) $(PCTOOLS)/src/udp/*.java
	cd $(PCTOOLS)/dist/classes && jar cf ../lib/jop-pc.jar *

#
# make target for the tools that are still in C
#
cprog:
	gcc c_src/amd.c -o amd.exe
	gcc c_src/e.c -o e.exe

#
#	compile and JOPize the application
#
ifeq (${WCET_METHOD},measure)
   JCOPTER_DEFAULT_OPTS=--inline.exclude-wca-targets true
else
   JCOPTER_DEFAULT_OPTS=
endif 
JCOPTER_DEFAULT_OPTS+= --use-dfa $(USE_DFA) --callstring-length $(CALLSTRING_LENGTH) --sp $(TARGET_SOURCE)
JCOPTER_OPTIONS=$(JCOPTER_DEFAULT_OPTS) ${JCOPTER_OPT} 

jop_config:
	java $(TOOLS_CP) com.jopdesign.tools.GenJopConfig $(JOP_CONF_STR) > $(TARGET)/src/common/com/jopdesign/sys/Config.java

java_app: 
	-rm -rf $(TARGET)/dist
	-mkdir $(TARGET)/dist
	-mkdir $(TARGET)/dist/classes
	-mkdir $(TARGET)/dist/lib
	-mkdir $(TARGET)/dist/bin

	make jop_config

	javac $(TARGET_JFLAGS) $(TARGET_SRC_PATH)/common/com/jopdesign/sys/*.java
ifeq ($(CLDC11),false)
	javac $(TARGET_JFLAGS) $(TARGET_SRC_PATH)/jdk_base/java/lang/annotation/*.java	# oh new Java 1.5 world!
endif

ifeq ($(USE_RTTM),yes)	
	javac $(TARGET_JFLAGS) $(TARGET_SRC_PATH)/common/rttm/internal/Utils.java
endif
	javac $(TARGET_JFLAGS) $(TARGET_APP)
# WCETPreprocess, overwrite existing class files 
	java $(DEBUG_JOPIZER) $(TOOLS_CP) com.jopdesign.wcet.WCETPreprocess \
           -c $(TARGET)/dist/classes -o $(TARGET)/dist $(MAIN_CLASS)
# Optimize
ifeq ($(USE_JCOPTER),yes)
ifeq (${JCOPTER_USE_WCA},no)
	rm -rf $(TARGET)/dist/classes.unopt; \
	mv $(TARGET)/dist/classes $(TARGET)/dist/classes.unopt
	java -Xmx1280M $(DEBUG_JOPIZER) $(TOOLS_CP) com.jopdesign.jcopter.JCopter \
	   -c $(TARGET)/dist/classes.unopt -o $(TARGET)/dist --classdir $(TARGET)/dist/classes \
	   --no-use-wca $(JCOPTER_OPTIONS) $(MAIN_CLASS)
else
	for target in ${WCET_METHOD}; do \
	  rm -rf $(TARGET)/dist/classes.unopt; \
	  mv $(TARGET)/dist/classes $(TARGET)/dist/classes.unopt; \
	  java -Xmx1280M $(DEBUG_JOPIZER) $(TOOLS_CP) com.jopdesign.jcopter.JCopter \
	   -c $(TARGET)/dist/classes.unopt -o $(TARGET)/dist --classdir $(TARGET)/dist/classes \
	   --use-wca --wca-target $${target} $(JCOPTER_OPTIONS) $(MAIN_CLASS) || exit 1; \
	done
endif
endif 
	cd $(TARGET)/dist/classes && jar cf ../lib/classes.jar *
# use SymbolManager for Paulo's version of JOPizer instead
	java $(DEBUG_JOPIZER) $(TOOLS_CP) -Dmgci=false com.jopdesign.build.JOPizer \
		-cp $(TARGET)/dist/lib/classes.jar -o $(TARGET)/dist/bin/$(JOPBIN) $(MAIN_CLASS)
#	java $(DEBUG_JOPIZER) $(TOOLS_CP) -Dmgci=false com.jopdesign.debug.jdwp.jop.JopSymbolManager \
#		-cp $(TARGET)/dist/lib/classes.jar -o $(TARGET)/dist/bin/$(JOPBIN) $(MAIN_CLASS)
	java $(TOOLS_CP) com.jopdesign.tools.jop2dat $(TARGET)/dist/bin/$(JOPBIN)
	# cp *.dat modelsim
	cp mem_main.dat modelsim/mem_main$(ITER).dat
	rm -f *.dat

jcopter_help:
	java $(DEBUG_JOPIZER) $(TOOLS_CP) com.jopdesign.jcopter.JCopter --help
	@echo "[make] Default JCopter options:"
	@echo "[make] JCOPTER_OPT=$(JCOPTER_OPT)"
	@echo ""

#	project.sof fiels are used to boot from the serial line
#
jopser:
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SERIAL
ifeq ($(XFPGA),true)
	@echo $(XPROJ)
	cd xilinx/$(XPROJ) && make
else
	@echo $(QPROJ)
	for target in $(QPROJ); do \
		make qsyn -e QBT=$$target || exit; \
		quartus_cpf  -c -q 10MHz -g 3.3 -n p quartus/$$target/NoC-HMP.sof rbf/NoC-HMP.svf; \
	done
endif


#
#	project.rbf fiels are used to boot from the USB interface
#
jopusb:
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=USB
	@echo $(QPROJ)
	for target in $(QPROJ); do \
		make qsyn -e QBT=$$target || exit; \
		cd quartus/$$target && quartus_cpf -c NoC-HMP.sof ../../rbf/$$target.rbf; \
	done

#
#	project.ttf files are used to boot from flash.
#
jopflash:
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=FLASH
	@echo $(QPROJ)
	for target in $(QPROJ); do \
		make qsyn -e QBT=$$target || exit; \
		quartus_cpf -c quartus/$$target/NoC-HMP.sof ttf/$$target.ttf; \
	done

BLOCK_SIZE=4096
#
#	assemble the microcode and generate on-chip memory files
#
gen_mem:
	rm -rf asm/generated
	mkdir asm/generated
	gcc -x c -E -C -P $(GCC_PARAMS) -D$(JVM_TYPE) asm/src/$(ASM_SRC).asm > asm/generated/jvmgen.asm
	java $(TOOLS_CP) com.jopdesign.tools.Jopa -s asm/generated -d asm/generated jvmgen.asm
# generate Xilinx and Actel memory files
	java $(TOOLS_CP) BlockGen -b $(BLOCK_SIZE) -pd -m xram_block asm/generated/ram.mif asm/generated/xram_block.vhd
	java $(TOOLS_CP) BlockGen -b 16384 -pd -m xram_block asm/generated/ram.mif asm/generated/xv4ram_block.vhd
	java $(TOOLS_CP) GenAsynROM -m actelram_initrom asm/generated/ram.mif asm/generated/actelram_initrom.vhd
# copy generated files into working directories
	cp asm/generated/*.vhd vhdl
	cp asm/generated/*.dat modelsim
# generate memory files for ReCOP
	# for FILE in asm/recop_src/*.mif ; do \
		# ./SimulationTool_mif2dat.sh $$FILE ; \
	# done

#
#	Quartus build process
#		called by jopser, jopusb,...
#
qsyn:
	echo $(QBT)
	echo "building $(QBT)"
	-rm -rf quartus/$(QBT)/db
	-rm -f quartus/$(QBT)/NoC-HMP.sof
	-rm -f jbc/$(QBT).jbc
	-rm -f rbf/$(QBT).rbf
	quartus_map quartus/$(QBT)/NoC-HMP
	quartus_fit quartus/$(QBT)/NoC-HMP
	quartus_asm quartus/$(QBT)/NoC-HMP
#	quartus_tan quartus/$(QBT)/NoC-HMP
	quartus_sta quartus/$(QBT)/NoC-HMP
	# echo "  --- updating mif files ---  "
	# quartus_cdb quartus/$(QBT)/NoC-HMP -c NoC-HMP --update_mif
	# echo "  --- recompile ---  "
	# quartus_asm --read_settings_files=on --write_settings_files=off quartus/$(QBT)/NoC-HMP -c NoC-HMP

update_mif:
	echo "  --- updating mif files ---  "
	quartus_cdb quartus/$(QPROJ)/NoC-HMP -c NoC-HMP --update_mif
	echo "  --- recompile ---  "
	quartus_asm --read_settings_files=on --write_settings_files=off quartus/$(QPROJ)/NoC-HMP -c NoC-HMP


#
#	Modelsim target
#		without the tools
#
sim: java_app
	#if [ "${MODELSIMDIR}" = "" ]; then
	#	export MODELSIMDIR="/cygdrive/c/modeltech_10.0c/"
	#	if [ -x ${MODELSIMDIR}/bin/win32/vsim ]; then
	#		export PATH="${PATH}:${MODELSIMDIR}/win32"
	#		export MODEL_TECH="${MODELSIMDIR}/win32"
	#	fi
	#fi
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SIMULATION
	cd modelsim && make NoC-HMP

simDist: java_app_dist
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SIMULATION
	cd modelsim && make NoC-HMPDist

ITER=0

java_app_dist: 
	i=0;\
	for v in $(P3); do \
		make java_app P3=$$v ITER=$$i || exit 1; \
		i=$$(( i + 1 ));\
	done


#
#	Modelsim target for CMP version of JOP
#		without the tools
#
sim_cmp: java_app
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SIMULATION
	cd modelsim && make cmp

sim_csp: java_app
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SIMULATION
	cd modelsim && make csp

#
#	Modelsim target for Gomspace CSP in JOP
#
sim_iic: java_app
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SIMULATION
	cd modelsim && make iic	


#
#	JopSim target
#		without the tools
#		use -Dcpucnt=# for a CMP simulation
#
jsim: java_app
	java $(DEBUG_JOPSIM) -cp java/tools/dist/lib/jop-tools.jar -Dlog="false" \
	com.jopdesign.tools.JopSim java/target/dist/bin/$(JOPBIN)

#
#	Simulate RTTM (Jopsim target)
#
jtmsim: java_app
	java $(DEBUG_JOPSIM) -cp java/tools/dist/lib/jop-tools.jar -Dcpucnt=$(CORE_CNT) \
	com.jopdesign.tools.TMSim java/target/dist/bin/$(JOPBIN)

#
#   Simulate RTTM (Modelsim target)
#
tmsim: java_app
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SIMULATION
	cd modelsim && ./sim_tm.bat -i -do sim_tm.do

tmsimcon: java_app
	make gen_mem -e ASM_SRC=jvm JVM_TYPE=SIMULATION
	cd modelsim && ./sim_tm.bat -c -do sim_tm_con.do

#
#	RTTM tests on hardware
#

ifeq ($(USB),true)
TEST_JAPP_CONFIG=config_usb
else
TEST_JAPP_CONFIG=config_byteblaster
endif
test_japp: java_app $(TEST_JAPP_CONFIG) test_download

rttm_tests:
	for t in `find java/target/src/test/rttm/tests/*.java -printf %f\\\\n|sed 's/\.java//'`; do \
		make test_japp -e P1=test P2=rttm/tests P3=$$t REFERENCE_PATTERN=java/target/src/test/rttm/tests/$$t.pattern || exit; \
	done

test_download:
	./down $(COM_FLAG) java/target/dist/bin/$(JOPBIN) $(COM_PORT)|java $(TOOLS_CP) com.jopdesign.tools.MatchPattern $(REFERENCE_PATTERN)

#
#	Simulate data cache
#
dcsim: java_app
	java $(DEBUG_JOPSIM) -cp java/tools/dist/lib/jop-tools.jar \
	com.jopdesign.tools.DCacheSim java/target/dist/bin/$(JOPBIN)

#
#	JopServer target
#		without the tools
#
jsim_server: java_app
	java $(DEBUG_JOPSIM) \
	-cp java/tools/dist/lib/jop-tools.jar$(S)$(TOOLS)/dist/lib/JopDebugger.jar -Dlog="false" \
	com.jopdesign.debug.jdwp.jop.JopServer java/target/dist/bin/$(JOPBIN)


config_byteblaster:
	cd quartus/$(DLPROJ) && quartus_pgm -c $(BLASTER_TYPE) -m JTAG NoC-HMP.cdf

config_usb:
	cd rbf && ../$(USBRUNNER) $(DLPROJ).rbf

config_xilinx:
	cd xilinx/$(XPROJ) && make config


download:
#	this is the Java version for downloading
#	java -cp java/tools/dist/lib/jop-tools.jar$(S)$(JAVA_RXTX_LIB) com.jopdesign.tools.JavaDown \
#	$(COM_FLAG) java/target/dist/bin/$(JOPBIN) $(COM_PORT)

#	this is the download version with down.exe
	$(DOWN) $(COM_FLAG) java/target/dist/bin/$(JOPBIN) $(COM_PORT)

#
#	flash programming
#
prog_flash: java_app
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o p\;jbc/$(DLPROJ).jbc
	down java/target/dist/bin/$(JOPBBIN) $(COM_PORT)
	java -cp java/pc/dist/lib/jop-pc.jar udp.Flash java/target/dist/bin/$(JOPBIN) $(IPDEST)
	java -cp java/pc/dist/lib/jop-pc.jar udp.Flash ttf/$(FLPROJ).ttf $(IPDEST)
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o p\;quartus/cycconf/cyc_conf.pof

#
#	flash programming for the BG hardware as an example
#
#prog_flash:
#	quartus_pgm -c ByteblasterMV -m JTAG -o p\;jbc/$(DLPROG).jbc
#	cd java/target && ./build.bat app oebb BgInit
#	down java/target/dist/bin/oebb_BgInit.jop $(COM_PORT)
#	cd java/target && ./build.bat app oebb Main
#	java -cp java/pc/dist/lib/jop-pc.jar udp.Flash java/target/dist/bin/oebb_Main.jop 192.168.1.2
#	java -cp java/pc/dist/lib/jop-pc.jar udp.Flash ttf/$(FLPROJ).ttf 192.168.1.2
#	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o p\;quartus/cycconf/cyc_conf.pof

erase_flash:
	java -cp java/pc/dist/lib/jop-pc.jar udp.Erase $(IPDEST)

pld_init:
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o p\;quartus/cycconf/cyc_conf_init.pof

pld_conf:
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o p\;quartus/cycconf/cyc_conf.pof

oebb:
	java -cp java/pc/dist/lib/jop-pc.jar udp.Flash java/target/dist/bin/oebb_Main.NoC-HMP 192.168.1.2

# do the whole build process including flash programming
# for BG and baseio (TAL)
bg: directories tools jopflash jopser prog_flash

#
#	some directories for configuration files
#
directories: jbc ttf rbf

jbc:
	mkdir jbc

ttf:
	mkdir ttf

rbf:
	mkdir rbf

#
# this line configures the FPGA and programs the PLD
# but uses a .jbc file
#
# However, the order is not so perfect. We would prefere to first
# program the PLD.
#
xxx:
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o p\;jbc/cycbg.jbc
	quartus_pgm -c $(BLASTER_TYPE) -m JTAG -o p\;jbc/cyc_conf.jbc


#
#	JOP porting test programs
#
#	TODO: combine all quartus stuff to a single target
#
jop_blink_test:
	make gen_mem -e ASM_SRC=blink JVM_TYPE=NOOP
	@echo $(QPROJ)
	for target in $(QPROJ); do \
		echo "building $$target"; \
		rm -rf quartus/$$target/db; \
		qp="quartus/$$target/NoC-HMP"; \
		echo $$qp; \
		quartus_map $$qp; \
		quartus_fit $$qp; \
		quartus_asm $$qp; \
#		quartus_tan $$qp; \
		quartus_sta $$qp; \
		cd quartus/$$target && quartus_cpf -c NoC-HMP.sof ../../rbf/$$target.rbf; \
	done
	make config
	e $(COM_PORT)


jop_testmon:
	make gen_mem -e ASM_SRC=testmon JVM_TYPE=NOOP
	@echo $(QPROJ)
	for target in $(QPROJ); do \
		echo "building $$target"; \
		rm -rf quartus/$$target/db; \
		qp="quartus/$$target/NoC-HMP"; \
		echo $$qp; \
		quartus_map $$qp; \
		quartus_fit $$qp; \
		quartus_asm $$qp; \
#		quartus_tan $$qp; \
		quartus_sta $$qp; \
		cd quartus/$$target && quartus_cpf -c NoC-HMP.sof ../../rbf/$$target.rbf; \
	done
	make config


#
#	UDP debugging
#
udp_dbg:
	java -cp java/pc/dist/lib/jop-pc.jar udp.UDPDbg


# set library path to current directory for the Mac
DYLD_FALLBACK_LIBRARY_PATH:=.:$(DYLD_FALLBACK_LIBRARY_PATH)
export DYLD_FALLBACK_LIBRARY_PATH 


# WCET analyzer
# make before     : java_app
# make after (dot): (cd java/target/wcet/<project-name>; make)
#
# Makefile options:
# WCET_UPPAAL: whether to use modelchecking for WCET analysis
# WCET_VERIFYTA: UPPAAL verifier executable
# WCET_OPTIONS: Additional WCET options (run 'make wcet_help')
#
# Profiling: add -Xss16M -agentlib:hprof=cpu=samples,interval=2,depth=8 to java arguments
# On Mac don't forget:
# export DYLD_FALLBACK_LIBRARY_PATH=.
WCET_DFA?=$(USE_DFA)
WCET_UPPAAL?=no
WCET_VERIFYTA?=verifyta	 # only needed if WCET_UPPAAL=yes
wcet:
	-mkdir -p $(TARGET)/wcet
	# Reading the classes.jar does not work correctly for optimized code because we need the sourcelines.txt
	for target in $(WCET_METHOD); do \
	  java -Xss16M -Xmx1280M $(JAVA_OPT) \
	    $(TOOLS_CP) com.jopdesign.wcet.WCETAnalysis \
		--classpath $(TARGET)/dist/classes --sp $(TARGET_SOURCE) \
		--target-method $${target} \
		-o "$(TARGET)/wcet/\$${projectname}" \
		--use-dfa $(WCET_DFA) $(DFA_CACHE) \
		--uppaal $(WCET_UPPAAL) --uppaal-verifier $(WCET_VERIFYTA) \
		--callstring-length $(CALLSTRING_LENGTH) \
		-v -d \
		$(WCET_OPTIONS) $(MAIN_CLASS) || exit 1; \
	done
	
# WCET help
wcet_help:
	java $(TOOLS_CP) com.jopdesign.wcet.WCETAnalysis --help


# report works for wcet.WCETAnalyser
WCET_REPORT_DIR=$(TARGET)/wcet/$(subst /,_,$(P2))_$(P3)_$(WCET_METHOD)/report
wcet_report:
	cd  $(WCET_REPORT_DIR) && make
	firefox $(WCET_REPORT_DIR)/index.html

dfa:
	java -Xss16M $(TOOLS_CP) com.jopdesign.dfa.Main \
		-cp $(TARGET)/dist/lib/classes.jar $(MAIN_CLASS)

test:
	java $(TOOLS_CP) com.jopdesign.wcet.CallGraph \
		-cp $(TARGET)/dist/lib/classes.jar -o $(TARGET)/wcet/$(P3)call.txt -sp $(TARGET_SOURCE) $(MAIN_CLASS)


###### end of Makefile #######







#
# some MS specific setting - just ignore it
#

# shortcut for my work in Eclipse on TCP/IP
eapp: ecl_app config_usb download

esim: ecl_app
	java $(DEBUG_JOPSIM) -cp java/tools/dist/lib/jop-tools.jar -Dlog="false" \
	com.jopdesign.tools.JopSim java/target/dist/bin/$(JOPBIN)

#
# do it from my eclipse workspace
#
ecl_app:
	cd ../../workspace/cvs_jop_target/classes && jar cf ../../../cpu/jop/java/target/dist/lib/classes.jar *
	java $(TOOLS_CP) -Dmgci=false com.jopdesign.build.JOPizer \
		-cp $(TARGET)/dist/lib/classes.jar -o $(TARGET)/dist/bin/$(JOPBIN) $(MAIN_CLASS)
	java $(TOOLS_CP) com.jopdesign.tools.jop2dat $(TARGET)/dist/bin/$(JOPBIN)
	cp *.dat modelsim
	rm -f *.dat

#
# test AppInfo
# MS: some temporary targets for AppInfo and libgraph tests
#
appinfo: tools
	java $(DEBUG_JOPIZER) $(TOOLS_CP) com.jopdesign.build.AppInfo \
		-cp $(TARGET)/dist/lib/classes.jar $(MAIN_CLASS)

testapp: tools
	make java_app
	-mkdir $(TARGET)/xxx
	java $(DEBUG_JOPIZER) $(TOOLS_CP) com.jopdesign.build.WCETPreprocess \
		-cp $(TARGET)/dist/lib/classes.jar -o $(TARGET)/xxx $(MAIN_CLASS)
	java $(DEBUG_JOPIZER) $(TOOLS_CP) -Dmgci=false com.jopdesign.build.JOPizer \
		-cp $(TARGET)/xxx -o $(TARGET)/dist/bin/$(JOPBIN) $(MAIN_CLASS)
