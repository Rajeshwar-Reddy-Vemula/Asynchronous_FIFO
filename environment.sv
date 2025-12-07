// Environment
`include"Scoreboard.sv"

class environment extends uvm_env;
  `uvm_component_utils(environment)
  agent agt;
  scoreboard scr;
  fifo_coverage cov;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt = agent::type_id::create("agt",this);
    scr = scoreboard::type_id::create("scr",this);
    cov = fifo_coverage::type_id::create("cov",this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agt.mon.mon_analysis_port.connect(scr.scr_analysis_imp);
    agt.mon.mon_analysis_port.connect(cov.analysis_export);
  endfunction
endclass