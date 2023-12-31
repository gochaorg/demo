PROJECT_NAME=AutoAccounting
EXE_NAME=$(PROJECT_NAME).exe

DIST_DIR=dist
SRC_DIR=source
SRC_EXE=$(SRC_DIR)\$(EXE_NAME)
DIST_EXE=$(DIST_DIR)\$(EXE_NAME)

help:
     @echo build script

$(SRC_EXE):
     cd $(SRC_DIR)
     dcc32 $(PROJECT_NAME).dpr
     cd ..
     
$(DIST_DIR): dist_dir $(DIST_EXE) $(DIST_DIR)\config.ini office_template sql

dist_dir:
     mkdir $(DIST_DIR)

$(DIST_EXE): dist_dir $(SRC_EXE) $(DIST_DIR)\config.ini
     copy /y $(SRC_EXE) $(DIST_EXE)

$(DIST_DIR)\config.ini: dist_dir
     copy /y config.ini $(DIST_DIR)\config.ini

office_template: dist_dir
     mkdir $(DIST_DIR)\sample
     copy /y sample\* $(DIST_DIR)\sample

clean:
     DEL /F /Q /S $(DIST_DIR)\sample\*
     rmdir $(DIST_DIR)\sample
     DEL /F /Q /S $(DIST_DIR)\sql\*
     rmdir $(DIST_DIR)\sql
     DEL /F /Q /S $(DIST_DIR)\*
     rmdir $(DIST_DIR)

sql:
     mkdir $(DIST_DIR)\sql
     copy /y sql\* $(DIST_DIR)\sql
     