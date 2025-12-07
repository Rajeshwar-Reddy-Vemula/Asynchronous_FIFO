`include"sequencer.sv"
class comprehensive_seq extends uvm_sequence#(transaction);
  `uvm_object_utils(comprehensive_seq)
  function new(string name = "comprehensive_seq");
    super.new(name);
  endfunction

  virtual task body();
    transaction tr;
    int fifo_depth = 1 << 7; // 128 for ASIZE=7

    // Phase 1: Write until full, covering wdata bins
    for (int i = 0; i < fifo_depth; i++) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { winc == 1; rinc == 0; }) `uvm_fatal("RAND_FAIL", "Randomization failed for write transaction");
      finish_item(tr);
    end

    // Phase 2: Attempt write when full (should trigger assertion)
    tr = transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with { winc == 1; rinc == 0; }) `uvm_fatal("RAND_FAIL", "Randomization failed for write when full");
    finish_item(tr);

    // Phase 3: Idle with full FIFO
    tr = transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with { winc == 0; rinc == 0; }) `uvm_fatal("RAND_FAIL", "Randomization failed for idle transaction");
    finish_item(tr);

    // Phase 4: Read until empty, covering rdata bins
    for (int i = 0; i < fifo_depth; i++) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      if (!tr.randomize() with { winc == 0; rinc == 1; }) `uvm_fatal("RAND_FAIL", "Randomization failed for read transaction");
      finish_item(tr);
    end

    // Phase 5: Attempt read when empty (should trigger assertion)
    tr = transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with { winc == 0; rinc == 1; }) `uvm_fatal("RAND_FAIL", "Randomization failed for read when empty");
    finish_item(tr);

    // Phase 6: Idle with empty FIFO
    tr = transaction::type_id::create("tr");
    start_item(tr);
    if (!tr.randomize() with { winc == 0; rinc == 0; }) `uvm_fatal("RAND_FAIL", "Randomization failed for idle transaction");
    finish_item(tr);

    // Phase 7: Gray code wrap-around: fill, empty, fill, empty
    repeat (2) begin
      for (int i = 0; i < fifo_depth; i++) begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        if (!tr.randomize() with { winc == 1; rinc == 0; }) `uvm_fatal("RAND_FAIL", "Randomization failed for wrap write");
        finish_item(tr);
      end
      for (int i = 0; i < fifo_depth; i++) begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        if (!tr.randomize() with { winc == 0; rinc == 1; }) `uvm_fatal("RAND_FAIL", "Randomization failed for wrap read");
        finish_item(tr);
      end
    end


    // Phase 8: Random phase to hit toggle/branch/condition
    for (int i = 0; i < 200; i++) begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize());
      finish_item(tr);
    end
  endtask
endclass
