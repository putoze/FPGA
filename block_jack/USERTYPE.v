`ifndef USERTYPE
`define USERTYPE

package usertype;

typedef enum logic  [1:0] { club                = 2'd0,
                            diamond             = 2'd1,
                            heart               = 2'd2,
                            spade               = 2'd3
                            }Suits ;


typedef logic [3:0] Number;

//6 bits long
typedef struct packed {
    Number      number;    //number
    Suits       suits;     //suits
} Poker_Info; //Poker_Info

typedef union packed{ 
    Poker_Info  [51:0] poker;
} Poker; //48 bits long



endpackage
import usertype::*; //import usertype into $unit

`endif