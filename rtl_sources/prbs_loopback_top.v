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
////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module prbs_loopback_top(
input wire clk_in,			// LVDS, P3/P4
input wire rstn_in,			// active low, R1
input wire testn_in,		// active low. injects errors into prbs generated stream
input wire prbs_in,			// receive prbs from the channel, B12
output wire prbs_out,		// prbs output to channel, E6
output wire heart_beat,		// D22, PIN D18, active Low
output wire bert_synchedn	// D21, PIN E18, active Low
//output wire led13			// not used
);

//rename reset
wire rstn;
assign rstn = rstn_in;

// make bert_synched active low
assign bert_synchedn = ~bert_synched;

//clk div
reg [23:0] ctr=24'd0;

always@(posedge clk_in)
begin
	ctr<=ctr+1'b1;
end
assign heart_beat=ctr[23];

//wire clk2x;		// change to clk2x from clk_div2
//wire clk;		// change to clk from clk_div4
wire clk = clk_in; // 10nsec period
wire clk_div2;	// change to clk_div2 from clk_div8

//assign clk2x=ctr[0];
//assign clk=ctr[1];
assign clk_div2=ctr[0];

//test pin
wire test;
assign test= (testn_in)?1'b0:clk_div2;

//prbs 7x1_gen0
//prbs 7x1 => prbs7x1_gen
wire prbs7_x1_signal /* synthesis preserve */;
prbs7x1_gen prbs7x1_gen0(
	.clk(clk),
	.noise(test),
	.rstn(rstn),
	.prbs_out(prbs_out)
)/* synthesis preserve */;

//prbs 7x1_chk0
prbs7x1_chk prbs7x1_chk0(
	.clk(clk),
	.rstn(rstn),
	.error(led14),
	.prbs_in(prbs_in),
	.bert_synched(bert_synched)
)/* synthesis preserve */;
endmodule
