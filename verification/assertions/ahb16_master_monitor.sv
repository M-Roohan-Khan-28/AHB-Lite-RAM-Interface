`timescale 1ns/1ps
module ahb16_master_monitor #(parameter bit FATAL=1) (
  input logic HCLK,HRESETn,HSEL,HREADY,HREADYOUT,HRESP,HWRITE,
  input logic [7:0] HADDR,
  input logic [1:0] HTRANS,
  input logic [2:0] HSIZE,
  input logic [31:0] HWDATA,
  output int violations
);
  bit stalled;
  logic held_sel,held_write;
  logic [7:0] held_addr;
  logic [1:0] held_trans;
  logic [2:0] held_size;
  logic [31:0] held_wdata;
  task automatic bad(input string reason);
    violations=violations+1;
    $display("AHB16_MASTER_VIOLATION %s",reason);
    if(FATAL) $fatal(1,"AHB16 master monitor: %s",reason);
  endtask
  always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
      stalled=0; violations=0;
      held_sel=0;held_write=0;held_addr=0;held_trans=0;held_size=0;held_wdata=0;
    end else begin
      if(stalled) begin
        if({HSEL,HADDR,HTRANS,HWRITE,HSIZE} !==
           {held_sel,held_addr,held_trans,held_write,held_size})
          bad("address/control changed during global HREADY wait");
        if(HWDATA !== held_wdata)
          bad("write data changed during global HREADY wait");
      end
      // A first-cycle ERROR wait permits cancelling the speculative address.
      stalled=!HREADY && !(HRESP && !HREADYOUT);
      if(!HREADY) begin
        held_sel=HSEL;held_addr=HADDR;held_trans=HTRANS;
        held_write=HWRITE;held_size=HSIZE;held_wdata=HWDATA;
      end
    end
  end
endmodule
