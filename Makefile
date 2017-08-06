KICKASS=$(KICK_HOME)/kickass

ifeq ($(KICK_HOME),)
KICKASS := kickass
endif

intro: src/intro.asm
	$(KICKASS) src/intro.asm -o bin/intro.prg -symbolfiledir ../bin/