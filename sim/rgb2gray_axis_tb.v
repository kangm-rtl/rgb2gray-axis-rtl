
`timescale 1ns/1ps

module rgb2gray_axis_tb;

    // 1. Testbench signals
    reg         aclk;
    reg         aresetn;

    reg  [23:0] s_axis_tdata;
    reg         s_axis_tvalid;
    wire        s_axis_tready;
    reg         s_axis_tlast;

    wire [7:0]  m_axis_tdata;
    wire        m_axis_tvalid;
    reg         m_axis_tready;
    wire        m_axis_tlast;

    // 2. Device Under Test (DUT)
    rgb2gray_axis dut (
        .aclk          (aclk),
        .aresetn       (aresetn),

        .s_axis_tdata  (s_axis_tdata),
        .s_axis_tvalid (s_axis_tvalid),
        .s_axis_tready (s_axis_tready),
        .s_axis_tlast  (s_axis_tlast),

        .m_axis_tdata  (m_axis_tdata),
        .m_axis_tvalid (m_axis_tvalid),
        .m_axis_tready (m_axis_tready),
        .m_axis_tlast  (m_axis_tlast)
    );

    // 3. Generate clock: 10 ns period
    always #5 aclk = ~aclk;

    // 4. Initialize signals and release reset
    initial begin
        aclk          = 1'b0;
        aresetn       = 1'b0;

        s_axis_tdata  = 24'd0;
        s_axis_tvalid = 1'b0;
        s_axis_tlast  = 1'b0;
        m_axis_tready = 1'b1;

        // Release reset
        #20;
        aresetn = 1'b1;

        // Send one black pixel: R=0, G=0, B=0
        @(negedge aclk);
        s_axis_tdata  = 24'h000000;
        s_axis_tvalid = 1'b1;
        s_axis_tlast  = 1'b0;

        // Wait for the pixel to be accepted
        @(posedge aclk);
        #1;

        // Check grayscale output
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd0) begin
            $fatal(1, "FAIL: Black pixel test");
        end
        else begin
            $display("PASS: Black pixel test");
        end

     
        // Stop sending the black pixel
        @(negedge aclk);
        s_axis_tvalid = 1'b0;

        // Send one white pixel: R=255, G=255, B=255
        @(negedge aclk);
        s_axis_tdata  = 24'hFFFFFF;
        s_axis_tvalid = 1'b1;
        s_axis_tlast  = 1'b0;

        // Check output after the accepting clock edge
        @(posedge aclk);
        #1;

        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd255) begin
            $fatal(1, "FAIL: White pixel test");
        end
        else begin
            $display("PASS: White pixel test");
        end

       
        // Stop input and apply backpressure
        @(negedge aclk);
        s_axis_tvalid = 1'b0;
        m_axis_tready = 1'b0;

        // Output must hold the white pixel while stalled
        @(posedge aclk);
        #1;

        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd255) begin
            $fatal(1, "FAIL: Backpressure hold test");
        end
        else begin
            $display("PASS: Backpressure hold test");
        end

        
        // Test input backpressure:
        // The white pixel is still waiting at the output.
        // Present a red pixel while the receiver is not ready.

        @(negedge aclk);
        s_axis_tdata  = 24'hFF0000;
        s_axis_tvalid = 1'b1;
        s_axis_tlast  = 1'b0;

        // The red pixel must not be accepted while stalled.
        @(posedge aclk);
        #1;

        if (s_axis_tready !== 1'b0 ||
            m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd255 ||
            m_axis_tlast !== 1'b0) begin
            $fatal(1, "FAIL: Input backpressure hold test");
        end
        else begin
            $display("PASS: Input backpressure hold test");
        end

        // Release backpressure.
        // The waiting red pixel should now be accepted.
        @(negedge aclk);
        m_axis_tready = 1'b1;

        @(posedge aclk);
        #1;

        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd76 ||
            m_axis_tlast !== 1'b0) begin
            $fatal(1, "FAIL: Backpressure recovery test");
        end
        else begin
            $display("PASS: Backpressure recovery test");
        end

        // Stop sending the red pixel.
        @(negedge aclk);
        s_axis_tvalid = 1'b0;

      
        // Test RED pixel: RGB = (255, 0, 0)
        @(negedge aclk);
        s_axis_tdata  = 24'hFF0000;
        s_axis_tvalid = 1'b1;

        @(posedge aclk);
        #1;
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd76) begin
            $fatal(1, "FAIL: Red pixel test");
        end
        else begin
            $display("PASS: Red pixel test");
        end

        @(negedge aclk);
        s_axis_tvalid = 1'b0;

        // Test GREEN pixel: RGB = (0, 255, 0)
        @(negedge aclk);
        s_axis_tdata  = 24'h00FF00;
        s_axis_tvalid = 1'b1;

        @(posedge aclk);
        #1;
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd149) begin
            $fatal(1, "FAIL: Green pixel test");
        end
        else begin
            $display("PASS: Green pixel test");
        end

        @(negedge aclk);
        s_axis_tvalid = 1'b0;

        // Test BLUE pixel: RGB = (0, 0, 255)
        @(negedge aclk);
        s_axis_tdata  = 24'h0000FF;
        s_axis_tvalid = 1'b1;

        @(posedge aclk);
        #1;
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd28) begin
            $fatal(1, "FAIL: Blue pixel test");
        end
        else begin
            $display("PASS: Blue pixel test");
        end

        @(negedge aclk);
        s_axis_tvalid = 1'b0;

        // Test TLAST propagation
        @(negedge aclk);
        s_axis_tdata  = 24'h123456;
        s_axis_tvalid = 1'b1;
        s_axis_tlast  = 1'b1;

        @(posedge aclk);
        #1;

        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tlast !== 1'b1) begin
            $fatal(1, "FAIL: TLAST propagation test");
        end
        else begin
            $display("PASS: TLAST propagation test");
        end

        @(negedge aclk);
        s_axis_tvalid = 1'b0;
        s_axis_tlast  = 1'b0;

        // Consecutive pixel transfer test
        // Keep TREADY high and send one pixel per clock

        m_axis_tready = 1'b1;

        // Pixel 1: Black -> 0
        @(negedge aclk);
        s_axis_tdata  = 24'h000000;
        s_axis_tvalid = 1'b1;
        s_axis_tlast  = 1'b0;

        @(posedge aclk);
        #1;
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd0)
            $fatal(1, "FAIL: Consecutive pixel 1");
        else
            $display("PASS: Consecutive pixel 1");

        // Pixel 2: Red -> 76
        @(negedge aclk);
        s_axis_tdata = 24'hFF0000;

        @(posedge aclk);
        #1;
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd76)
            $fatal(1, "FAIL: Consecutive pixel 2");
        else
            $display("PASS: Consecutive pixel 2");

        // Pixel 3: Green -> 149
        @(negedge aclk);
        s_axis_tdata = 24'h00FF00;

        @(posedge aclk);
        #1;
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd149)
            $fatal(1, "FAIL: Consecutive pixel 3");
        else
            $display("PASS: Consecutive pixel 3");

        // Pixel 4: Blue -> 28
        @(negedge aclk);
        s_axis_tdata = 24'h0000FF;

        @(posedge aclk);
        #1;
        if (m_axis_tvalid !== 1'b1 ||
            m_axis_tdata !== 8'd28)
            $fatal(1, "FAIL: Consecutive pixel 4");
        else
            $display("PASS: Consecutive pixel 4");

        // End input stream
        @(negedge aclk);
        s_axis_tvalid = 1'b0;
        s_axis_tlast  = 1'b0;

        #20;
        $finish;



    end

endmodule
