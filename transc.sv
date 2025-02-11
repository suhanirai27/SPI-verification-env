class transaction;
  bit newd;                   // Flag for new transaction
  rand bit [11:0] din;        // Random 12-bit data input
  bit [11:0] dout;            // 12-bit data output
  constraint din_less_than_150 { din>100; din<150; }    // Adding a constraint to streamline and control input values
  function transaction copy();
    copy = new();             // Create a copy of the transaction
    copy.newd = this.newd;    // Copy the newd flag
    copy.din  = this.din;     // Copy the data input
    copy.dout = this.dout;    // Copy the data output
  endfunction
endclass
