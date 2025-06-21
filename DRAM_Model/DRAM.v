`timescale 1ns / 1ps


module DRAM( DATA,                                                  // 16-Bit data as input and output 
             MA,                                                    // Memory Address 10-Bits
             RAS_N,                                                 // Row Address Strobe 
             CAS_N,                                                 // Column Address Strobe
             LWE_N,                                                 // Lower Write Enable
             UWE_N,                                                 // Upper Write Enable
             OE_N                                                   // Output Enable
            );
    
    inout [15:0]DATA;
    input [9:0]MA;
    input RAS_N;
    input CAS_N;
    input LWE_N;
    input UWE_N;
    input OE_N;
    
    reg [15:0] memblk [0:262143];                                   // Memory Block 256K x 16
    reg [9:0] rowadd;                                               // Row add upper 10 bits of MA
    reg [7:0] coladd;                                               // Col add Lower 8 bits of MA
    reg [15:0] rd_data;                                             // To read data and give the output
    reg [15:0] temp_reg;                                            // To store the partial write
    
    reg hidden_ref;
    reg last_lwe;
    reg last_uwe;
    reg cas_bef_ras_ref;
    reg end_cas_bef_ras_ref;
    reg last_cas;
    reg read;
    reg rmw;
    reg output_disable_check;
    
    integer page_mode;
    
    assign #5 DATA =  (OE_N === 1'b0 && CAS_N === 1'b0) ? rd_data : 16'bz;
    
    parameter infile = "Data_DRAM.txt";
    
    initial begin
        $readmemh(infile,memblk);
    end
    
    always@(RAS_N) begin
        
        if (RAS_N == 1'b0) begin
            if (CAS_N == 1'b1)
                rowadd = MA;
            else 
                hidden_ref = 1'b1;
        end
        else
            hidden_ref = 1'b0;
    end
    
    always@(CAS_N) begin
        #1 last_cas = CAS_N;
    end
    
    always@(CAS_N or LWE_N or UWE_N) begin

        if (last_cas == 1'b1)
            coladd = MA[7:0];
        
        if (RAS_N == 1'b0 && CAS_N == 1'b0) begin

            if (LWE_N !== 1'b0 && UWE_N !== 1'b0) begin  // Read
                rd_data = memblk[{rowadd,coladd}];
                $display("READ | Address : %b | Data : %b", {rowadd,coladd}, rd_data);
            end

            if (LWE_N == 1'b0 && UWE_N == 1'b0) begin    // Write Full
                memblk[{rowadd,coladd}] = DATA;
            end

            if (LWE_N == 1'b0 && UWE_N == 1'b1) begin    // Partial Lower
                temp_reg = memblk[{rowadd,coladd}];
                temp_reg[7:0] = DATA[7:0];
                memblk[{rowadd,coladd}] = temp_reg;
            end

            if (LWE_N == 1'b1 && UWE_N == 1'b0) begin    // Partial Upper
                temp_reg = memblk[{rowadd,coladd}];
                temp_reg[15:8] = DATA[15:8];
                memblk[{rowadd,coladd}] = temp_reg;
            end
    end
end

    
    // REFRESH
    always@(CAS_N or RAS_N) begin
        
        // 1. Detect CAS-before-RAS refresh start
        if (CAS_N == 1'b0 && last_cas == 1'b1 && RAS_N == 1'b1) begin
            cas_bef_ras_ref = 1'b1;
        end
        
        // 2. Detect refresh cycle end (both CAS_N and RAS_N high)
        if (CAS_N == 1'b1 && RAS_N == 1'b1 && cas_bef_ras_ref == 1'b1) begin
            cas_bef_ras_ref = 1'b0;
            end_cas_bef_ras_ref = 1'b1;
        end
        
        // 3. Reset end_cas_bef_ras_ref when next cycle starts
        if (CAS_N == 1'b0 && RAS_N == 1'b0 && end_cas_bef_ras_ref == 1'b1) begin
            end_cas_bef_ras_ref = 1'b0;
        end
    end
endmodule
