ModelSim (Lab 4, Kevin Wong)
1. ModelSim > File > Change Directory... > this folder
2. Transcript:  do compile.do
3. Transcript:  do sim_latch.do    (SR latch alone, no clock: asynchronous behaviour)
                do sim_filtre.do   (filter: bounces rejected, latch output)
                do sim_system.do   (whole controller)
Each testbench prints "ok ..." lines and "*** ... PASSED ***" in the Transcript.
