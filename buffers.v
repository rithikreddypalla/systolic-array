// ============================================================
// A input conveyor belts
// belt lengths: row0=8, row1=9, row2=10, row3=11
// Parallel 1-bit new_data belts of same lengths travel with A
// Index 0 = output end (feeds sysarray)
// Index N-1 = input end (new value pushed each cycle)
// ============================================================
module a_input_buffer(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] a_push[0:3],        // data pushed each cycle
    input  wire       a_nd_push[0:3],     // new_data pushed each cycle
    output wire [7:0] a_out[0:3],         // front of data belt → sysarray
    output wire       a_nd_out[0:3]       // front of new_data belt → sysarray
);
    // data belts
    reg [7:0] belt0 [0:7];
    reg [7:0] belt1 [0:8];
    reg [7:0] belt2 [0:9];
    reg [7:0] belt3 [0:10];

    // new_data belts
    reg nd_belt0 [0:7];
    reg nd_belt1 [0:8];
    reg nd_belt2 [0:9];
    reg nd_belt3 [0:10];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8;  i = i+1) begin belt0[i] <= 8'b0; nd_belt0[i] <= 1'b0; end
            for (i = 0; i < 9;  i = i+1) begin belt1[i] <= 8'b0; nd_belt1[i] <= 1'b0; end
            for (i = 0; i < 10; i = i+1) begin belt2[i] <= 8'b0; nd_belt2[i] <= 1'b0; end
            for (i = 0; i < 11; i = i+1) begin belt3[i] <= 8'b0; nd_belt3[i] <= 1'b0; end
        end else begin
            // shift data belts left
            for (i = 0; i < 7;  i = i+1) belt0[i] <= belt0[i+1];
            for (i = 0; i < 8;  i = i+1) belt1[i] <= belt1[i+1];
            for (i = 0; i < 9;  i = i+1) belt2[i] <= belt2[i+1];
            for (i = 0; i < 10; i = i+1) belt3[i] <= belt3[i+1];
            // push new data at end
            belt0[7]  <= a_push[0];
            belt1[8]  <= a_push[1];
            belt2[9]  <= a_push[2];
            belt3[10] <= a_push[3];

            // shift new_data belts left
            for (i = 0; i < 7;  i = i+1) nd_belt0[i] <= nd_belt0[i+1];
            for (i = 0; i < 8;  i = i+1) nd_belt1[i] <= nd_belt1[i+1];
            for (i = 0; i < 9;  i = i+1) nd_belt2[i] <= nd_belt2[i+1];
            for (i = 0; i < 10; i = i+1) nd_belt3[i] <= nd_belt3[i+1];
            // push new_data flag at end
            nd_belt0[7]  <= a_nd_push[0];
            nd_belt1[8]  <= a_nd_push[1];
            nd_belt2[9]  <= a_nd_push[2];
            nd_belt3[10] <= a_nd_push[3];
        end
    end

    assign a_out[0]    = belt0[0];
    assign a_out[1]    = belt1[0];
    assign a_out[2]    = belt2[0];
    assign a_out[3]    = belt3[0];

    assign a_nd_out[0] = nd_belt0[0];
    assign a_nd_out[1] = nd_belt1[0];
    assign a_nd_out[2] = nd_belt2[0];
    assign a_nd_out[3] = nd_belt3[0];

endmodule


