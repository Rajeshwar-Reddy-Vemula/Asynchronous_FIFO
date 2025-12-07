// FUNCTIONAL COVERAGE COLLECTOR
`include"transaction.sv"
class fifo_coverage extends uvm_subscriber #(transaction);
  `uvm_component_utils(fifo_coverage)

  transaction tr;
  real cov;

  covergroup fifo_cg;
    option.per_instance = 1;
    winc_cp   : coverpoint tr.winc;
    rinc_cp   : coverpoint tr.rinc;
    wfull_cp  : coverpoint tr.wfull;
    rempty_cp : coverpoint tr.rempty;
    wdata_cp  : coverpoint tr.wdata {
      bins low  = {[0:63]};
      bins mid  = {[64:127]};
      bins high = {[128:191]};
      bins max  = {[192:255]};
    }
    rdata_cp  : coverpoint tr.rdata {
      bins low  = {[0:63]};
      bins mid  = {[64:127]};
      bins high = {[128:191]};
      bins max  = {[192:255]};
    }
    wfull_cross        : cross winc_cp, wfull_cp;
    rempty_cross       : cross rinc_cp, rempty_cp;
    wdata_full_cross   : cross wdata_cp, wfull_cp;
    rdata_empty_cross  : cross rdata_cp, rempty_cp;
  endgroup

  function new(string name, uvm_component parent);
    super.new(name, parent);
    fifo_cg = new();
  endfunction

  virtual function void write(transaction t);
    this.tr = t;
    fifo_cg.sample();
  endfunction

  virtual function void extract_phase(uvm_phase phase);
    cov = fifo_cg.get_coverage();
  endfunction

  virtual function void report_phase(uvm_phase phase);
    `uvm_info(get_full_name(), $sformatf("Functional coverage: %0.2f%%", cov), UVM_NONE)
    $display("================================================");
    $display("FUNCTIONAL COVERAGE: %0.2f%%", cov);
    $display("================================================");
  endfunction
endclass
