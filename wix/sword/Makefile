InstallSword.exe:
	$(WINDRES) -o icon.o icon.rc
	$(CC) -o $@ main.c icon.o -D_UNICODE -municode -mwindows -lgdi32
