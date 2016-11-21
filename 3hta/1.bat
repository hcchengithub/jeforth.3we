: @rem ;
@rem ' \ dup alias echo dup alias @echo dup alias @goto dup alias :end alias jeforth.hta
@echo hello world!! from Batch program
jeforth.hta include 1.bat
@goto end
." Hello world! from jeforth" cr 5000 nap bye 
:end

@rem [ ] check errorlevel returned from jeforth.hta
@rem [ ] 1.bat replaced by a more flexable notation
@rem [ ] use jeforth.hta to improve install.bat automation for all applications
