#include "Vsystem.h"                // Top-level module header generated by Verilator
#include "verilated.h"              // Verilator header
#include "verilated_vcd_c.h"        // Optional: for VCD waveform generation

#include <iostream>
#include <cstdlib>

// Current simulation time (in time units)
vluint64_t main_time = 0;
double sc_time_stamp() { return main_time; }

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vsystem* top = new Vsystem;

    // Optional: Set up VCD trace
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace with a depth of 99 levels
    tfp->open("dump.vcd");

    // Simulation parameters
    const int clock_period = 10; // clock period in time units (e.g., ns)
    const int sim_cycles = 50;   // total simulation cyclesgit 

    // Initialize inputs
    top->clk = 0;
    top->rst = 1;
    top->fifo1_data_in = 0;
    top->fifo2_data_in = 0;
    top->fifo3_data_in = 0;
    top->fifo1_write_en = 0;
    top->fifo2_write_en = 0;
    top->fifo3_write_en = 0;
    top->fifo1_read_en = 0;
    top->fifo2_read_en = 0;
    top->fifo3_read_en = 0;

    // Apply reset for a few cycles (e.g., 3 cycles)
    for (int i = 0; i < 3; i++) {
        // Clock low phase
        top->clk = 0;
        top->eval();
        tfp->dump(main_time);
        main_time += clock_period/2;

        // Clock high phase
        top->clk = 1;
        top->eval();
        tfp->dump(main_time);
        main_time += clock_period/2;
    }
    // Release reset
    top->rst = 0;

    // Wait one cycle after reset
    for (int i = 0; i < 1; i++) {
        top->clk = 0;
        top->eval();
        tfp->dump(main_time);
        main_time += clock_period/2;
        top->clk = 1;
        top->eval();
        tfp->dump(main_time);
        main_time += clock_period/2;
    }

    // Write values into the three FIFOs:
    // FIFO1: 3, FIFO2: 4, FIFO3: 5.
    top->fifo1_data_in = 3;
    top->fifo2_data_in = 4;
    top->fifo3_data_in = 5;
    top->fifo1_write_en = 1;
    top->fifo2_write_en = 1;
    top->fifo3_write_en = 1;

    // Provide one clock cycle for the write
    top->clk = 0;
    top->eval();
    tfp->dump(main_time);
    main_time += clock_period/2;
    top->clk = 1;
    top->eval();
    tfp->dump(main_time);
    main_time += clock_period/2;

    // Deassert write enables after one cycle
    top->fifo1_write_en = 0;
    top->fifo2_write_en = 0;
    top->fifo3_write_en = 0;

    // Let the design settle by running a few more clock cycles.
    for (int i = 0; i < 5; i++) {
        top->clk = 0;
        top->eval();
        tfp->dump(main_time);
        main_time += clock_period/2;
        top->clk = 1;
        top->eval();
        tfp->dump(main_time);
        main_time += clock_period/2;
    }

    // Read the result from the system output
    // Expected result = (3 * 4) + 5 = 17
    uint32_t result = top->result_out;
    std::cout << "Result = " << result << std::endl;

    if(result != 17) {
        std::cerr << "Test FAILED: Expected result 17, got " << result << std::endl;
        exit(1);
    } else {
        std::cout << "Test PASSED: Result is 17 as expected." << std::endl;
    }

    // Finish simulation
    tfp->close();
    top->final();
    delete top;
    return 0;
}
