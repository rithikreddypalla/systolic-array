// ------------------------------------------------------------
// sysarray.v
// 4x4 systolic array
// ------------------------------------------------------------
module sysarray(
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  a_in[0:3],
    input  wire [7:0]  b_in[0:3],
    input  wire        a_new_data[0:3],
    input  wire        b_new_data[0:3],
    output wire [31:0] c_out[0:3][0:3],
    output wire        a_nd_wire[0:3][0:3],
    output wire        b_nd_wire[0:3][0:3]
);
    wire [7:0]  a_wire [0:3][0:3];
    wire [7:0]  b_wire [0:3][0:3];
    wire [31:0] c_wire [0:3][0:3];

    genvar r, c;
    generate
        for (r = 0; r < 4; r = r + 1) begin : row
            for (c = 0; c < 4; c = c + 1) begin : col
                pe pe_inst (
                    .clk            (clk),
                    .rst            (rst),
                    .a_in           (c == 0 ? a_in[r]        : a_wire[r][c-1]),
                    .b_in           (r == 0 ? b_in[c]        : b_wire[r-1][c]),
                    .a_new_data_in  (c == 0 ? a_new_data[r]  : a_nd_wire[r][c-1]),
                    .b_new_data_in  (r == 0 ? b_new_data[c]  : b_nd_wire[r-1][c]),
                    .a_out          (a_wire[r][c]),
                    .b_out          (b_wire[r][c]),
                    .a_new_data_out (a_nd_wire[r][c]),
                    .b_new_data_out (b_nd_wire[r][c]),
                    .c              (c_wire[r][c])
                );
            end
        end
    endgenerate

    genvar rr, cc;
    generate
        for (rr = 0; rr < 4; rr = rr + 1) begin : cbuf_row
            for (cc = 0; cc < 4; cc = cc + 1) begin : cbuf_col
                reg [31:0] latch;
                always @(posedge clk or posedge rst) begin
                    if (rst)                   latch <= 32'b0;
                    else if (a_nd_wire[rr][cc]) latch <= c_wire[rr][cc];
                end
                assign c_out[rr][cc] = latch;
            end
        end
    endgenerate

endmodule
