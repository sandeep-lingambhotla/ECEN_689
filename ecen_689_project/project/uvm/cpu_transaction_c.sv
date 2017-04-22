//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_transaction.sv
// Description: basic transaction class which is passed to the cpu agent and
// scoreboard
// Designers: Venky & Suru
//=====================================================================

typedef enum bit {READ_REQ=0, WRITE_REQ=1} request_t;
typedef enum bit {ICACHE_ACC, DCACHE_ACC} access_cache_t;

class cpu_transaction_c extends uvm_sequence_item;

    parameter DATA_WID_LV1      = `DATA_WID_LV1;
    parameter ADDR_WID_LV1      = `ADDR_WID_LV1;

    rand request_t                  request_type;
    rand bit [DATA_WID_LV1-1 : 0]   data;
    rand bit [ADDR_WID_LV1-1 : 0]   address;
    rand access_cache_t             access_cache_type;
    rand int unsigned               wait_cycles;

    // soft constraint for wait cycles within 0 and 20
    constraint ct_wait_time{
        soft wait_cycles >= 0;
        soft wait_cycles <= 20;
    }
    
    //TODO: Add meaningful constraints
    //You will notice that some of the data members are related. 
    //Example: you can obtain access_cache_type from address
    //It is useful to have constraints for such items

    // set default access to I-cache
    constraint ct_cache_type {
        soft access_cache_type == ICACHE_ACC;
    }
        
    // soft constraint for expected data in case of a read type -> ignored in scoreboard
    constraint ct_exp_data{
        if((request_type == READ_REQ) && (address[3] == 1)) {
            soft data == 32'h5555_AAAA;
        }
        else if ((request_type == READ_REQ) && (address[3] == 0)) {
            soft data == 32'hAAAA_5555;
        }
    }

    // UVM macros for built-in automation
    `uvm_object_utils_begin(cpu_transaction_c)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(address, UVM_ALL_ON)
        `uvm_field_enum(request_t, request_type, UVM_ALL_ON)
        `uvm_field_enum(access_cache_t,access_cache_type, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new (string name = "cpu_transaction_c");
        super.new(name);
    endfunction : new
endclass : cpu_transaction_c

