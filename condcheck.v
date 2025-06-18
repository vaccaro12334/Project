module condcheck (
    input wire [3:0] Cond,
	input wire [3:0] Flags,  
    output wire CondEx
);
    wire N, Z, C, V;
    assign {N, Z, C, V} = Flags;

    assign CondEx = (Cond == 4'b0000) ?  Z :  // EQ
                    (Cond == 4'b0001) ? ~Z :  // NE
                    (Cond == 4'b0010) ?  C :  // CS/HS
                    (Cond == 4'b0011) ? ~C :  // CC/LO
                    (Cond == 4'b0100) ?  N :  // MI
                    (Cond == 4'b0101) ? ~N :  // PL
                    (Cond == 4'b0110) ?  V :  // VS
                    (Cond == 4'b0111) ? ~V :  // VC
                    (Cond == 4'b1000) ? (C & ~Z) :       // HI
                    (Cond == 4'b1001) ? (~C | Z) :        // LS
                    (Cond == 4'b1010) ? (N == V) :        // GE
                    (Cond == 4'b1011) ? (N != V) :        // LT
                    (Cond == 4'b1100) ? (~Z & (N == V)) : // GT
                    (Cond == 4'b1101) ? (Z | (N != V)) :  // LE
	   	    (Cond == 4'b1110) ? 1'b1 :            // AL  
	             1'b0;                                 // NV

endmodule

