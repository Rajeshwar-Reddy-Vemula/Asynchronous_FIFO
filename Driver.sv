// Driver
`include"sequence_item.sv"
class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
  virtual async_fifo_inf #(8,7) fifo;
  transaction tr;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual async_fifo_inf #(8,7))::get(this, "*", "fifo", fifo))
      `uvm_fatal("NO_IF", "async_fifo_inf interface not found");
  endfunction

  virtual task run_phase(uvm_phase phase);
    initialize();
    forever begin
      seq_item_port.get_next_item(tr);
      if (tr.winc)
        write(tr);
      else if (tr.rinc)
        read(tr);
      else
        @(negedge fifo.wclk); // Idle cycle
      seq_item_port.item_done();
    end
  endtask

  virtual task initialize();
    fifo.wrst_n <= 0;
    fifo.rrst_n <= 0;
    fifo.winc   <= 0;
    fifo.rinc   <= 0;
    fifo.wdata  <= '0;
    repeat (2) @(negedge fifo.wclk);
    repeat (2) @(negedge fifo.rclk);
    fifo.wrst_n <= 1;
    fifo.rrst_n <= 1;
	repeat (2) @(negedge fifo.wclk);
    repeat (2) @(negedge fifo.rclk);
	fifo.wrst_n <= 0;
    fifo.rrst_n <= 0;
	repeat (2) @(negedge fifo.wclk);
    repeat (2) @(negedge fifo.rclk);
	fifo.wrst_n <= 1;
    fifo.rrst_n <= 1;
  endtask

  virtual task write(transaction tr);
    @(negedge fifo.wclk);
    fifo.winc <= 1;
    fifo.wdata <= tr.wdata;
    @(negedge fifo.wclk);
    fifo.winc <= 0;
    fifo.wdata <= '0;
  endtask

  virtual task read(transaction tr);
    @(negedge fifo.rclk);
    fifo.rinc <= 1;
    @(negedge fifo.rclk);
    fifo.rinc <= 0;
  endtask
endclass