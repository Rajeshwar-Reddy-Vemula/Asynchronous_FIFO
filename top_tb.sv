// Top module
`include"test.sv"
`include"interface.sv"

  module top_tb;
  logic wclk, rclk;
  async_fifo_inf #(8,7) fifo(.wclk(wclk), .rclk(rclk));

  async_fifo #(8,7) DUT (
    .wclk(fifo.wclk), .wrst_n(fifo.wrst_n),
    .rclk(fifo.rclk), .rrst_n(fifo.rrst_n),
    .winc(fifo.winc), .wdata(fifo.wdata), .wfull(fifo.wfull),
    .rinc(fifo.rinc), .rdata(fifo.rdata), .rempty(fifo.rempty),
    .whalf_full(fifo.whalf_full), // <-- Connect these
    .wthree_quarters_full(fifo.wthree_quarters_full)
  );

  initial begin
    uvm_config_db#(virtual async_fifo_inf #(8,7))::set(null, "*", "fifo", fifo);
  end

  initial begin
    wclk = 0; rclk = 0;
  end
  always #4 wclk = ~wclk;
  always #8 rclk = ~rclk;

  initial begin
    run_test("test");
    // Wait for UVM to finish all phases, then finish simulation
    #100;
    $finish();
  end

  // Remove or comment out this block:
  // initial begin
  //   #20000;
  //   $finish();
  // end
endmodule