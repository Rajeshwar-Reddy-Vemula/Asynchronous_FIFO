// Assertions for the Asynchronous FIFO
// Need to write the BIND FILE
// Includes some Invariants, CDC data integrity, pointers and flags assertions

longint wcnt, rcnt;
always @(posedge wclk) if (write) wcnt++;
always @(posedge rclk) if (read) rcnt++;

property p_data_integrity;
  longint cnt;
  logic [N-1:0] data;
  @(posedge wclk) disable iff(!rst_n)
  (write, cnt = wcnt, data = wdata) |=> @(posedge rclk) (read && (rcnt===cnt))[->1] ##0 (rdata === data);         // using local variables and checking the FIFO order, this doesnt have to be a circular buffer like teh RTL
endproperty


property p_no_data_creation
@(posedge rclk) disable iff (!rst_n)
  gray2bin(wptr_sync) >= gray2bin(rptr);                        // use the already-synchronised write pointer visible in read domain, WRITE THE gray2bin() function or use the synchronoised binary pointers from RTL
endproperty


property p_gray_code_write
    @(posedge wclk) disable iff(!rst_n)
  write |-> $onehot( wptr ^ $past(wptr))                  
endproperty

property p_gray_code_read
  @(posedge rclk) disable iff(!rst_n)
  read |-> $onehot( rptr ^ $past(rptr))
endproperty


property p_full_empty_invariant
  disable iff(!rst_n)
  !(full && empty)
endproperty


property p_overflow
@(posedge wclk) disable iff (!rst_n)                             // FIFO never overflows — can't write when full
  full |-> !write;
endproperty


property p_underflow
@(posedge rclk) disable iff (!rst_n)                                  // FIFO never underflows — can't read when empty  
  empty |-> !read;
endproperty


// Fill to full
@(posedge wclk) cover property (disable iff (!rst_n) $rose(full));

// Drain to empty
@(posedge rclk) cover property (disable iff (!rst_n) $rose(empty));

// Simultaneous read and write
@(posedge wclk) cover property (disable iff (!rst_n) write && read);

// Write up to full then read back to empty
@(posedge wclk) cover property (disable iff (!rst_n) 
  full ##[1:$] empty);
