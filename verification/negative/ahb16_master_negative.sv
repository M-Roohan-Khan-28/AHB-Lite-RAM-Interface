`timescale 1ns/1ps
module ahb16_master_negative;
  logic HCLK=0,HRESETn=0,HSEL=0,HREADY=1,HREADYOUT=1,HRESP=0,HWRITE=0;
  logic [7:0] HADDR=0;
  logic [1:0] HTRANS=0;
  logic [2:0] HSIZE=2;
  logic [31:0] HWDATA=0;
  int violations;
  ahb16_master_monitor #(.FATAL(0)) mon(.*);
  always #5 HCLK=~HCLK;
  task automatic reset_case();
    @(negedge HCLK);
    HRESETn=0;HSEL=0;HREADY=1;HWRITE=0;
    HADDR=0;HTRANS=0;HSIZE=2;HWDATA=0;
    repeat(2) @(posedge HCLK);
    @(negedge HCLK);HRESETn=1;
  endtask
  task automatic begin_wait(input bit wr);
    @(negedge HCLK);
    HSEL=1;HREADY=0;HWRITE=wr;
    HADDR=8'h0c;HTRANS=2;HSIZE=2;HWDATA=32'h12345678;
    @(posedge HCLK);#1;
    if(violations!==0) $fatal(1,"Unexpected violation before mutation");
  endtask
  initial begin
    reset_case();
    begin_wait(1);
    @(negedge HCLK);HADDR=8'h10;
    @(posedge HCLK);#1;
    if(violations!==1) $fatal(1,"Expected address instability detection, got %0d",violations);
    $display("AHB16_MASTER_NEGATIVE_CASE_PASS address");

    reset_case();
    begin_wait(1);
    @(negedge HCLK);HWDATA=32'h87654321;
    @(posedge HCLK);#1;
    if(violations!==1) $fatal(1,"Expected write-data instability detection, got %0d",violations);
    $display("AHB16_MASTER_NEGATIVE_CASE_PASS write_data");

    reset_case();
    begin_wait(0);
    @(negedge HCLK);HTRANS=3;
    @(posedge HCLK);#1;
    if(violations!==1) $fatal(1,"Expected HTRANS instability detection, got %0d",violations);
    $display("AHB16_MASTER_NEGATIVE_CASE_PASS transfer_control");

    reset_case();
    begin_wait(1);
    repeat(3) begin
      @(posedge HCLK);#1;
      if(violations!==0) $fatal(1,"Legal held wait flagged");
    end
    @(negedge HCLK);HREADY=1;
    @(posedge HCLK);#1;
    if(violations!==0) $fatal(1,"Legal wait release flagged");
    $display("AHB16_MASTER_NEGATIVE_PASS cases=3 legal=1");
    $finish;
  end
  initial begin #5000;$fatal(1,"AHB16 master-negative timeout");end
endmodule
