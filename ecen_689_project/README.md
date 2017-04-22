# uvm_tb
> run setup.sh:   '$ . ./setup.sh' or '$ source ./setup.sh'

# compilation and elaboration
  cd ./project/sim/
  irun -f cmd_line_comp_elab.f

# running a test case in GUI
> cd ./project/sim/
> irun -f run_mc.f <+UVM_TESTNAME=test_case_name>

***************
## File Organization
• design – folder that contains all cache design files. "cache_top.sv" is the top level file.

• design/common – folder that contains component design files shared by level 1 and level 2 cache.

• design/lv1 – folder that contains component design files which exclusively belongs to level 1 cache.

• design/lv2 – folder that contains component design files which exclusively belongs to level 2 cache.

• sim – folder that contains files to control simulation and store results.
    sim/logs            directory for regression logs
    sim/cov_work        directory for coverage data

• gold – folder that contains the golden arbiter, and memory.

• uvm – folder that contains test bench files: driver, monitor, scoreboard, transactions, packet classes and checkers.

  top level test bench file: "top.sv"

• test – folder that contains test case files: virtual sequences and test classes.

***************
## Test Bench Instructions
  1. Currently the design has all 4 cores enabled. You can choose to initially verify a single core and subsequently proceed to the multi-core environment.

  2. Level 1 and level 2 cache are all empty at the beginning but memory is pre-filled with initial data. The value of a data block in
  the memory depend on bit[3] of its address.
  data = addr_bus_lv2_mem[3] ? 32'h5555_aaaa : 32'haaaa_5555;
  Once you write back to the memory, it will become the value you have written.

*******************

**************************************
Running a simulation
**************************************
You have two options:
1. GUI mode
    $ source setup.bash
    $ cd project/sim
    $ irun -f run_mc.f
    // Ensure that you have selected the correct UVM_TESTNAME within run_mc.f
2. Command Line
    $ source setup.bash
    $ cd project/sim
    // this will perform compilation and elaboration
    $ irun -f cmd_line_comp_elab.f 
    // this command will run the simulation
    $ irun -f sim_cmd_line.f +UVM_TESTNAME=read_miss_icache
    // You can check the results in the log file i.e. irun.log

**************************************
Scripts provided in sim folder
**************************************
1. all.bash -> will run all the testcases listed in this file with the default seed i.e. 1
    $ cd project/sim
    $ ./all.bash
2. regress.bash -> will run all the testcases listed in the file, 20 times
    $ ./regress.bash n {will run it n times}
    $ ./regress.bash    {will run it exactly 20 times}
all the logs will be output in ./project/sim/logs directory
You can use the ./analyse.bash script to list out the pass and fails
3. ./ALL_CLEAR -> will clear all the extra files within the sim directory
