verdiSetActWin -dock widgetDock_<Decl._Tree>
simSetSimulator "-vcssv" -exec "build/simv" -args "+case=all"
debImport "-dbdir" "build/simv.daidir"
debLoadSimResult /home/a26403_asu/ADDV-Lab3/PART4/build/part4.fsdb
wvCreateWindow
verdiSetActWin -win $_nWave2
verdiWindowResize -win $_Verdi_1 "318" "27" "900" "631"
verdiWindowResize -win $_Verdi_1 "318" "27" "900" "631"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
wvGetSignalOpen -win $_nWave2
wvGetSignalSetScope -win $_nWave2 "/tb_matmul_apb"
verdiSetActWin -win $_nWave2
wvGetSignalSetSignalFilter -win $_nWave2 "*pclk*"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
}
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvGetSignalSetSignalFilter -win $_nWave2 "*preset*"
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 1)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSetPosition -win $_nWave2 {("G1" 1)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvGetSignalSetSignalFilter -win $_nWave2 "*psel*"
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 2)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetPosition -win $_nWave2 {("G1" 2)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetPosition -win $_nWave2 {("G1" 3)}
wvGetSignalSetSignalFilter -win $_nWave2 "*pre*"
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetPosition -win $_nWave2 {("G1" 3)}
wvGetSignalSetSignalFilter -win $_nWave2 "*pe*"
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetPosition -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvGetSignalSetScope -win $_nWave2 "/tb_matmul_apb/dut"
wvGetSignalSetSignalFilter -win $_nWave2 "*pready"
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSetPosition -win $_nWave2 {("G1" 4)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvGetSignalSetSignalFilter -win $_nWave2 "*write"
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSetPosition -win $_nWave2 {("G1" 5)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvGetSignalSetSignalFilter -win $_nWave2 "**"
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvGetSignalSetSignalFilter -win $_nWave2 "*addr*"
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvSetPosition -win $_nWave2 {("G1" 7)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
}
wvSelectSignal -win $_nWave2 {( "G1" 7 )} 
wvSetPosition -win $_nWave2 {("G1" 7)}
wvGetSignalSetSignalFilter -win $_nWave2 "*data*"
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 1)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSetPosition -win $_nWave2 {("G2" 1)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G2" 2)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSetPosition -win $_nWave2 {("G2" 2)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetPosition -win $_nWave2 {("G2" 3)}
wvGetSignalSetSignalFilter -win $_nWave2 "*slv*"
wvSetPosition -win $_nWave2 {("G2" 3)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetPosition -win $_nWave2 {("G2" 3)}
wvGetSignalSetSignalFilter -win $_nWave2 "*sl*"
wvSetPosition -win $_nWave2 {("G2" 3)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetPosition -win $_nWave2 {("G2" 3)}
wvGetSignalSetScope -win $_nWave2 "/tb_matmul_apb"
wvGetSignalSetSignalFilter -win $_nWave2 "*start*"
wvSetPosition -win $_nWave2 {("G2" 3)}
wvSetPosition -win $_nWave2 {("G2" 3)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetPosition -win $_nWave2 {("G2" 3)}
wvGetSignalSetScope -win $_nWave2 "/tb_matmul_apb/dut"
wvGetSignalSetScope -win $_nWave2 "/tb_matmul_apb/monitor"
wvGetSignalSetScope -win $_nWave2 "/tb_matmul_apb/dut/u_csr"
wvGetSignalSetScope -win $_nWave2 "/tb_matmul_apb/dut/u_core"
wvSetPosition -win $_nWave2 {("G2" 4)}
wvSetPosition -win $_nWave2 {("G2" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/u_core/start_mat_mul} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 4 )} 
wvSetPosition -win $_nWave2 {("G2" 4)}
wvGetSignalSetSignalFilter -win $_nWave2 "*done*"
wvSetPosition -win $_nWave2 {("G2" 4)}
wvSetPosition -win $_nWave2 {("G2" 4)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/u_core/start_mat_mul} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 4 )} 
wvSetPosition -win $_nWave2 {("G2" 4)}
wvSetPosition -win $_nWave2 {("G2" 5)}
wvSetPosition -win $_nWave2 {("G2" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/u_core/start_mat_mul} -height 16 \
{/tb_matmul_apb/dut/u_core/done_mat_mul} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 5 )} 
wvSetPosition -win $_nWave2 {("G2" 5)}
wvSetPosition -win $_nWave2 {("G2" 5)}
wvSetPosition -win $_nWave2 {("G2" 5)}
wvAddSignal -win $_nWave2 -clear
wvAddSignal -win $_nWave2 -group {"G1" \
{/tb_matmul_apb/PCLK} -height 16 \
{/tb_matmul_apb/PRESETn} -height 16 \
{/tb_matmul_apb/PSEL} -height 16 \
{/tb_matmul_apb/PENABLE} -height 16 \
{/tb_matmul_apb/dut/PREADY} -height 16 \
{/tb_matmul_apb/dut/PWRITE} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G2" \
{/tb_matmul_apb/dut/PADDR\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PWDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/PRDATA\[15:0\]} -height 16 \
{/tb_matmul_apb/dut/u_core/start_mat_mul} -height 16 \
{/tb_matmul_apb/dut/u_core/done_mat_mul} -height 16 \
}
wvAddSignal -win $_nWave2 -group {"G3" \
}
wvSelectSignal -win $_nWave2 {( "G2" 5 )} 
wvSetPosition -win $_nWave2 {("G2" 5)}
wvGetSignalClose -win $_nWave2
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 1
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 2 3 )} 
wvSelectSignal -win $_nWave2 {( "G2" 1 2 3 )} 
wvSetRadix -win $_nWave2 -format Hex
wvScrollUp -win $_nWave2 1
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetCursor -win $_nWave2 144880.827955 -snap {("G1" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvZoom -win $_nWave2 99917.812383 430895.565902
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 145246.349936 -snap {("G2" 1)}
wvSelectSignal -win $_nWave2 {( "G2" 2 )} 
wvSelectSignal -win $_nWave2 {( "G2" 3 )} 
wvSetCursor -win $_nWave2 178726.864498 -snap {("G2" 2)}
wvSetCursor -win $_nWave2 198421.284828 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 184635.190597 -snap {("G2" 2)}
wvSetCursor -win $_nWave2 199406.005845 -snap {("G2" 2)}
wvZoomAll -win $_nWave2
wvZoom -win $_nWave2 103253.076923 1239036.923077
wvZoom -win $_nWave2 499903.743195 961206.720710
wvSetCursor -win $_nWave2 574776.764930 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 510253.534571 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 520544.139454 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 519124.745677 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 519124.745677 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 507769.595461 -snap {("G1" 1)}
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 870069.857032 -snap {("G2" 1)}
wvSetCursor -win $_nWave2 875747.432140 -snap {("G2" 5)}
wvSetCursor -win $_nWave2 881425.007248 -snap {("G2" 5)}
wvSetCursor -win $_nWave2 896328.641906 -snap {("G2" 3)}
wvSetCursor -win $_nWave2 153275.999663 -snap {("G2" 0)}
wvSetCursor -win $_nWave2 147598.424555 -snap {("G1" 4)}
wvSetCursor -win $_nWave2 147598.424555 -snap {("G1" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 1 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 4 )} 
wvSelectSignal -win $_nWave2 {( "G1" 5 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvScrollDown -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSetCursor -win $_nWave2 157534.180994 -snap {("G2" 1)}
wvSelectSignal -win $_nWave2 {( "G2" 1 )} 
wvSetCursor -win $_nWave2 160372.968548 -snap {("G1" 6)}
wvSetCursor -win $_nWave2 323603.252899 -snap {("G2" 3)}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvScrollUp -win $_nWave2 1
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
