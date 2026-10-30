$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$modelsimBin = "C:\intelFPGA_lite\18.1\modelsim_ase\win32aloem"
$uvmSource = "C:\intelFPGA_lite\18.1\modelsim_ase\verilog_src\uvm-1.2\src"
$vlib = Join-Path $modelsimBin "vlib.exe"
$vlog = Join-Path $modelsimBin "vlog.exe"
$vsim = Join-Path $modelsimBin "vsim.exe"
$library = "build/uvm_work"

foreach ($requiredPath in @($vlib, $vlog, $vsim, (Join-Path $uvmSource "uvm_pkg.sv"))) {
    if (-not (Test-Path $requiredPath)) {
        throw "Required UVM/ModelSim file was not found: $requiredPath"
    }
}

New-Item -ItemType Directory -Force -Path "build" | Out-Null
if (-not (Test-Path "$library/_info")) {
    & $vlib $library
    if ($LASTEXITCODE -ne 0) { throw "Could not create the UVM work library." }
}

& $vlog -sv -work $library "+define+UVM_NO_DPI" "+incdir+$uvmSource" `
    (Join-Path $uvmSource "uvm_pkg.sv")
if ($LASTEXITCODE -ne 0) { throw "UVM 1.2 package compilation failed." }

& $vlog -sv -work $library "+define+UVM_NO_DPI" `
    "+incdir+$uvmSource" "+incdir+verification/cpu_uvm" `
    "verification/cpu_uvm/cpu_uvm_pkg.sv" `
    "verification/cpu_uvm/uvm_top.sv"
if ($LASTEXITCODE -ne 0) { throw "CPU UVM smoke-test compilation failed." }

& $vsim -c -suppress 19 -lib $library uvm_top `
    +UVM_TESTNAME=cpu_smoke_test +UVM_NO_RELNOTES `
    -do "onbreak {quit -f -code 1}; run -all; quit -f -code 0"
if ($LASTEXITCODE -ne 0) { throw "CPU UVM smoke test failed." }
