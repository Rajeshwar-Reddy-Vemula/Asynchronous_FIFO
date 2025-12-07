// fifo_uvm_logger.sv
class fifo_uvm_logger;
  integer logfile;

  function new(string logfile_name = "fifo_uvm_log.txt");
    logfile = $fopen(logfile_name, "w");
    if (logfile == 0) begin
      $display("LOGGER ERROR: Could not open log file %s for writing", logfile_name);
    end else begin
      $fdisplay(logfile, "+===============================================================+");
      $fdisplay(logfile, "|                 FIFO UVM Testbench Log Started                |");
      $fdisplay(logfile, "+===============================================================+");
    end
  endfunction

  // Helper to get a formatted date-time string (simulator-dependent)
  virtual function string get_time_str();
    string time_str;
    $sformat(time_str, "%0t", $time); // Replace with real date-time if supported
    return time_str;
  endfunction

  virtual function string compose_message(
    string severity,
    string id,
    string message,
    string filename,
    int line
  );
    string msg, time_str;
    time_str = get_time_str();
    // Box-style formatting
    msg = { 
      "+---------------------------------------------------------------+\n",
      $sformatf("| [%s] %s | ID: %s\n", severity, time_str, id),
      $sformatf("| Message: %s\n", message),
      $sformatf("| File: %s, Line: %0d\n", filename, line),
      "+---------------------------------------------------------------+\n"
    };
    return msg;
  endfunction

  function void log_message(
    string severity,
    string id,
    string message,
    string filename,
    int line,
    bit display = 1,
    bit log_to_file = 1
  );
    string composed_msg;
    composed_msg = compose_message(severity, id, message, filename, line);
    if (display) $write(composed_msg);
    if (log_to_file && logfile != 0) $fwrite(logfile, "%s", composed_msg);
  endfunction

  function void start_of_simulation_phase(string phase_name);
    log_message("INFO", "SIM_PHASE", 
      $sformatf("Start of %s phase", phase_name), 
      `__FILE__, `__LINE__);
  endfunction

  function void finalize();
    if (logfile != 0) begin
      $fdisplay(logfile, "+===============================================================+");
      $fdisplay(logfile, "|                  FIFO UVM Testbench Log Ended                 |");
      $fdisplay(logfile, "+===============================================================+");
      $fclose(logfile);
    end
  endfunction
endclass
