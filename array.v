// ============================================================
// Systolic Array (4×4)
// a_new_data travels horizontally with A (left→right)
// b_new_data travels vertically   with B (top→down)
// c_buffer latches each PE's result when its a_new_data fires
// (a and b new_data are coincident at each PE when skew correct)
// ============================================================
module sysarray(
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  a_in[0:3],
    input  wire [7:0]  b_in[0:3],
    input  wire        a_new_data[0:3],    // from a_input_buffer front
    input  wire        b_new_data[0:3],    // from b_input_buffer front
    output wire [31:0] c_out[0:3][0:3],
    // expose internal new_data wires for output_collect_buffer
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

    // c_buffer: latch each PE's result when a_new_data arrives
    // (a_new_data is used as the latch enable — it is coincident
    //  with b_new_data at every PE when belt skews are correct)
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


// ============================================================
// Top-level wrapper
// Connects input buffers → sysarray → output collect → drain
// ============================================================
module top(
    input  wire        clk,
    input  wire        rst,

    // A operands pushed each cycle (from memory controller)
    input  wire [7:0]  a_push[0:3],
    input  wire        a_nd_push[0:3],   // new_data flag pushed with A

    // B operands pushed each cycle (from memory controller)
    input  wire [7:0]  b_push[0:3],
    input  wire        b_nd_push[0:3],   // new_data flag pushed with B

    // memory write interface (2 words/cycle)
    output wire [31:0] mem_word[0:1],
    output wire        mem_word_valid,
    output wire        mem_drain_done
);
    wire [7:0] a_to_array[0:3];
    wire       a_nd_to_array[0:3];
    wire [7:0] b_to_array[0:3];
    wire       b_nd_to_array[0:3];

    a_input_buffer a_buf (
        .clk       (clk),
        .rst       (rst),
        .a_push    (a_push),
        .a_nd_push (a_nd_push),
        .a_out     (a_to_array),
        .a_nd_out  (a_nd_to_array)
    );

    b_input_buffer b_buf (
        .clk       (clk),
        .rst       (rst),
        .b_push    (b_push),
        .b_nd_push (b_nd_push),
        .b_out     (b_to_array),
        .b_nd_out  (b_nd_to_array)
    );

    wire [31:0] c_out    [0:3][0:3];
    wire        a_nd_wire[0:3][0:3];
    wire        b_nd_wire[0:3][0:3];

    sysarray sa (
        .clk        (clk),
        .rst        (rst),
        .a_in       (a_to_array),
        .b_in       (b_to_array),
        .a_new_data (a_nd_to_array),
        .b_new_data (b_nd_to_array),
        .c_out      (c_out),
        .a_nd_wire  (a_nd_wire),
        .b_nd_wire  (b_nd_wire)
    );

    wire [31:0] collected[0:15];
    wire        collect_done;

    output_collect_buffer ocb (
        .clk            (clk),
        .rst            (rst),
        .a_new_data_wire(a_nd_wire),
        .b_new_data_wire(b_nd_wire),
        .c_out          (c_out),
        .collected      (collected),
        .collect_done   (collect_done)
    );

    drain_buffer db (
        .clk       (clk),
        .rst       (rst),
        .load      (collect_done),
        .data_in   (collected),
        .word_out  (mem_word),
        .word_valid(mem_word_valid),
        .drain_done(mem_drain_done)
    );

endmodule