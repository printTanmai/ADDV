// `timescale 1ns / 1ps
// //////////////////////////////////////////////////////////////////////////////////
// // Company: 
// // Engineer: 
// // 
// // Create Date:    11:34:24 06/02/2016
// // Design Name: 
// // Module Name:    graycounter 
// // Project Name: 
// // Target Devices: 
// // Tool versions: 
// // Description: 
// //
// // Dependencies: 
// //
// // Revision: 
// // Revision 0.01 - File Created
// // Additional Comments: 
// //
// //////////////////////////////////////////////////////////////////////////////////
module graycounter #(
    parameter int WIDTH = 4
)(
    input logic [WIDTH-1:0] gray_in, binary_in,
    output logic [WIDTH-1:0] gray_out, binary_out
    );

    always_comb begin 
        gray_out = (binary_in >> 1) ^ binary_in;
        
        binary_out [WIDTH-1:0] = gray_in [WIDTH-1:0];
        
        for (int i = WIDTH-2; i>=0 ; i-- ) 
        begin
            binary_out[i] = binary_out[i+1] ^ gray_in[i];
        end
        
    end


// module bin2gray #(
//     parameter int WIDTH = 4
// )(
//     input logic [WIDTH-1:0] bin,
//     output logic [WIDTH-1:0] gray
// );

//     always_comb begin 
//         gray = (bin >> 1 ) ^ bin;
        
//     end
// endmodule

// module gray2bin #(
//     parameter int int_name = value; WIDTH = 4
// )(
//     input logic [WIDTH-1:0] gray,
//     output logic [WIDTH-1:0] bin
// );

//     always_comb begin 
//         bin[WIDTH-1] = gray[WIDTH-1];

//         for (int i =WIDTH-2; i >= 0; i--) begin
//             bin[i] = bin[i+1] ^ gray [i];
//         end
        
//     end
// endmodule
