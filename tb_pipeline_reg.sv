module tb_pipeline_reg;

    parameter WIDTH = 32;
    logic clk;
    logic rst_n;

    logic in_valid;
    logic in_ready;
    logic [WIDTH-1:0] in_data;

    logic out_valid;
    logic out_ready;
    logic [WIDTH-1:0] out_data;

   
    // VCD dump for EPWave 
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pipeline_reg);
    end

    
    // DUT
    pipeline_reg #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .in_valid  (in_valid),
        .in_ready  (in_ready),
        .in_data   (in_data),
        .out_valid (out_valid),
        .out_ready (out_ready),
        .out_data  (out_data)
    );

    
    // Clock generation
    always #5 clk = ~clk;

   
    // Stimulus
    initial begin
        clk = 0;
        rst_n = 0;
        in_valid = 0;
        in_data  = 0;
        out_ready = 0;

        // Apply reset
        #20;
        rst_n = 1;

        
        // Normal transfer
        @(posedge clk);
        in_valid  = 1;
        in_data   = 32'hA5A5A5A5;   // neutral test pattern
        out_ready = 1;

        @(posedge clk);
        in_valid = 0;

        
        // Backpressure test
        @(posedge clk);
        in_valid  = 1;
        in_data   = 32'h12345678;   
        out_ready = 0;             

        repeat (3) @(posedge clk);

        // Release backpressure
        out_ready = 1;
        in_valid  = 0;

        // Finish simulation
        #50;
        $finish;
    end

endmodule
