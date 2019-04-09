/////////////////////////////////////////////////////////////////////
////                                                             ////
////                    laikos@yahoo.com                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
///////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

//`define SYNTHESIS
module prbs7x1_gen(
input wire clk,
input wire noise,
input wire rstn,
output wire prbs_out
);
reg [6:0] col_gen  /* synthesis dont_merge preserve*/;
wire      fb_gen;


`ifdef SYNTHESIS
always@(posedge clk or negedge rstn)
begin
	if(~rstn)
		begin
			col_gen<=7'b1111111;
		end
	else
		begin
			col_gen<={fb_gen,col_gen[6:1]};
		end
end
assign fb_gen=col_gen[0]^col_gen[6];
assign prbs_out=col_gen[6] ; //| noise;

`else
reg seq_delay = 0;
parameter CLOCK_PERIOD = 10;
parameter CLOCK_DELAYS = 119;
initial begin
	@(posedge rstn)
	begin
		#(CLOCK_PERIOD*CLOCK_DELAYS);
//		@(posedge clk)
			seq_delay = 1;
	end
end		
	
always@(posedge clk or negedge rstn)
begin
	if(~seq_delay || ~rstn)
		begin
			col_gen<=7'b1111111;
		end
	else
		begin
			col_gen<={fb_gen,col_gen[6:1]};
		end
end
assign fb_gen=col_gen[0]^col_gen[6];
assign prbs_out=col_gen[6] ; // | noise;
`endif

endmodule

