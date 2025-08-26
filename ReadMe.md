
<!-- HTML README for UART Design -->
<div align="center" style="margin-top:24px;">
  <h1 style="margin:0; font-size:6rem;">Universal Asynchronous Receiver and Transmitter (UART) </h1>
</div>

<div style="text-align:center; margin-top:24px;">
  <p style="margin:0; font-size:3rem; font-weight:700; font-family:Arial, Helvetica, sans-serif; color:#333;">
    📑 Table of Contents
  </p>
  <ul style="list-style:none; padding:0; margin:12px 0; line-height:2.2;">
    <li><a href="#overview" class="toc-link">Overview</a></li>
    <li><a href="#interface" class="toc-link">Top Interface</a></li>
    <li><a href="#parameters" class="toc-link">Parameters</a></li>
    <li><a href="#usage" class="toc-link">Usage</a></li>
    <li><a href="#diagram" class="toc-link">Block Diagram</a></li>
  </ul>
</div>
<hr/>

<h2 id="overview">Overview</h2>
<p>The Universal Asynchronous Receiver and Transmitter (UART) are described, which is essentially a serial data transfer protocol used in digital circuit applications. The UART transmitter architecture has a baud rate generator, a parity generator, a transmitter finite state machine (FSM), and a parallel in serial out (PISO) register. The UART receiver is composed of a baud rate generator, a negative edge detector, a parity checker, a receiver Finite State Machine (FSM), and a serial in parallel out (SIPO) register. The transmitter and the receiver have the same baud rate generator; therefore, the transmitter/receiver baud rate is the same. The baud rate generator is the same as the frequency divider circuit. A UART transmitter data frame has 1 start bit, 8 transmit data bits, 1 parity bit, and 1 stop bit..</p>
<hr/>
<h2 id="features">Features</h2>
<ul>
  <li>Simple, easy-to-use UART with small logic utilization.</li>
  <li>Supports an optional parity bit (even or odd parity for transmit and
receive).</li>
  <li>1 stop bit.</li>
  <li>Baud prescaler (set according to system clock).</li>
  <li>Supports run-time configurable baud rate.</li>
  <li>Self-checking testbench with directed tests and error injection.</li>
<hr/>
</ul>
<h2 id="interface">Top-Level Interface</h2>
<p>The The UART controller consists of a UART transmitter finite state machine
(FSM), UART receiver FSM, and a baud rate generator..</p>
<table align="center";style="width:100%; border-collapse:collapse;">
  <thead>
    <tr style="background:#A2f202;">
      <th style="border:1px solid #ddd; padding:8px; text-align:left;">Signal Name</th>
      <th style="border:1px solid #ddd; padding:8px; text-align:left;">Direction</th>
      <th style="border:1px solid #ddd; padding:8px; text-align:left;">Width</th>
      <th style="border:1px solid #ddd; padding:8px; text-align:left;">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;"><strong>Tx_Data</strong></td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">8-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Parallel data input to be transmitted</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;"><strong>Tx_Data_Valid</strong></td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Control signal to start transmission</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Tx_Busy</td>
      <td style="border:1px solid #ddd; padding:8px;">Output</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Indicates the transmitter is busy</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Tx_Data_Out</td>
      <td style="border:1px solid #ddd; padding:8px;">Output</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Serial transmitted data (UART TX line)</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Rx_Data_IN</td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Serial input data (UART RX line)</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;"><strong>Rx_Data_OUT</strong></td>
      <td style="border:1px solid #ddd; padding:8px;">Output</td>
      <td style="border:1px solid #ddd; padding:8px;">8-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Parallel received data output</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Rx_Data_Valid</td>
      <td style="border:1px solid #ddd; padding:8px;">Output</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Indicates a valid received byte</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Clock</td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">System clock</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Reset</td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Asynchronous active-low reset</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Prescale</td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">6-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Prescaler value for baud-rate generator</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Parity_Enable</td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Enable parity generation/checking</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Parity_Type</td>
      <td style="border:1px solid #ddd; padding:8px;">Input</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">0 = even, 1 = odd (example mapping)</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Frame_Err</td>
      <td style="border:1px solid #ddd; padding:8px;">Output</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Indicates stop-bit/frame error</td>
    </tr>
    <tr>
      <td style="border:1px solid #ddd; padding:8px;">Parity_Err</td>
      <td style="border:1px solid #ddd; padding:8px;">Output</td>
      <td style="border:1px solid #ddd; padding:8px;">1-bit</td>
      <td style="border:1px solid #ddd; padding:8px;">Parity mismatch detected</td>
    </tr>
  </tbody>
</table>
<p align="center">
  <img src="docs/UART_TOP_Interface.png" alt="UART Block Diagram" width="800">
</p>

<h2 id="parameters">Parameters (defaults)</h2>
<ul>
  <li><strong>DATA_BITS</strong>: 8</li>
  <li><strong>PARITY</strong>: "none"</li>
  <li><strong>STOP_BITS</strong>: 1</li>
  <li><strong>PRESCALE</strong>: 27 (example for Fclk=50MHz, BAUD=115200, OVERSAMPLE=16)</li>
</ul>

<h2 id="usage">Usage</h2>
<p>Compile and simulate with a Verilog simulator. Example commands for ModelSim/Questa:</p>
<pre style="background:#f6f8fa; padding:10px; border-radius:6px;">vlog rtl/uart_tx.v rtl/uart_rx.v rtl/uart_baud.v rtl/uart_top.v tb/uart_tb.v
vsim -voptargs=+acc work.uart_tb
run -all</pre>

<h2 id="diagram">Block Diagram</h2>
<!-- Add your image to docs/uart_block.png so GitHub renders it. -->
<div style="text-align:center; margin:12px 0;">
  <img src="docs/uart_block.png" alt="UART Block Diagram" style="max-width:900px; width:100%; border-radius:8px; border:1px solid #e6e6e6;"/>
  <p style="color:#666; font-size:0.9rem;">Figure: Top-level UART architecture (Baud generator, TX, RX)</p>
</div>

<hr/>
<p style="font-size:0.9rem; color:#666;">Note: Update the <code>Prescale</code> default to match your clock and baud requirements. If you want the table styled differently, or need column reordering, tell me which columns or signals to change.</p>