// ============================================================
// B input conveyor belts
// identical structure but column-wise (col0=8, col1=9, ...)
// Parallel 1-bit new_data belts of same lengths travel with B
// ============================================================
module b_input_buffer(
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] b_push[0:3],
    input  wire       b_nd_push[0:3],
    output wire [7:0] b_out[0:3],
    output wire       b_nd_out[0:3]
);
    reg [7:0] belt0 [0:7];
    reg [7:0] belt1 [0:8];
    reg [7:0] belt2 [0:9];
    reg [7:0] belt3 [0:10];

    reg nd_belt0 [0:7];
    reg nd_belt1 [0:8];
    reg nd_belt2 [0:9];
    reg nd_belt3 [0:10];

    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 8;  i = i+1) begin belt0[i] <= 8'b0; nd_belt0[i] <= 1'b0; end
            for (i = 0; i < 9;  i = i+1) begin belt1[i] <= 8'b0; nd_belt1[i] <= 1'b0; end
            for (i = 0; i < 10; i = i+1) begin belt2[i] <= 8'b0; nd_belt2[i] <= 1'b0; end
            for (i = 0; i < 11; i = i+1) begin belt3[i] <= 8'b0; nd_belt3[i] <= 1'b0; end
        end else begin
            for (i = 0; i < 7;  i = i+1) belt0[i] <= belt0[i+1];
            for (i = 0; i < 8;  i = i+1) belt1[i] <= belt1[i+1];
            for (i = 0; i < 9;  i = i+1) belt2[i] <= belt2[i+1];
            for (i = 0; i < 10; i = i+1) belt3[i] <= belt3[i+1];
            belt0[7]  <= b_push[0];
            belt1[8]  <= b_push[1];
            belt2[9]  <= b_push[2];
            belt3[10] <= b_push[3];

            for (i = 0; i < 7;  i = i+1) nd_belt0[i] <= nd_belt0[i+1];
            for (i = 0; i < 8;  i = i+1) nd_belt1[i] <= nd_belt1[i+1];
            for (i = 0; i < 9;  i = i+1) nd_belt2[i] <= nd_belt2[i+1];
            for (i = 0; i < 10; i = i+1) nd_belt3[i] <= nd_belt3[i+1];
            nd_belt0[7]  <= b_nd_push[0];
            nd_belt1[8]  <= b_nd_push[1];
            nd_belt2[9]  <= b_nd_push[2];
            nd_belt3[10] <= b_nd_push[3];
        end
    end

    assign b_out[0]    = belt0[0];
    assign b_out[1]    = belt1[0];
    assign b_out[2]    = belt2[0];
    assign b_out[3]    = belt3[0];

    assign b_nd_out[0] = nd_belt0[0];
    assign b_nd_out[1] = nd_belt1[0];
    assign b_nd_out[2] = nd_belt2[0];
    assign b_nd_out[3] = nd_belt3[0];

endmodule


// ============================================================
// Output collection buffer
// Watches new_data_wire from each PE (AND of a and b signals)
// Collects all 16 results, pulses collect_done when full
// ============================================================
module output_collect_buffer(
    input  wire        clk,
    input  wire        rst,
    input  wire        a_new_data_wire [0:3][0:3],
    input  wire        b_new_data_wire [0:3][0:3],
    input  wire [31:0] c_out           [0:3][0:3],
    output reg  [31:0] collected [0:15],
    output reg         collect_done
);
    reg [4:0] count;

    integer r, c;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count        <= 0;
            collect_done <= 0;
        end else begin
            collect_done <= 0;
            for (r = 0; r < 4; r = r+1) begin
                for (c = 0; c < 4; c = c+1) begin
                    // latch when both A and B new_data arrive (they should
                    // be coincident when belt skews are set up correctly)
                    if (a_new_data_wire[r][c] && b_new_data_wire[r][c]) begin
                        collected[r*4+c] <= c_out[r][c];
                        count            <= count + 1;
                    end
                end
            end
            if (count == 15) begin
                collect_done <= 1;
                count        <= 0;
            end
        end
    end

endmodule


// ============================================================
// Drain buffer
// Latches 16 collected words, drains 2 per cycle to memory
// ============================================================
module drain_buffer(
    input  wire        clk,
    input  wire        rst,
    input  wire        load,
    input  wire [31:0] data_in  [0:15],
    output reg  [31:0] word_out [0:1],
    output reg         word_valid,
    output reg         drain_done
);
    reg [31:0] buf [0:15];
    reg [3:0]  ptr;
    reg        draining;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ptr        <= 0;
            draining   <= 0;
            word_valid <= 0;
            drain_done <= 0;
        end else begin
            drain_done <= 0;
            word_valid <= 0;

            if (load) begin
                buf      <= data_in;
                ptr      <= 0;
                draining <= 1;
            end else if (draining) begin
                word_out[0] <= buf[ptr];
                word_out[1] <= buf[ptr+1];
                word_valid  <= 1;
                ptr         <= ptr + 2;
                if (ptr == 14) begin
                    draining   <= 0;
                    drain_done <= 1;
                end
            end
        end
    end

endmodule