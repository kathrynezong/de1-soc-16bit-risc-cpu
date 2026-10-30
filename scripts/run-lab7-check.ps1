$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot
$modelsimBin = "C:\intelFPGA_lite\18.1\modelsim_ase\win32aloem"
$vlib = Join-Path $modelsimBin "vlib.exe"
$vlog = Join-Path $modelsimBin "vlog.exe"
$vsim = Join-Path $modelsimBin "vsim.exe"
$checker = "..\lab7\lab7_autograder_check.sv"
$library = "build/lab7_work"
if (-not (Test-Path $checker)) { throw "Could not find $checker." }
if (-not ((Test-Path $vlib) -and (Test-Path $vlog) -and (Test-Path $vsim))) {
    throw "Intel FPGA Lite 18.1 ModelSim was not found at $modelsimBin."
}
New-Item -ItemType Directory -Force -Path "build" | Out-Null
if (-not (Test-Path "$library/_info")) {
    & $vlib $library
    if ($LASTEXITCODE -ne 0) { throw "Could not create the ModelSim library." }
}
$sources = @("rtl/core/shifter.sv", "rtl/core/alu.sv", "rtl/core/regfile.sv",
    "rtl/core/datapath.sv", "rtl/memory/memory.sv", "rtl/core/cpu.sv",
    "rtl/board/lab7_top.sv", $checker)
& $vlog -sv -work $library $sources
if ($LASTEXITCODE -ne 0) { throw "Lab 7 checker compilation failed." }
& $vsim -c -lib $library lab7_check_tb -do "run -all; quit -f"
if ($LASTEXITCODE -ne 0) { throw "Lab 7 checker simulation failed." }
