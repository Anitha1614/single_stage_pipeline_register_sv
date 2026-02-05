module pipeline_reg #(
    parameter WIDTH = 32
)(
    input  logic             clk,
    input  logic             rst_n,

    // Input interface
    input  logic             in_valid,
    output logic             in_ready,
    input  logic [WIDTH-1:0] in_data,

    // Output interface
    output logic             out_valid,
    input  logic             out_ready,
    output logic [WIDTH-1:0] out_data
);

    // Internal storage
    logic [WIDTH-1:0] data_reg;
    logic             valid_reg;

    // Ready logic:
    // We can accept new data if:
    //  - register is empty
    //  - OR downstream is ready to consume current data
    assign in_ready = ~valid_reg || (out_ready);

    // Output assignments
    assign out_valid = valid_reg;
    assign out_data  = data_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_reg <= 1'b0;
            data_reg  <= '0;
        end
        else begin
            // Load new data when handshake occurs
            if (in_valid && in_ready) begin
                data_reg  <= in_data;
                valid_reg <= 1'b1;
            end
            // Clear valid when data is accepted by downstream
            else if (out_ready && valid_reg) begin
                valid_reg <= 1'b0;
            end
        end
    end

endmodule
