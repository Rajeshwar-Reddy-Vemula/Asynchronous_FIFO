module async_fifo #(parameter DSIZE = 8, ASIZE = 7) (
  input  logic wclk, wrst_n, rclk, rrst_n,
  input  logic winc, rinc,
  input  logic [DSIZE-1:0] wdata,
  output logic [DSIZE-1:0] rdata,
  output logic wfull, rempty,
  output logic whalf_full, wthree_quarters_full // <--- ADDED
);

  logic [ASIZE-1:0] waddr, raddr;
  logic [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;

  logic [DSIZE-1:0] mem [0:(1<<ASIZE)-1];

  always_ff @(posedge wclk)
    if (winc && !wfull)
      mem[waddr] <= wdata;

  assign rdata = mem[raddr];

  logic [ASIZE:0] wbin, wbinnext, wgraynext;
  logic wfull_val;

  assign waddr = wbin[ASIZE-1:0];
  assign wbinnext = wbin + (winc & ~wfull);
  assign wgraynext = (wbinnext >> 1) ^ wbinnext;
  assign wfull_val = (wgraynext == {~wq2_rptr[ASIZE:ASIZE-1], wq2_rptr[ASIZE-2:0]});

  always_ff @(posedge wclk or negedge wrst_n)
    if (!wrst_n) {wbin, wptr} <= 0;
    else         {wbin, wptr} <= {wbinnext, wgraynext};

  always_ff @(posedge wclk or negedge wrst_n)
    if (!wrst_n) wfull <= 0;                   //should be zero, when it's 1 its a bug
    else         wfull <= wfull_val;

  logic [ASIZE:0] rbin, rbinnext, rgraynext;
  logic rempty_val;

  assign raddr = rbin[ASIZE-1:0];
  assign rbinnext = rbin + (rinc & ~rempty);
  assign rgraynext = (rbinnext >> 1) ^ rbinnext;
  assign rempty_val = (rgraynext == rq2_wptr);

  always_ff @(posedge rclk or negedge rrst_n)
    if (!rrst_n) {rbin, rptr} <= 0;
    else         {rbin, rptr} <= {rbinnext, rgraynext};

  always_ff @(posedge rclk or negedge rrst_n)
    if (!rrst_n) rempty <= 1;
    else         rempty <= rempty_val;

  logic [ASIZE:0] wq1_rptr;
  always_ff @(posedge wclk or negedge wrst_n)
    if (!wrst_n) {wq2_rptr, wq1_rptr} <= 0;
    else         {wq2_rptr, wq1_rptr} <= {wq1_rptr, rptr};

  logic [ASIZE:0] rq1_wptr;
  always_ff @(posedge rclk or negedge rrst_n)
    if (!rrst_n) {rq2_wptr, rq1_wptr} <= 0;
    else         {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr};

  // --------- ADDED FOR HALF AND 3/4 FULL FLAGS ---------
  logic [ASIZE:0] w_occupancy;
  assign w_occupancy = wbin - wq2_rptr;

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      whalf_full <= 0;
      wthree_quarters_full <= 0;
    end else begin
      whalf_full           <= (w_occupancy >= ((1 << ASIZE) >> 1)); // >= half
      wthree_quarters_full <= (w_occupancy >= ((1 << ASIZE) - ((1 << ASIZE) >> 2))); // >= 3/4
    end
  end
  // ------------------------------------------------------

endmodule