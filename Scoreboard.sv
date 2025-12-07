// Scoreboard (simple printout)
`include"agent.sv"
class scoreboard extends uvm_component;
  `uvm_component_utils(scoreboard)
  uvm_analysis_imp#(transaction, scoreboard) scr_analysis_imp;

  function new(string name, uvm_component parent = null);
    super.new(name, parent);
    scr_analysis_imp = new("scr_analysis_imp", this);
  endfunction
  virtual function void write(transaction tr);
    $display("SCOREBOARD: winc=%0d rinc=%0d wdata=0x%0h rdata=0x%0h wfull=%0d rempty=%0d whalf_full=%0d wthree_quarters_full=%0d",
      tr.winc, tr.rinc, tr.wdata, tr.rdata, tr.wfull, tr.rempty, tr.whalf_full, tr.wthree_quarters_full);
  endfunction
endclass
