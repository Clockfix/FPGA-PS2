// fpga4student.com: FPGA projects, Verilog projects, VHDL projects
// FPGA tutorial: How to interface a mouse with Basys 3 FPGA 
// Verilog code for interfacing a mouse with the Basys 3 FPGA board 
module mouse_basys3_FPGA(
    input clock_100Mhz, // 100 Mhz clock source on Basys 3 FPGA
    input reset, // reset
    input Mouse_Data, // Mouse PS2 data
    input Mouse_Clk, // Mouse PS2 Clock
    output reg [3:0] Anode_Activate, // anode signals of the 7-segment LED display
    output reg [6:0] LED_out// cathode patterns of the 7-segment LED display
    );
    reg [5:0] Mouse_bits; // count number of bits receiving from the PS2 mouse 
    reg [26:0] one_second_counter; // counter for generating 1 second clock enable
    wire one_second_enable;// one second enable for counting numbers
    reg [15:0] displayed_number; // Number to be increased and decreased by the mouse 
    reg [3:0] LED_BCD;
 // Signals for displaying on 7-segment LED of Basys 3 FPGA 
    reg [20:0] refresh_counter; // the first 19-bit for creating 190Hz refresh rate
             // the other 2-bit for creating 4 LED-activating signals
    wire [1:0] LED_activating_counter; 
 // counting the number of bits receiving from the Mouse Data 
 // 33 bits to be received from the Mouse 
    always @(posedge Mouse_Clk or posedge reset)
    begin
        if(reset==1)
            Mouse_bits <= 0;
        else if(Mouse_bits <=31) 
            Mouse_bits <= Mouse_bits + 1;
        else 
             Mouse_bits <= 0;
    end
 // Increase/Decrease the number when pressing Left/Right Mouse 
    always @(negedge Mouse_Clk or posedge reset)
    begin
        if(reset)
            displayed_number <= 0;
        else begin
            if(Mouse_bits==1) begin
                if(Mouse_Data==1) // if The mouse is left clicked, increase the number 
                   displayed_number <= displayed_number + 1;
            end
            else if(Mouse_bits==2) begin
               if(Mouse_Data==1&&displayed_number>0)// if The mouse is right clicked, decrease the number 
                   displayed_number <= displayed_number - 1;
                end
        end 
    end    
     // refreshing the 4-digit 7-segment display on Basys 3 FPGA 
    always @(posedge clock_100Mhz or posedge reset)
    begin 
        if(reset==1)
            refresh_counter <= 0;
        else
            refresh_counter <= refresh_counter + 1;
    end 
    assign LED_activating_counter = refresh_counter[20:19];
    // anode activating signals for 4 LEDs
    // decoder to generate anode signals 
    always @(*)
    begin
        case(LED_activating_counter)
        2'b00: begin
            Anode_Activate = 4'b0111; 
            // activate LED1 and Deactivate LED2, LED3, LED4
            LED_BCD = displayed_number/1000;
            // the first digit of the 16-bit number
              end
        2'b01: begin
            Anode_Activate = 4'b1011; 
            // activate LED2 and Deactivate LED1, LED3, LED4
            LED_BCD = (displayed_number % 1000)/100;
            // the second digit of the 16-bit number
              end
        2'b10: begin
            Anode_Activate = 4'b1101; 
            // activate LED3 and Deactivate LED2, LED1, LED4
            LED_BCD = ((displayed_number % 1000)%100)/10;
            // the third digit of the 16-bit number
                end
        2'b11: begin
            Anode_Activate = 4'b1110; 
            // activate LED4 and Deactivate LED2, LED3, LED1
            LED_BCD = ((displayed_number % 1000)%100)%10;
            // the fourth digit of the 16-bit number    
               end
        endcase
    end
    // Cathode patterns of the 7-segment LED display 
    always @(*)
    begin
        case(LED_BCD)
        4'b0000: LED_out = 7'b0000001; // "0"     
        4'b0001: LED_out = 7'b1001111; // "1" 
        4'b0010: LED_out = 7'b0010010; // "2" 
        4'b0011: LED_out = 7'b0000110; // "3" 
        4'b0100: LED_out = 7'b1001100; // "4" 
        4'b0101: LED_out = 7'b0100100; // "5" 
        4'b0110: LED_out = 7'b0100000; // "6" 
        4'b0111: LED_out = 7'b0001111; // "7" 
        4'b1000: LED_out = 7'b0000000; // "8"     
        4'b1001: LED_out = 7'b0000100; // "9" 
        default: LED_out = 7'b0000001; // "0"
        endcase
    end
 endmodule