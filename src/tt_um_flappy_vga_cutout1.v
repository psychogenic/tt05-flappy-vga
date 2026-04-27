
// Top level module for a VGA based flappy bird game to be included in Tiny Tapeout 05
//
// Author: Daniel Robinson (cutout on Discord)

module tt_um_flappy_vga_cutout1 (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock (25MHz)
    input  wire       rst_n     // reset_n - low to reset
);
	wire [9:0] h_count, v_count;
	wire [8:0] bird_pos, hole_pos;
	wire [9:0] pipe_pos;
	wire [7:0] score;
	wire red, green, blue;
	wire h_sync, v_sync;
	wire game_button;
	wire bright;

	// Gamepad Pmod support
	wire gamepad_pmod_latch = ui_in[4];
	wire gamepad_pmod_clk = ui_in[5];
	wire gamepad_pmod_data = ui_in[6];
	wire gamepad_is_present;
	wire gamepad_left;
	wire gamepad_right;
	wire gamepad_up;
	wire gamepad_down;
	wire gamepad_start;
	wire gamepad_select;
	wire gamepad_a;
	wire gamepad_x;
	
	
	assign uio_oe = 8'b11111111;
	assign uio_out = score;
	

      gamepad_pmod_single gamepad_pmod (
	// Inputs:
	.clk(clk),
	.rst_n(rst_n),
	.pmod_latch(gamepad_pmod_latch),
	.pmod_clk(gamepad_pmod_clk),
	.pmod_data(gamepad_pmod_data),

	// Outputs:
	.is_present(gamepad_is_present),
	.left(gamepad_left),
	.right(gamepad_right),
	.up(gamepad_up),
	.down(gamepad_down),
	.start(gamepad_start),
	.select(gamepad_select),
	.a(gamepad_a),
	.x(gamepad_x)
      );
	// Tiny VGA PMOD compatible outputs
	assign uo_out[0] = red;    // R1
	assign uo_out[1] = green;  // G1
	assign uo_out[2] = blue;   // B1
	assign uo_out[3] = v_sync; // vsync
	assign uo_out[4] = red;    // R0
	assign uo_out[5] = green;  // G0
	assign uo_out[6] = blue;   // B0
	assign uo_out[7] = h_sync; // hsync
	
	gameControl game (clk, rst_n, v_sync, game_button, gamepad_start, bird_pos, hole_pos, pipe_pos, score);
	
	vgaControl controller (clk, rst_n, h_sync, v_sync, bright, h_count, v_count);
	
	bitGen bitGenerator (clk, rst_n, bright, h_count, v_count, bird_pos, hole_pos, pipe_pos, red, green, blue);
	
	always @(posedge clk)
	begin
	  if (gamepad_is_present)
	   begin
	    game_button <= ~(gamepad_up || gamepad_a || gamepad_x);
	   end
	  else
	   begin
	    game_button <= ui_in[0];
	   end
	end
	
endmodule
