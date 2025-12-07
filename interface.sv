// Interface for async_fifo with assertions
import uvm_pkg::*;
`include "uvm_macros.svh"

interface async_fifo_inf #(parameter DSIZE=8, ASIZE=7) (input logic wclk, rclk);
  logic wrst_n, rrst_n;
  logic winc, rinc;
  logic [DSIZE-1:0] wdata;
  logic [DSIZE-1:0] rdata;
  logic wfull, rempty;
  logic whalf_full, wthree_quarters_full; 

  // Assertion: No write when FIFO is full
  assert_no_write_when_full: assert property (@(posedge wclk) disable iff (!wrst_n)
    !(winc && wfull))
    else begin
	$error("Attempted write when FIFO is full!");
end
  // Assertion: No read when FIFO is empty
  assert_no_read_when_empty: assert property (@(posedge rclk) disable iff (!rrst_n)
    !(rinc && rempty))
    else begin $error("Attempted read when FIFO is empty!");
	end
endinterface