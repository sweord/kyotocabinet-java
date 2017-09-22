# Makefile for Kyoto Cabinet for Java



#================================================================
# Setting Variables
#================================================================


# Generic settings
SHELL = /bin/bash

# Package information
PACKAGE = kyotocabinet-java
VERSION = 1.24
PACKAGEDIR = $(PACKAGE)-$(VERSION)
PACKAGETGZ = $(PACKAGE)-$(VERSION).tar.gz
LIBVER = 1
LIBREV = 1

# Targets
JARFILES = kyotocabinet.jar
JAVAFILES = Loader.java Utility.java Error.java Visitor.java FileProcessor.java Cursor.java DB.java MapReduce.java ValueIterator.java Test.java
LIBRARYFILES = libjkyotocabinet.so
LIBOBJFILES = kyotocabinet.o

# Install destinations
prefix = /usr/local
exec_prefix = ${prefix}
datarootdir = ${prefix}/share
LIBDIR = ${exec_prefix}/lib
DESTDIR =

# Building configuration
JAVAC = /bin/javac
JAVACFLAGS = -d .
JAR = /bin/jar
JAVAH = /bin/javah
JAVADOC = /bin/javadoc
JAVADOCFLAGS = -locale en -tag note:a:Note: -nodeprecated -nohelp -quiet -noqualifier all
JAVARUN = /bin/java
JAVARUNFLAGS = -cp kyotocabinet.jar -Djava.library.path=.:/root/lib:/usr/local/lib::/usr/local/lib
CXX = clang++
CPPFLAGS = -I. -I$(INCLUDEDIR) -I/root/include -I/usr/local/include -DNDEBUG -I/include -I/include/ -I/Headers -I/Headers/ -I/usr/local/include \
	-I/usr/lib/jvm/java-8-openjdk-amd64/include -I/usr/lib/jvm/java-8-openjdk-amd64/include/linux
CXXFLAGS = -m64 -Wall -fPIC -fsigned-char -O2 -target x86_64-pc-linux-gnu 
LDFLAGS = -L. -L$(LIBDIR) -L/root/lib -L/usr/local/lib -L/usr/local/lib -L../kyotocabinet-github
LIBS = -lz -lstdc++ -lrt -lpthread -lm -lc  -m64 -lkyotocabinet 
LDENV = LD_RUN_PATH=/lib:/usr/lib:$(LIBDIR):$(HOME)/lib:/usr/local/lib:$(LIBDIR):/usr/local/lib:.
RUNENV = LD_LIBRARY_PATH=.:/lib:/usr/lib:$(LIBDIR):$(HOME)/lib:/usr/local/lib:$(LIBDIR):/usr/local/lib



#================================================================
# Suffix rules
#================================================================


.SUFFIXES :
.SUFFIXES : .cc .o

.cc.o :
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $<



#================================================================
# Actions
#================================================================


all : $(JARFILES) $(LIBRARYFILES)
	@printf '\n'
	@printf '#================================================================\n'
	@printf '# Ready to install.\n'
	@printf '#================================================================\n'


clean :
	rm -rf $(JARFILES) $(LIBRARYFILES) $(LIBOBJFILES) \
	  *.o a.out *.class check.in check.out gmon.out *.vlog \
	  casket* *.kch *.kct *.kcd *.kcf *.wal *.tmpkc* *.kcss *.log *~ hoge moge tako ika


untabify :
	ls *.cc *.h *.java | while read name ; \
	  do \
	    sed -e 's/\t/        /g' -e 's/ *$$//' $$name > $$name~; \
	    [ -f $$name~ ] && mv -f $$name~ $$name ; \
	  done


install :
	mkdir -p $(DESTDIR)$(LIBDIR)
	cp -Rf $(JARFILES) $(DESTDIR)$(LIBDIR)
	cp -Rf $(LIBRARYFILES) $(DESTDIR)$(LIBDIR)
	@printf '\n'
	@printf '#================================================================\n'
	@printf '# Thanks for using Kyoto Cabinet for Java.\n'
	@printf '#================================================================\n'


uninstall :
	cd $(DESTDIR)$(LIBDIR) && rm -f $(JARFILES)
	cd $(DESTDIR)$(LIBDIR) && rm -f $(LIBRARYFILES)


dist :
	$(MAKE) untabify
	$(MAKE) distclean
	cd .. && tar cvf - $(PACKAGEDIR) | gzip -c > $(PACKAGETGZ)
	sync ; sync


