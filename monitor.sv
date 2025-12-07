// Monitor
`include"Driver.sv"
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  virtual async_fifo_inf #(8,7) fifo;
  transaction tr;
  uvm_analysis_port#(transaction) mon_analysis_port;

  function new (string name, uvm_component parent = null);
    super.new(name, parent);
    mon_analysis_port = new("mon_analysis_port", this);
  endfunction

  virtual function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db #(virtual async_fifo_inf #(8,7)) :: get(this, "*", "fifo", fifo))
      `uvm_fatal("NO_IF", "async_fifo_inf interface not found");
  endfunction

  virtual task run_phase(uvm_phase phase);
    forever begin
      tr = transaction::type_id::create("tr");
      // Sample write signals at wclk
      @(posedge fifo.wclk);
      tr.winc = fifo.winc;
      tr.wdata = fifo.wdata;
      tr.wfull = fifo.wfull;
	        tr.whalf_full = fifo.whalf_full;
      tr.wthree_quarters_full = fifo.wthree_quarters_full;
      // Sample read signals at rclk
      @(posedge fifo.rclk);
      tr.rinc = fifo.rinc;
      tr.rdata = fifo.rdata;
      tr.rempty = fifo.rempty;
      mon_analysis_port.write(tr);
    end
  endtask
endclass
