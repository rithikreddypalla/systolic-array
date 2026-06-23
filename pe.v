// ------------------------------------------------------------
// pe.v
// Processing Element
// ------------------------------------------------------------
module pe(
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  a_in,
    input  wire [7:0]  b_in,
    input  wire        a_new_data_in,
    input  wire        b_new_data_in,
    output wire [31:0] c,
    output reg  [7:0]  a_out,
    output reg  [7:0]  b_out,
    output reg         a_new_data_out,
    output reg         b_new_data_out
);
    mac mac_inst(
        .clk(clk),
        .rst(rst),
        .a(a_in),
        .b(b_in),
        .result(c)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out          <= 8'b0;
            b_out          <= 8'b0;
            a_new_data_out <= 1'b0;
            b_new_data_out <= 1'b0;
        end else begin
            a_out          <= a_in;
            b_out          <= b_in;
            a_new_data_out <= a_new_data_in;
            b_new_data_out <= b_new_data_in;
        end
    end

endmodule
