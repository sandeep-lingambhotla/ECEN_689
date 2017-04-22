    +access+rwc                   //allow probes to record signals
    -timescale 1ns/1ns            //set simulation time precision
    -gui                          //launch user interface

//setup UVM home
    -uvmhome $UVMHOME

//UVM options
    +UVM_VERBOSITY=UVM_LOW

    +UVM_TESTNAME=read_miss_icache                    //-> DONE

//file list containing design and TB files to compiled
    -f file_list.f
