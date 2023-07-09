total计数

MEM/WB需要clear

考虑不同信号优先级,eStall和Eflush

接口接错

地址忘记变换

地址位搞错

WARNING: [Synth 8-5788] Register dout_reg in module Dmem is has both Set and reset with same priority. This may cause simulation mismatches. Consider rewriting code  [D:/vivado/LabH6s/LabH6s.srcs/sources_1/new/Dmem.v:56]
WARNING: [Synth 8-4767] Trying to implement RAM 'ram_reg' in registers. Block RAM or DRAM implementation is not possible; see log for reasons.
Reason is one or more of the following :
	1: RAM has multiple writes via different ports in same process. If RAM inferencing intended, write to one port per process. 
	2: Unable to determine number of words or word size in RAM