`timescale 1ns / 1ps


module DRAM_tb();
    
    // Test bench Signals 
    reg CAS_N, RAS_N, LWE_N, UWE_N, OE_N;
    wire [15:0] DATA;
    reg [9:0] MA;
    
    //Bidirectional Signals
    reg [15:0] data_drive;
    assign DATA = (OE_N == 1'b0) ? 16'bz : data_drive;
    
    
    // DRAM Initialisation
    DRAM dut( .DATA(DATA),
              .CAS_N(CAS_N),
              .RAS_N(RAS_N),
              .LWE_N(LWE_N),
              .UWE_N(UWE_N),
              .OE_N(OE_N),
              .MA(MA)
            );
            
            
    // TASK to perform full write 
    task full_write(input [9:0] addr, input [15:0] wdata);
    begin
        $display("...FULL WRITE...");
        MA = addr;
        data_drive = wdata;
        
        CAS_N = 1'b1;
        RAS_N = 1'b1;
        LWE_N = 1'b1;
        UWE_N = 1'b1;
        OE_N = 1'b1;  
        
        #5 RAS_N = 1'b0;
        #5 CAS_N = 1'b0; LWE_N = 1'b0; UWE_N = 1'b0;
        
        #10 CAS_N = 1'b1;
        #5 RAS_N = 1'b1;
        #5 LWE_N = 1'b1; UWE_N = 1'b1;
                
    end  
    endtask
    
    
    // TASK to perform full read
    task full_read(input [9:0] addr);
    begin
        $display("...FULL READ...");
        MA = addr;
        
        CAS_N = 1'b1;
        RAS_N = 1'b1;
        LWE_N = 1'b1;
        UWE_N = 1'b1;
        OE_N = 1'b1;
        
        #5 RAS_N = 1'b0;
        #5 CAS_N = 1'b0; OE_N = 1'b0;
        
        #10 $display("Read DATA from Address - %b - %h", addr, DATA);
        #10 CAS_N = 1'b1; 
        #5 RAS_N  = 1'b1;
        #5 OE_N = 1'b1;
    end
    endtask
    
    
    // TASK to perform partial lower write 
    task partial_lower_write(input [9:0] addr, input [15:0] wdata);
    begin
        $display("...PARTIAL LOWER WRITE...");
        MA = addr;
        data_drive = {8'b0, wdata[7:0]};
        
        CAS_N = 1'b1;
        RAS_N = 1'b1;
        LWE_N = 1'b1;
        UWE_N = 1'b1;
        OE_N = 1'b1;
        
        #5 RAS_N = 1'b0;
        #5 CAS_N = 1'b0; LWE_N = 1'b0; UWE_N = 1'b1;
        
        #10 CAS_N = 1'b1;
        #5 RAS_N = 1'b1; LWE_N = 1'b1; UWE_N = 1'b1;
        
    end
    endtask
    
    
    // TASK to perform partial upper write
    task partial_upper_write(input [9:0] addr, input [15:0] wdata);
    begin
        $display("...PARTIAL UPPER WRITE...");
        MA = addr;
        data_drive = {wdata[15:8], 8'b0};
        
        CAS_N = 1'b1;
        RAS_N = 1'b1;
        LWE_N = 1'b1;
        UWE_N = 1'b1;
        OE_N = 1'b1;
        
        #5 RAS_N = 1'b0;
        #5 CAS_N = 1'b0; LWE_N = 1'b1; UWE_N = 1'b0;
        
        #10 CAS_N = 1'b1;
        #5 RAS_N = 1'b1; LWE_N = 1'b1; UWE_N = 1'b1;
    end
    endtask
    
    
    // TASK to perform cas before ras refresh
    task cas_before_ras_refresh;
    begin
        $display("...CAS-BEFORE-RAS-REFRESH...");
        CAS_N = 1'b1;
        RAS_N = 1'b1;
        
        #5 CAS_N = 1'b0;
        #5 RAS_N = 1'b0;
        
        #10 CAS_N = 1'b1;
        #5 RAS_N = 1'b1;
    end
    endtask
    
    
    initial begin
    
        RAS_N = 1'b1; CAS_N = 1'b1; LWE_N = 1'b1; UWE_N = 1'b1; OE_N = 1'b1;
        data_drive = 16'hzzzz;
        MA = 10'b0;
        #20;

        // Perform test operations
        full_write(10'b0000000001, 16'hA5A5);
        full_read(10'b0000000001);
        
        partial_lower_write(10'b0000000001, 16'h895A);
        full_read(10'b0000000001);

        partial_upper_write(10'b0000000001, 16'h65C3);
        full_read(10'b0000000001);
        
        // Perform refresh cycle
        cas_before_ras_refresh;
        
        #20;
        $display("Simulation complete");
        $finish;
    end
    
endmodule
