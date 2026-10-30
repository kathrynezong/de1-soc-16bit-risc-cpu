$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$sources = @(
    "rtl/core/shifter.sv",
    "rtl/core/alu.sv",
    "rtl/core/regfile.sv",
    "rtl/core/datapath.sv",
    "rtl/memory/memory.sv",
    "rtl/core/cpu.sv",
    "rtl/system/simple_risc_system.sv",
    "rtl/board/lab7_top.sv",
    "verification/integration/system_tb.sv"
)

New-Item -ItemType Directory -Force -Path "build" | Out-Null

if (Get-Command iverilog -ErrorAction SilentlyContinue) {
    & iverilog -g2012 -Wall -s system_tb -o "build/system_tb.vvp" $sources
    if ($LASTEXITCODE -ne 0) { throw "Icarus compilation failed." }
    & vvp "build/system_tb.vvp"
    if ($LASTEXITCODE -ne 0) { throw "Icarus simulation failed." }
    exit 0
}

$modelsimBin = "C:\intelFPGA_lite\18.1\modelsim_ase\win32aloem"
$vlib = Join-Path $modelsimBin "vlib.exe"
$vlog = Join-Path $modelsimBin "vlog.exe"
$vsim = Join-Path $modelsimBin "vsim.exe"

if ((Test-Path $vlib) -and (Test-Path $vlog) -and (Test-Path $vsim)) {
    if (-not (Test-Path "build/work/_info")) {
        & $vlib "build/work"
        if ($LASTEXITCODE -ne 0) { throw "Could not create the ModelSim work library." }
    }
    & $vlog -sv -work "build/work" $sources
    if ($LASTEXITCODE -ne 0) { throw "ModelSim compilation failed." }
    & $vsim -c -lib "build/work" system_tb -do "run -all; quit -f"
    if ($LASTEXITCODE -ne 0) { throw "ModelSim simulation failed." }
    exit 0
}

throw "No supported HDL simulator found. Install Icarus Verilog or Intel FPGA Lite 18.1."
