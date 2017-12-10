module hazardDetection(IDEXMEM_Read, IDEX_RegisterRt, IFID_RegisterRs, IFID_RegisterRt, PCWrite, IFIDWrite, conMux);
input [4:0] IDEX_RegisterRt, IFID_RegisterRs, IFID_RegisterRt;
input IDEXMEM_Read;
output reg PCWrite, IFIDWrite, conMux;

always@(*)
if(IDEXMEM_Read & ((IDEX_RegisterRt == IFID_RegisterRs) | (IDEX_RegisterRt == IFID_RegisterRt)))
begin  //stall
PCWrite=0;
IFIDWrite=0;
//zero the control signals 
conMux=0;
end

else
begin 
PCWrite=1;
IFIDWrite=1;
conMux=1;
end

endmodule
