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

module prbs7x1_chk(
input wire clk,
input wire rstn,	// active low
output wire error,	// error detected
input wire prbs_in	// data stream to be compared
);

// regs
reg prbs_rstn	;
reg efc_rstn	;
reg efc_en		;
reg ec_rstn		;	
reg ec_en		;
reg bert_synched;
reg encr_bit_position;


//-----------------------------
// DESIGN PARAMETERS
//-----------------------------
parameter [2:0] PRBS_PATTERN			= 7	;
parameter [7:0] SEQUENCE_LENGTH 		= 2^PRBS_PATTERN - 1;			// PRBS-7 sequence is 127 Bits long
parameter [6:0] CLOCKS_ASSUME_SYNCH = 63;		// How many clocks will we wait to check if streams are synch'ed
parameter [6:0] ERROR_CNT_TERM_VAL = 65535;		// 



//-----------------------------
// FSM PARAMETERS
//-----------------------------
parameter [2:0] IDLE = 0;				// Initial state
parameter [2:0] TEST_SYNCH = 1;			// checking for errors to see if synch'ed
parameter [2:0] ADD_DELAY = 2;			// shift local compare pattern by one bit time
parameter [2:0]	WAIT_FOR_CNT_ALIGN = 3;	// wait for last shift to occur so we can then move to TEST_SYNCH
parameter [2:0] BERT_TEST = 4;			// Streams synch'ed; Count errors
// parameter [3:0] STRADDLED_0TO1 = 4 ;
// parameter [3:0] STRADDLED_1TO0 = 5 ;


//-----------------------------
// Counters
//-----------------------------

// This counter will count as high as the number of bits in a given prbs sequence. For example prbs-7 repeats every
// 127 bits so the counter will count from 0 to 126.
reg [PRBS_PATTERN-1:0] pattern_count ;
always@(posedge clk or negedge rstn)
	begin
		if (~rstn)
			pattern_count <= 0;
		else 
			pattern_count <= pattern_count + 1;
	end
			
// Counts number of errors
reg [15:0] error_counter;
always@(posedge clk or negedge ec_rstn)
	begin
		if (~ec_rstn)
			error_counter <= 0;
		else 
			begin
				if (ec_en)
					error_counter <= error_counter + 1;
			end
	end

// Counts number of error free bits
reg [5:0] error_free_counter;
always@(posedge clk or negedge efc_rstn)
	begin
		if (~efc_rstn)
			error_free_counter <= 0;
		else 
			begin
				if (efc_en)
					error_free_counter <= error_free_counter + 1;
			end
	end

reg [2:0] bert_state, bert_next_state;
//---------------------------------------------------
// BERT State machine
//---------------------------------------------------
always@(posedge clk or negedge rstn)
//    begin
		if (~rstn)
			bert_state <= IDLE;
//    end
    else
//    begin
        bert_state <= bert_next_state;
        // FSM self healing ??
//    end

// FSM case next state logic
always@(*)
    begin
        case (bert_state)
            IDLE: begin			// 0
                bert_next_state = TEST_SYNCH;
            end

            TEST_SYNCH: begin  // 1
                bert_next_state = TEST_SYNCH;
                if (error_free_counter == CLOCKS_ASSUME_SYNCH)  
                    bert_next_state = BERT_TEST;
				if (error)
					bert_next_state = ADD_DELAY;
            end

           ADD_DELAY: begin  // 2
                bert_next_state = WAIT_FOR_CNT_ALIGN;
            end
			
			WAIT_FOR_CNT_ALIGN: begin	// 3
				bert_next_state = WAIT_FOR_CNT_ALIGN;
				if (pattern_bit_position == pattern_count)  
                    bert_next_state = TEST_SYNCH;
			end
			
			BERT_TEST: begin  // 4
                bert_next_state = BERT_TEST;
                if (error_counter == 65535)  
                    bert_next_state = TEST_SYNCH;
            end
			
			default: begin
				bert_next_state = IDLE ;
			end
		endcase	
	end

// FSM case output logic
always@(*)
    begin
        case (bert_state)
            IDLE: begin			// 0
				prbs_rstn		= 0;
                efc_rstn		= 0;
				efc_en			= 0;
				ec_rstn			= 0;
				ec_en			= 0;
				bert_synched	= 0;
				encr_bit_position = 0;
//				bert_error		= 0;
            end

            TEST_SYNCH: begin  // 1
                prbs_rstn		= 1;
				efc_rstn		= 1;
				efc_en			= 1;
				ec_rstn			= 0;
				ec_en			= 0;
				bert_synched	= 0;
				encr_bit_position = 0;
//				bert_error		= 0;
            end

           ADD_DELAY: begin  // 2
				prbs_rstn		= 0;
				efc_rstn		= 0;
				efc_en			= 1;
				ec_rstn			= 0;
				ec_en			= 0;
				bert_synched	= 0;
				encr_bit_position = 1;
//				bert_error		= 0;
            end
			
			WAIT_FOR_CNT_ALIGN: begin  // 3
				prbs_rstn		= 0;
				efc_rstn		= 0;
				efc_en			= 1;
				ec_rstn			= 0;
				ec_en			= 0;
				bert_synched	= 0;
				encr_bit_position = 0;
//				bert_error		= 0;
            end
			
			BERT_TEST: begin  // 4
				prbs_rstn		= 1;
                efc_rstn		= 1;
				efc_en			= 0;
				ec_rstn			= 1;
				ec_en			= 1;
				bert_synched	= 1;
				encr_bit_position = 0;
//				bert_error		= 0;
            end
		endcase	
	end

// the pattern_bit_position is where we are going to attempt to synch with the incoming prbs pattern
// Each time we fail to synch we increment the bit position and try again.
reg [PRBS_PATTERN-1:0] pattern_bit_position ;
always@(posedge clk or negedge rstn)
begin
	if(~rstn)
		begin
			pattern_bit_position<=0;
		end
	else if (encr_bit_position)
		begin
			pattern_bit_position<=pattern_bit_position+1;
		end
end

reg [6:0] col_chk /* synthesis dont_merge preserve*/;
wire      fb_chk;
always@(posedge clk or negedge rstn)
begin
	if(~prbs_rstn || ~rstn)
		begin
			col_chk<=7'b1111111;
		end
	else
		begin
			col_chk<={fb_chk,col_chk[6:1]};
		end
end
assign fb_chk=(col_chk[0]^col_chk[6])/* synthesis preserve noprune*/;
assign error=(fb_chk^prbs_in)/* synthesis preserve noprune*/;

endmodule
