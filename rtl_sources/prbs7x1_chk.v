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
module prbs7x1_chk(
input wire clk,
input wire reset,
output wire error,	// error detected
input wire prbs_in	// data stream to be compared
);

/*
//-----------------------------
// FSM PARAMETERS
//----------------------------
parameter [3:0] IDLE = 0;				// Initial state
parameter [3:0] ALIGNING = 1;			// shifting local prbs to align with incoming stream
parameter [3:0] CHECKING = 2;			// Streams are aligned and we are checking for errors
// parameter [3:0] PRE_BUFF_1 = 3;
// parameter [3:0] STRADDLED_0TO1 = 4 ;
// parameter [3:0] STRADDLED_1TO0 = 5 ;

//---------------------------------------------------
// BERT State machine
//---------------------------------------------------
always@(posedge clk or negedge reset)
    begin
        bert_state <= IDLE;
    end
    else
    begin
        bert_state <= bert_next_state;
        // FSM self healing ??
    end

always@(*)
    begin
        // FSM case
        case (bert_state)

            IDLE: begin
                bert_next_state = IDLE;
                if (bert_start)
                    bert_next_state = ALIGNING;
            end

            ALIGNING: begin  // 1
                bert_next_state = ALIGNING;
                if (aligned)  
                    bert_next_state = CHECKING;
            end

           CHECKING: begin  // 2
                bert_next_state = CHECKING;
                if (alignment_lossed)  
                    bert_next_state = ALIGNING;
            end
*/




reg [6:0] col /* synthesis dont_merge preserve*/;
wire      fb;
always@(posedge clk or posedge reset)
begin
	if(reset)
		begin
			col<=7'b1111111;
		end
	else
		begin
			col<={prbs_in,col[6:1]};
		end
end
assign fb=(col[0]^col[6])/* synthesis preserve noprune*/;
assign error=(fb^prbs_in)/* synthesis preserve noprune*/;

endmodule