distclean : clean
	cd example && $(MAKE) clean
	rm -rf Makefile config.cache config.log config.status config.tmp autom4te.cache


head : kyotocabinet.jar
	rm -rf kyotocabinet_*.h
	CLASSPATH=kyotocabinet.jar $(JAVAH) -jni kyotocabinet.Utility kyotocabinet.Error \
	  kyotocabinet.Cursor kyotocabinet.DB kyotocabinet.MapReduce kyotocabinet.ValueIterator


check :
	$(MAKE) DBNAME=":" RNUM="10000" check-each
	$(MAKE) DBNAME="*" RNUM="10000" check-each
	$(MAKE) DBNAME="%" RNUM="10000" check-each
	$(MAKE) DBNAME="casket.kch" RNUM="10000" check-each
	$(MAKE) DBNAME="casket.kct" RNUM="10000" check-each
	$(MAKE) DBNAME="casket.kcd" RNUM="1000" check-each
	$(MAKE) DBNAME="casket.kcf" RNUM="10000" check-each
	@printf '\n'
	@printf '#================================================================\n'
	@printf '# Checking completed.\n'
	@printf '#================================================================\n'


check-each :
	rm -rf casket*
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  -rnd "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  -etc "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  -rnd -etc "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  -th 4 "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  -th 4 -rnd "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  -th 4 -etc "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test order \
	  -th 4 -rnd -etc "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test wicked \
	  "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test wicked \
	  -it 4 "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test wicked \
	  -th 4 "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test wicked \
	  -th 4 -it 4 "$(DBNAME)" "$(RNUM)"
	$(RUNENV) $(JAVARUN) $(JAVARUNFLAGS) kyotocabinet.Test misc \
	  "$(DBNAME)"
	rm -rf casket*


check-forever :
	while true ; \
	  do \
	    $(MAKE) check || break ; \
	  done


doc :
	$(MAKE) docclean
	mkdir -p doc
	mkdir -p doctmp
	\ls *.java | while read file ; \
	  do \
	    sed -e 's/public static class X/private static class X/' $$file > doctmp/$$file ; \
	  done
	$(JAVADOC) $(JAVADOCFLAGS) -windowtitle kyotocabinet -overview overview.html \
	  -d doc doctmp/*.java
	rm -rf doctmp


docclean :
	rm -rf doc doctmp


.PHONY : all clean install casket check doc



#================================================================
# Building binaries
#================================================================


kyotocabinet.jar : $(JAVAFILES)
	$(JAVAC) $(JAVACFLAGS) $(JAVAFILES)
	$(JAR) cvf $@ kyotocabinet/*.class
	rm -rf kyotocabinet

libjkyotocabinet.so : $(LIBOBJFILES)
	$(CXX) $(CXXFLAGS) -shared -Wl,-soname,libjkyotocabinet.so -o $@ \
	  $(LIBOBJFILES) $(LDFLAGS) $(LIBS)


# libjkyotocabinet.so.$(LIBVER) : libjkyotocabinet.so.$(LIBVER).$(LIBREV).0
# 	ln -f -s libjkyotocabinet.so.$(LIBVER).$(LIBREV).0 $@


# libjkyotocabinet.so : libjkyotocabinet.so.$(LIBVER).$(LIBREV).0
# 	ln -f -s libjkyotocabinet.so.$(LIBVER).$(LIBREV).0 $@


libjkyotocabinet.dylib : $(LIBOBJFILES)
	$(CXX) $(CXXFLAGS) -dynamiclib -o $@ \
	  -install_name $(LIBDIR)/libjkyotocabinet.dylib \
	  $(LIBOBJFILES) $(LDFLAGS) $(LIBS)


# libjkyotocabinet.$(LIBVER).dylib : libjkyotocabinet.$(LIBVER).$(LIBREV).0.dylib
# 	ln -f -s libjkyotocabinet.$(LIBVER).$(LIBREV).0.dylib $@


# libjkyotocabinet.dylib : libjkyotocabinet.$(LIBVER).$(LIBREV).0.dylib
# 	ln -f -s libjkyotocabinet.$(LIBVER).$(LIBREV).0.dylib $@


# libjkyotocabinet.jnilib : libjkyotocabinet.dylib
# 	ln -f -s libjkyotocabinet.dylib $@


kyotocabinet.o : kyotocabinet_Utility.h kyotocabinet_Error.h \
  kyotocabinet_Cursor.h kyotocabinet_DB.h kyotocabinet_MapReduce.h kyotocabinet_ValueIterator.h



# END OF FILE
