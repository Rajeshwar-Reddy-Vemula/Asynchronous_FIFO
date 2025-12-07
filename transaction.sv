// Transaction (sequence item) with constraints
`include "uvm_macros.svh"
import uvm_pkg::*;
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
  rand bit winc, rinc;
  rand logic [7:0] wdata;
  logic [7:0] rdata;
  logic wfull, rempty;
  logic whalf_full, wthree_quarters_full;

  // Constraint: Only one of winc or rinc can be 1 at a time
  constraint one_op_at_a_time { !(winc && rinc); }

  // Constraint: wdata only matters for writes
  constraint wdata_valid_if_write { if (!winc) wdata == 8'b0; }

  // New constraint for wdata to ensure all bins are hit
  constraint wdata_dist { wdata dist { [0:63]:/25, [64:127]:/25, [128:191]:/25, [192:255]:/25 }; }

  function new (string name = "transaction");
    super.new(name);
  endfunction
endclass
