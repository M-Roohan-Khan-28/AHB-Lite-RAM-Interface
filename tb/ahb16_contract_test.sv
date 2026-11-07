`timescale 1ns/1ps
// Independent accepted-address/data-phase model for the bounded 16-word RAM.
module ahb16_contract_test;
  logic HCLK=0,HRESETn=0,HSEL=0,HWRITE=0,HREADY=1;
  logic [7:0] HADDR=0;
  logic [1:0] HTRANS=0;
  logic [2:0] HSIZE=3'b010;
  logic [31:0] HWDATA=0;
  wire [31:0] HRDATA;
  wire HREADYOUT,HRESP;
  ahb_lite_slave_ram dut(.*);
  always #5 HCLK=~HCLK;

  logic [31:0] ref_mem[0:15];
  bit pending, pwrite, perror;
  logic [3:0] pindex;
  int phase=0; // 0=normal, 1=first ERROR, 2=second ERROR
  int checks=0,accepted=0,retired=0,commits=0,errors=0,stalls=0;
  int unsigned rng=32'h28a81607;
  function automatic logic [31:0] next_word();
    rng ^= rng << 13; rng ^= rng >> 17; rng ^= rng << 5;
    return rng;
  endfunction

  // Model state advances from pre-edge pins. No DUT internal state is read.
  always @(posedge HCLK or negedge HRESETn) begin
    if(!HRESETn) begin
      for(int i=0;i<16;i++) ref_mem[i]=0;
      pending=0; pwrite=0; perror=0; pindex=0; phase=0;
    end else if(phase==1) phase=2;
    else if(HREADY) begin
      if(pending) begin
        retired++;
        if(pwrite && !perror) begin
          ref_mem[pindex]=HWDATA;
          commits++;
        end
      end
      pending=HSEL && HTRANS[1];
      pwrite=HWRITE;
      pindex=HADDR[5:2];
      perror=(HADDR[1:0]!=0 || HADDR>8'h3c || HSIZE!=3'b010);
      if(pending) begin
        accepted++;
        if(perror) begin errors++; phase=1; end
        else phase=0;
      end else phase=0;
    end else stalls++;
    #1;
    if(HREADYOUT !== (phase!=1) || HRESP !== (phase!=0) ||
       HRDATA !== ((pending && !pwrite && !perror) ? ref_mem[pindex] : 32'h0))
      $fatal(1,"AHB16_MISMATCH phase=%0d addr=%02h ready=%b expected readyout/resp/data=%b/%b/%08h observed=%b/%b/%08h accepted=%0d retired=%0d",
          phase,HADDR,HREADY,(phase!=1),(phase!=0),
          ((pending && !pwrite && !perror) ? ref_mem[pindex] : 32'h0),
          HREADYOUT,HRESP,HRDATA,accepted,retired);
    checks+=3;
  end

  task automatic step(input bit sel,input logic [1:0] trans,input bit wr,
      input logic [2:0] size,input logic [7:0] addr,
      input logic [31:0] data,input bit ready);
    @(negedge HCLK);
    HSEL=sel; HTRANS=trans; HWRITE=wr; HSIZE=size;
    HADDR=addr; HWDATA=data; HREADY=ready;
    @(posedge HCLK); #2;
  endtask
  task automatic idle_step(input logic [31:0] data,input bit ready);
    step(0,0,0,2,0,data,ready);
  endtask
  task automatic reset_all();
    @(negedge HCLK); HRESETn=0; HSEL=0; HTRANS=0; HREADY=1;
    repeat(2) @(posedge HCLK);
    @(negedge HCLK); HRESETn=1;
  endtask
  task automatic write_word(input int idx,input logic [31:0] data);
    step(1,2,1,2,idx*4,0,1);
    idle_step(data,1);
  endtask
  task automatic read_word(input int idx);
    step(1,2,0,2,idx*4,0,1);
    idle_step(0,1);
  endtask
  task automatic bad_address(input logic [7:0] addr,input logic [2:0] size);
    int start_accept;
    start_accept=accepted;
    step(1,2,1,size,addr,0,1); // invalid address is accepted
    if(phase!=1 || HRESP!==1 || HREADYOUT!==0)
      $fatal(1,"AHB16_ERROR_FIRST_MISSING addr=%02h size=%0d",addr,size);
    step(1,2,1,2,8'h00,32'hdeadbeef,0); // speculative address, cancelled
    if(phase!=2 || HRESP!==1 || HREADYOUT!==1 || accepted!=start_accept+1)
      $fatal(1,"AHB16_ERROR_SECOND_MISSING addr=%02h size=%0d",addr,size);
    idle_step(32'h11111111,1);
    if(accepted!=start_accept+1 || phase!=0)
      $fatal(1,"AHB16_ERROR_CANCEL_FAILED addr=%02h",addr);
    read_word(0); // recovery and no invalid write
  endtask

  initial begin
    reset_all();
    // All 16 words, distinct data; subsequent reads sample every index.
    for(int i=0;i<16;i++) write_word(i,next_word());
    for(int i=0;i<16;i++) read_word(i);
    for(int i=0;i<16;i++) write_word(i,next_word());
    for(int i=0;i<16;i++) read_word(i);

    // Full-rate W-W, W-R, R-W and R-R pairs, including SEQ and boundaries.
    step(1,2,1,2,8'h00,0,1);
    step(1,3,1,2,8'h3c,32'h12345678,1);
    step(1,2,0,2,8'h00,32'hcafebabe,1);
    step(1,3,0,2,8'h3c,0,1);
    step(1,2,1,2,8'h04,0,1);
    step(1,3,0,2,8'h04,32'h55aa77cc,1);
    idle_step(0,1);

    // Address and data phases held through external global-ready stalls.
    foreach(ref_mem[i]) begin
      if(i==0 || i==1 || i==2) begin
        int n;
        n=(i==0)?1:((i==1)?2:5);
        step(1,2,1,2,i*4,0,1);
        repeat(n) step(1,2,0,2,8'h3c,32'h90000000+i,0);
        step(1,2,0,2,8'h3c,32'h90000000+i,1);
        idle_step(0,1);
        read_word(i);
      end
    end

    // HSEL/HTRANS guards; all eight size codes and address error classes.
    for(int t=0;t<4;t++) step(1,t[1:0],1,2,8'h08,32'hffffffff,1);
    step(0,2,1,2,8'h08,32'hffffffff,1);
    idle_step(0,1);
    for(int sz=0;sz<8;sz++) if(sz!=2) bad_address(8'h0c,sz[2:0]);
    bad_address(8'h02,2);
    bad_address(8'h40,2);
    bad_address(8'hfc,2);

    // Reset cancels pending valid write and both ERROR phases.
    step(1,2,1,2,8'h00,0,1);
    reset_all();
    for(int i=0;i<16;i++) read_word(i);
    step(1,2,1,3,8'h00,0,1); // first ERROR phase
    reset_all();
    read_word(0);
    step(1,2,1,3,8'h00,0,1);
    idle_step(0,0); // second ERROR phase
    reset_all();
    read_word(0);

    if(accepted<100 || commits<40 || errors!=12 || stalls<8)
      $fatal(1,"AHB16_COUNT_MISMATCH accepted=%0d commits=%0d errors=%0d stalls=%0d",
          accepted,commits,errors,stalls);
    $display("AHB16_CONTRACT_PASS checks=%0d accepted=%0d retired=%0d commits=%0d errors=%0d stalls=%0d seed=0x28A81607",
       checks,accepted,retired,commits,errors,stalls);
    $finish;
  end
  initial begin #1000000; $fatal(1,"AHB16_TIMEOUT"); end
endmodule
