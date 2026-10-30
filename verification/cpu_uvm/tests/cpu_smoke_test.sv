class cpu_smoke_test extends uvm_test;
    `uvm_component_utils(cpu_smoke_test)

    function new(string name = "cpu_smoke_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("CPU_SMOKE", "CPU UVM environment is running", UVM_LOW)
        #10ns;
        phase.drop_objection(this);
    endtask
endclass
