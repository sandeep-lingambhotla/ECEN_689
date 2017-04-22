//=====================================================================
// Project: 4 core MESI cache design
// File Name: cpu_driver_c.sv
// Description: cpu driver component
// Designers: Venky & Suru
//=====================================================================

`define TIME_OUT_VAL 110

class cpu_driver_c extends uvm_driver #(cpu_transaction_c);
    //component macro
    `uvm_component_utils(cpu_driver_c)
    parameter DATA_WID_LV1           = `DATA_WID_LV1       ;
    parameter ADDR_WID_LV1           = `ADDR_WID_LV1       ;

    // Virtual interface of used to drive and observe CPU-LV1 interface signals
    virtual interface cpu_lv1_interface vi_cpu_lv1_if;

    //constructor
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern protected task get_and_drive();
    extern protected task send_to_dut(cpu_transaction_c transaction);
    extern protected task drv_rd_trans(bit [ADDR_WID_LV1-1:0] addr, bit [DATA_WID_LV1-1:0] exp_data);
    //TODO add code for drv_wr_trans (task to perform a write operation)
endclass : cpu_driver_c

    //UVM build phase ()
    function void cpu_driver_c::build_phase(uvm_phase phase);
        super.build_phase(phase);

        // throw error if virtual interface is not set
        if (!uvm_config_db#(virtual cpu_lv1_interface)::get(this, "","vif", vi_cpu_lv1_if))
            `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"})
    endfunction: build_phase

    //UVM run phase()
    task cpu_driver_c::run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "RUN Phase", UVM_LOW)
        get_and_drive();
    endtask: run_phase

    //Gets packets from the sequencer and passes them to the driver.
    task cpu_driver_c::get_and_drive();
        forever begin
            // Get new item from the sequencer
            seq_item_port.get_next_item(req);
            // Drive the item
            send_to_dut(req);
            // Communicate item done to the sequencer
            seq_item_port.item_done();
        end
    endtask: get_and_drive

    // Gets a packet and drive it into the DUT
    task cpu_driver_c::send_to_dut(cpu_transaction_c transaction);
        `uvm_info(get_type_name(), $sformatf("Input Data to Send:\n%s", transaction.sprint()),UVM_LOW);
        
        // wait time before start of the transaction
        repeat(transaction.wait_cycles) @(posedge vi_cpu_lv1_if.clk);

        vi_cpu_lv1_if.data_bus_cpu_lv1_reg  <= {DATA_WID_LV1{1'bz}};
        vi_cpu_lv1_if.addr_bus_cpu_lv1      <= {ADDR_WID_LV1{1'bz}};
        vi_cpu_lv1_if.cpu_rd                <= 1'b0;
        vi_cpu_lv1_if.cpu_wr                <= 1'b0;

        // check request type
        if (transaction.request_type == READ_REQ)
            drv_rd_trans(transaction.address,transaction.data);

        `uvm_info(get_type_name(), $sformatf("Ended Driving transaction"), UVM_LOW)

    endtask : send_to_dut

    // Task to drive a read transaction to the DUT
    task cpu_driver_c::drv_rd_trans(bit [ADDR_WID_LV1-1:0] addr, bit [DATA_WID_LV1-1:0] exp_data);

        @(posedge vi_cpu_lv1_if.clk);
        // Drive address and cpu_rd
        vi_cpu_lv1_if.cpu_rd            <= 1'b1;
        vi_cpu_lv1_if.addr_bus_cpu_lv1  <= addr;

        // start timer and wait for data_in_bus_cpu_lv1
        fork: timer_and_wait
            @(posedge vi_cpu_lv1_if.data_in_bus_cpu_lv1);
            begin: time_out_check
                repeat(`TIME_OUT_VAL) @(posedge vi_cpu_lv1_if.clk);
            end
        join_any: timer_and_wait

        // Release the address bus and cpu_rd. Other internal signals
        @(posedge vi_cpu_lv1_if.clk);
        vi_cpu_lv1_if.cpu_rd            <= 1'b0;
        vi_cpu_lv1_if.addr_bus_cpu_lv1  <= {ADDR_WID_LV1{1'bz}};
        disable fork;

        // wait till data_in_bus_cpu_lv1 goes low to indicate end of transaction
        // or for another clock if the transaction timed out
        @(negedge vi_cpu_lv1_if.data_in_bus_cpu_lv1 or posedge vi_cpu_lv1_if.clk);
        @(posedge vi_cpu_lv1_if.clk);

    endtask: drv_rd_trans
