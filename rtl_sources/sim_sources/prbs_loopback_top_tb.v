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

module prbs_loopback_top_tb();

reg clk=1;
reg rstn=0;
reg tst=0;
wire led15;
wire x2_result;
wire x4_result;

// Create the PLL reference clock
always #(10/2) clk <= ~clk; // 10nsec period


//dut
prbs_loopback_top DUT(
	.clk_in(clk),
	.rstn_in(rstn),
	.testn_in(tst),
	.led15(led15),
	.led14(x2_result)
//	.led13(x4_result)
);

initial begin
#40;
rstn=1'b0;
#100;
rstn=1'b1; // what is board push button??
#1000;
tst=1'b0;
#5000;
tst=1'b1;

end

endmodule
